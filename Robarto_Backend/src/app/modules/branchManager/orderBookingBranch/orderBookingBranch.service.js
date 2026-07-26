import prisma from "../../../prisma/client.js";
import DevBuildError from "../../../lib/DevBuildError.js";
import { StatusCodes } from "http-status-codes";
import { QueryBuilder } from "../../../utils/QueryBuilder.js";
import { NotificationService } from "../../notification/notification.service.js";
import { GoogleCalendarService } from "../../googleCalendar/googleCalendar.service.js";
import { syncBookingToCrmLead } from "../../../utils/workflowHelpers.js";
import {
    getBookingModel,
    buildMainPayload,
    buildDetailsPayload,
    buildDetailsUpdatePayload,
    saveAdditionalDetails,
    updateAdditionalDetails,
    attachDetails,
} from "../../../utils/bookingHelpers.js";

const resolveBusinessType = async (businessId) => {
    const business = await prisma.business.findUnique({
        where: { id: businessId },
        select: { businessType: true },
    });
    return business?.businessType || "ORDER_BOOKING";
};

const createBookingService = async (payload) => {
    const businessType = await resolveBusinessType(payload.businessId);
    const { model, detailsModel, detailsRelation } = getBookingModel(businessType);
    const mainPayload = buildMainPayload(payload.businessId, payload, businessType);

    const result = await prisma.$transaction(async (tx) => {
        const booking = await model.create({ data: mainPayload });
        const detailsPayload = buildDetailsPayload(businessType, payload, booking.id, booking.businessId, booking.branchId);
        await detailsModel.create({ data: detailsPayload });

        // Create payment detail if provided
        const hasPaymentStatus = payload.paymentStatus || payload.paymentDetails?.paymentStatus;
        const hasPaymentMethod = payload.paymentMethod || payload.paymentDetails?.paymentMethod;
        const hasTransactionId = payload.transactionId || payload.paymentDetails?.transactionId;

        if (hasPaymentStatus || hasPaymentMethod || hasTransactionId) {
            await tx.paymentDetail.create({
                data: {
                    referenceId: booking.id,
                    createdById: mainPayload.createdById || null,
                    paymentStatus: hasPaymentStatus || "PENDING",
                    paymentMethod: hasPaymentMethod || null,
                    transactionId: hasTransactionId || null,
                }
            });
        }

        // Save any extra/additional fields
        await saveAdditionalDetails(tx, booking.businessId, booking.branchId, booking.id, payload);

        const createdBooking = await model.findUnique({
            where: { id: booking.id },
            include: { [detailsRelation]: true },
        });

        await syncBookingToCrmLead(tx, createdBooking, payload, businessType);

        return await attachDetails(tx, createdBooking);
    });

    // Trigger notification for booking creation
    NotificationService.createAndSendNotification({
        title: `New ${businessType.replace('_', ' ')} Created`,
        message: `Booking for ${result.customerName} (${result.customerNumber}) has been created.`,
        type: businessType,
        businessId: result.businessId,
        branchId: result.branchId || null,
        bookingId: result.id,
        conversationId: result.conversationId || null,
    }).catch(err => console.error("Error sending booking creation notification:", err));

    // Sync to Google Calendar for all booking categories
    GoogleCalendarService.syncBookingToCalendar(result).catch(err => {
        console.error("Error auto-syncing booking to Google Calendar in branch service:", err);
    });

    return result;
};

const getAllBookingsService = async (query = {}, filter = {}) => {
    const { startDate, endDate, ...restQuery } = query;
    const businessId = filter.businessId || restQuery.businessId;
    const businessType = await resolveBusinessType(businessId);
    const { model, detailsRelation } = getBookingModel(businessType);

    const searchConfig = ["customerName", "customerNumber", "email", "country", "price", "note"];
    if (businessType !== "APPOINTMENT_BOOKING") {
        searchConfig.push("productName");
    }
    if (businessType === "ORDER_BOOKING") {
        searchConfig.push({
            orderDetails: ["deliveryAddress", "productType", "address"]
        });
    } else if (businessType === "PARCEL_DELIVERY") {
        searchConfig.push({
            parcelDetails: ["pickupAddress", "deliveryAddress", "productType", "productHeight"]
        });
    } else if (businessType === "APPOINTMENT_BOOKING") {
        searchConfig.push({
            appointmentDetails: ["platform", "duration"]
        });
    }

    const queryBuilder = new QueryBuilder(restQuery)
        .search(searchConfig)
        .filter()
        .sort()
        .paginate()
        .fields();

    const queryParams = queryBuilder.build();
    queryParams.where = { ...queryParams.where, ...filter };

    if (startDate || endDate) {
        queryParams.where.createdAt = {};
        if (startDate) {
            const start = new Date(startDate);
            if (!isNaN(start.getTime())) {
                queryParams.where.createdAt.gte = start;
            }
        }
        if (endDate) {
            const end = new Date(endDate);
            if (!isNaN(end.getTime())) {
                if (endDate.length === 10) {
                    end.setHours(23, 59, 59, 999);
                }
                queryParams.where.createdAt.lte = end;
            }
        }
    }

    // productType filter — nested relation filter based on businessType
    const productType = restQuery.productType;
    if (productType) {
        const detailsFilterKey =
            businessType === "ORDER_BOOKING" ? "orderDetails" :
                businessType === "PARCEL_DELIVERY" ? "parcelDetails" :
                    businessType === "APPOINTMENT_BOOKING" ? "appointmentDetails" : null;
        if (detailsFilterKey) {
            queryParams.where = {
                ...queryParams.where,
                [detailsFilterKey]: { productType },
            };
            delete queryParams.where.productType;
        }
    }

    if (!queryParams.select) {
        queryParams.include = {
            [detailsRelation]: true,
            createdBy: {
                select: { id: true, email: true, firstName: true, lastName: true }
            },
            branch: { select: { id: true, name: true } }
        };
    }

    const baseWhere = { ...queryParams.where };
    delete baseWhere.status;

    const [result, total, totalBookings, pending, confirmed, delivered] = await Promise.all([
        model.findMany(queryParams),
        model.count({ where: queryParams.where }),
        model.count({ where: baseWhere }),
        model.count({ where: { ...baseWhere, status: "PENDING" } }),
        model.count({ where: { ...baseWhere, status: "CONFIRMED" } }),
        model.count({ where: { ...baseWhere, status: { in: ["DELIVERED", "COMPLETED"] } } }),
    ]);

    const formattedData = await attachDetails(prisma, result);

    return {
        meta: {
            ...queryBuilder.getMeta(total),
            total,
            totalBookings,
            pending,
            confirmed,
            delivered,
        },
        data: formattedData,
    };
};

const getBookingByIdService = async (id, filter = {}, query = {}) => {
    const businessId = filter.businessId;
    const businessType = await resolveBusinessType(businessId);
    const { model, detailsRelation } = getBookingModel(businessType);

    const queryBuilder = new QueryBuilder(query).fields();
    const queryParams = queryBuilder.build();
    const findArgs = { where: { id, ...filter } };

    if (queryParams.select) {
        findArgs.select = queryParams.select;
    } else {
        findArgs.include = {
            [detailsRelation]: true,
            createdBy: {
                select: { id: true, email: true, firstName: true, lastName: true }
            },
            branch: { select: { id: true, name: true } }
        };
    }

    const result = await model.findUnique(findArgs);
    if (!result) throw new DevBuildError("Booking not found", StatusCodes.NOT_FOUND);
    return await attachDetails(prisma, result);
};

const updateBookingService = async (id, filter, payload) => {
    const businessId = filter.businessId;
    const businessType = await resolveBusinessType(businessId);
    const { model, detailsModel, detailsKey, detailsRelation } = getBookingModel(businessType);

    const isExist = await model.findUnique({ where: { id, ...filter } });
    if (!isExist) throw new DevBuildError("Booking not found or no access", StatusCodes.NOT_FOUND);

    const mainPayload = buildMainPayload(businessId, payload, businessType);
    const detailsUpdateData = buildDetailsUpdatePayload(businessType, payload);
    const { userId } = payload;

    const result = await prisma.$transaction(async (tx) => {
        const updated = await model.update({ where: { id }, data: mainPayload });

        if (Object.keys(detailsUpdateData).length > 0) {
            await detailsModel.upsert({
                where: { [detailsKey]: id },
                update: detailsUpdateData,
                create: buildDetailsPayload(businessType, payload, id, updated.businessId, updated.branchId),
            });
        }

        // Handle payment details updates if provided
        const paymentStatus = payload.paymentStatus || payload.paymentDetails?.paymentStatus;
        const paymentMethod = payload.paymentMethod !== undefined ? payload.paymentMethod : payload.paymentDetails?.paymentMethod;
        const transactionId = payload.transactionId !== undefined ? payload.transactionId : payload.paymentDetails?.transactionId;

        if (paymentStatus || paymentMethod !== undefined || transactionId !== undefined) {
            const existingPayment = await tx.paymentDetail.findFirst({ where: { referenceId: id } });
            if (existingPayment) {
                await tx.paymentDetail.update({
                    where: { id: existingPayment.id },
                    data: {
                        paymentStatus: paymentStatus || existingPayment.paymentStatus,
                        paymentMethod: paymentMethod !== undefined ? paymentMethod : existingPayment.paymentMethod,
                        transactionId: transactionId !== undefined ? transactionId : existingPayment.transactionId,
                    }
                });
            } else {
                await tx.paymentDetail.create({
                    data: {
                        referenceId: id,
                        createdById: userId || null,
                        paymentStatus: paymentStatus || "PENDING",
                        paymentMethod: paymentMethod || null,
                        transactionId: transactionId || null,
                    }
                });
            }
        }

        // Handle additional details updates
        await updateAdditionalDetails(tx, businessId, updated.branchId, id, payload);

        await tx.auditLog.create({
            data: {
                businessId,
                userId: userId || null,
                action: "UPDATE",
                targetTable: businessType,
                targetId: id,
                oldValues: { note: isExist.note, price: isExist.price },
                newValues: { note: updated.note, price: updated.price },
            }
        });

        const updatedBooking = await model.findUnique({
            where: { id },
            include: { [detailsRelation]: true },
        });

        await syncBookingToCrmLead(tx, updatedBooking, payload, businessType);

        return await attachDetails(tx, updatedBooking);
    });

    // Trigger notification if booking is delivered or completed
    if (result && (result.status === "DELIVERED" || result.status === "COMPLETED")) {
        NotificationService.createAndSendNotification({
            title: `${businessType.replace('_', ' ')} Delivered`,
            message: `Booking for ${result.customerName} has been marked as ${result.status.toLowerCase()}.`,
            type: `${businessType}_DELIVERY`,
            businessId: result.businessId,
            branchId: result.branchId || null,
            bookingId: result.id,
            conversationId: result.conversationId || null,
        }).catch(err => console.error("Error sending booking delivery notification:", err));
    }

    return result;
};

const deleteBookingService = async (id, filter) => {
    const businessId = filter.businessId;
    const businessType = await resolveBusinessType(businessId);
    const { model } = getBookingModel(businessType);

    const isExist = await model.findUnique({ where: { id, ...filter } });
    if (!isExist) throw new DevBuildError("Booking not found or no access", StatusCodes.NOT_FOUND);

    return await prisma.$transaction(async (tx) => {
        // Delete payment details
        await tx.paymentDetail.deleteMany({ where: { referenceId: id } });
        // Delete additional details
        await tx.additionalDetail.deleteMany({ where: { referenceId: id } });
        // Delete the booking itself
        return await model.delete({ where: { id } });
    });
};

const getBookingCountriesService = async (businessId, branchId) => {
    const businessType = await resolveBusinessType(businessId);
    const { model } = getBookingModel(businessType);

    const bookingWhere = {
        businessId,
    };
    if (branchId) {
        bookingWhere.branchId = branchId;
    }

    const bookingResult = await model.findMany({
        where: bookingWhere,
        select: {
            country: true,
        },
    });

    const leadWhere = {
        businessId,
    };
    if (branchId) {
        leadWhere.branchId = branchId;
    }

    const leadResult = await prisma.crmLead.findMany({
        where: leadWhere,
        select: {
            country: true,
            metadata: true,
        },
    });

    const additionalResult = await prisma.additionalDetail.findMany({
        where: {
            businessId,
            ...(branchId ? { branchId } : {}),
            key: {
                in: ["country", "Country", "destination", "Destination", "country_name", "destination_country"],
            },
        },
        select: {
            value: true,
        },
    });

    const countriesSet = new Set();
    bookingResult.forEach((b) => {
        if (b.country && b.country.trim() !== "") {
            countriesSet.add(b.country.trim());
        }
    });

    leadResult.forEach((l) => {
        if (l.country && l.country.trim() !== "") {
            countriesSet.add(l.country.trim());
        }
        if (l.metadata && typeof l.metadata === "object") {
            const metaCountry = l.metadata.country || l.metadata.Country || l.metadata.country_name;
            const metaDestination = l.metadata.destination || l.metadata.Destination || l.metadata.destination_country;
            if (metaCountry && typeof metaCountry === "string" && metaCountry.trim() !== "") {
                countriesSet.add(metaCountry.trim());
            }
            if (metaDestination && typeof metaDestination === "string" && metaDestination.trim() !== "") {
                countriesSet.add(metaDestination.trim());
            }
        }
    });

    additionalResult.forEach((a) => {
        if (a.value && a.value.trim() !== "") {
            countriesSet.add(a.value.trim());
        }
    });

    return Array.from(countriesSet).filter((c) => c && c.trim() !== "");
};

/**
 * Returns distinct productTypes for a given business & branch.
 * Only applicable for ORDER_BOOKING and PARCEL_DELIVERY (have productType in details).
 */
const getBookingProductTypesService = async (businessId, branchId) => {
    const businessType = await resolveBusinessType(businessId);

    const detailsModelMap = {
        ORDER_BOOKING: "orderDetails",
        PARCEL_DELIVERY: "parcelDetails",
    };

    const detailsModelName = detailsModelMap[businessType];
    if (!detailsModelName) return [];

    const where = {
        businessId,
        branchId,
        productType: { not: null },
    };

    const result = await prisma[detailsModelName].findMany({
        where,
        select: { productType: true },
        distinct: ["productType"],
    });

    return result
        .map((r) => r.productType)
        .filter((t) => t && t.trim() !== "");
};

export const OrderBookingBranchService = {
    createBookingService,
    getAllBookingsService,
    getBookingByIdService,
    updateBookingService,
    deleteBookingService,
    getBookingCountriesService,
    getBookingProductTypesService,
};
