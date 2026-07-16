import prisma from "../prisma/client.js";

/**
 * Safely parses a date value, returning null if it's invalid
 */
const parseSafeDate = (value) => {
    if (!value) return null;
    const date = new Date(value);
    if (isNaN(date.getTime())) {
        return null;
    }
    return date;
};

const getFlexibleValue = (payload, standardKey, fallbackKeys = []) => {
    if (!payload || typeof payload !== "object") return undefined;

    // Build list of target keys normalized (lowercase alphanumeric)
    const targets = [standardKey, ...fallbackKeys].map(k => k.toLowerCase().replace(/[^a-z0-9]/g, ""));

    for (const key of Object.keys(payload)) {
        const cleanKey = key.toLowerCase().replace(/[^a-z0-9]/g, "");
        if (targets.includes(cleanKey)) {
            return payload[key];
        }
    }
    return undefined; // key is missing
};

/**
 * Returns the correct Prisma model config based on businessType.
 */
export const getBookingModel = (businessType) => {
    if (businessType === "APPOINTMENT_BOOKING") {
        return {
            model: prisma.appointmentBooking,
            detailsModel: prisma.appointmentDetails,
            detailsKey: "appointmentId",
            detailsRelation: "appointmentDetails",
        };
    }
    if (businessType === "PARCEL_DELIVERY") {
        return {
            model: prisma.parcelDelivery,
            detailsModel: prisma.parcelDetails,
            detailsKey: "parcelDeliveryId",
            detailsRelation: "parcelDetails",
        };
    }
    // Default: ORDER_BOOKING
    return {
        model: prisma.orderBooking,
        detailsModel: prisma.orderDetails,
        detailsKey: "orderId",
        detailsRelation: "orderDetails",
    };
};

/**
 * Builds the main booking payload (common fields).
 */
export const buildMainPayload = (businessId, payload) => {
    const extracted = { businessId };
    const fields = ["branchId", "createdById", "customerName", "customerNumber", "email", "country", "note", "status", "conversationId", "productName"];
    for (const f of fields) {
        if (payload[f] !== undefined) extracted[f] = payload[f];
    }
    if (payload.price !== undefined) extracted.price = String(payload.price);
    return extracted;
};

/**
 * Builds the details payload based on businessType.
 */
export const buildDetailsPayload = (businessType, payload, bookingId, businessId, branchId) => {
    if (businessType === "APPOINTMENT_BOOKING") {
        const rawTime = getFlexibleValue(payload, "appointmentTime", ["appointment_time"]);
        return {
            businessId,
            branchId: branchId || null,
            appointmentId: bookingId,
            appointmentDate: getFlexibleValue(payload, "appointmentDate", ["appointment_date"]) ?? null,
            appointmentTime: parseSafeDate(rawTime),
            platform: getFlexibleValue(payload, "platform") ?? null,
            duration: getFlexibleValue(payload, "duration") ?? null,
        };
    }
    if (businessType === "PARCEL_DELIVERY") {
        return {
            businessId,
            branchId: branchId || null,
            parcelDeliveryId: bookingId,
            pickupAddress: getFlexibleValue(payload, "pickupAddress", ["pickup_address"]) ?? null,
            pickupDate: getFlexibleValue(payload, "pickupDate", ["pickup_date", "preferred_pickup_date"]) ?? null,
            pickupTime: getFlexibleValue(payload, "pickupTime", ["pickup_time", "preferred_pickup_time", "datetime"]) ?? null,
            deliveryDate: getFlexibleValue(payload, "deliveryDate", ["delivery_date"]) ?? null,
            deliveryAddress: getFlexibleValue(payload, "deliveryAddress", ["delivery_address", "destination"]) ?? null,
            productType: getFlexibleValue(payload, "productType", ["product_type", "packageType", "package_type", "shipmentType", "shipment_type"]) ?? null,
            productHeight: getFlexibleValue(payload, "productHeight", ["product_height", "packageHeight", "package_height"]) ?? null,
            productWeight: (() => {
                const w = getFlexibleValue(payload, "productWeight", ["product_weight", "packageWeight", "package_weight", "weightKg", "weight_kg"]);
                if (w === undefined || w === null || w === "") return null;
                const parsed = parseInt(w, 10);
                return isNaN(parsed) ? null : parsed;
            })(),
            receiverName: getFlexibleValue(payload, "receiverName", ["receiver_name"]) ?? null,
            receiverPhone: getFlexibleValue(payload, "receiverPhone", ["receiver_phone", "receiver_phone_number", "receiverPhoneNumber"]) ?? null,
        };
    }
    // Default: ORDER_BOOKING
    return {
        businessId,
        branchId: branchId || null,
        orderId: bookingId,
        deliveryDate: getFlexibleValue(payload, "deliveryDate", ["delivery_date"]) ?? null,
        deliveryAddress: getFlexibleValue(payload, "deliveryAddress", ["delivery_address", "destination"]) ?? null,
        productType: getFlexibleValue(payload, "productType", ["product_type", "packageType", "package_type"]) ?? null,
    };
};

/**
 * Builds partial details payload for update (only provided fields).
 */
export const buildDetailsUpdatePayload = (businessType, payload) => {
    const data = {};
    if (businessType === "APPOINTMENT_BOOKING") {
        const rawTime = getFlexibleValue(payload, "appointmentTime", ["appointment_time"]);
        const appointmentDate = getFlexibleValue(payload, "appointmentDate", ["appointment_date"]);
        if (appointmentDate !== undefined) data.appointmentDate = appointmentDate;
        if (rawTime !== undefined) data.appointmentTime = parseSafeDate(rawTime);
        
        const platform = getFlexibleValue(payload, "platform");
        if (platform !== undefined) data.platform = platform;
        
        const duration = getFlexibleValue(payload, "duration");
        if (duration !== undefined) data.duration = duration;
    } else if (businessType === "PARCEL_DELIVERY") {
        const pickupAddress = getFlexibleValue(payload, "pickupAddress", ["pickup_address"]);
        if (pickupAddress !== undefined) data.pickupAddress = pickupAddress;
        
        const pickupDate = getFlexibleValue(payload, "pickupDate", ["pickup_date", "preferred_pickup_date"]);
        if (pickupDate !== undefined) data.pickupDate = pickupDate;
        
        const pickupTime = getFlexibleValue(payload, "pickupTime", ["pickup_time", "preferred_pickup_time", "datetime"]);
        if (pickupTime !== undefined) data.pickupTime = pickupTime;

        const deliveryDate = getFlexibleValue(payload, "deliveryDate", ["delivery_date"]);
        if (deliveryDate !== undefined) data.deliveryDate = deliveryDate;

        const deliveryAddress = getFlexibleValue(payload, "deliveryAddress", ["delivery_address", "destination"]);
        if (deliveryAddress !== undefined) data.deliveryAddress = deliveryAddress;

        const productType = getFlexibleValue(payload, "productType", ["product_type", "packageType", "package_type", "shipmentType", "shipment_type"]);
        if (productType !== undefined) data.productType = productType;

        const productHeight = getFlexibleValue(payload, "productHeight", ["product_height", "packageHeight", "package_height"]);
        if (productHeight !== undefined) data.productHeight = productHeight;

        const w = getFlexibleValue(payload, "productWeight", ["product_weight", "packageWeight", "package_weight", "weightKg", "weight_kg"]);
        if (w !== undefined) {
            if (w === null || w === "") {
                data.productWeight = null;
            } else {
                const parsed = parseInt(w, 10);
                data.productWeight = isNaN(parsed) ? null : parsed;
            }
        }

        const receiverName = getFlexibleValue(payload, "receiverName", ["receiver_name"]);
        if (receiverName !== undefined) data.receiverName = receiverName;

        const receiverPhone = getFlexibleValue(payload, "receiverPhone", ["receiver_phone", "receiver_phone_number", "receiverPhoneNumber"]);
        if (receiverPhone !== undefined) data.receiverPhone = receiverPhone;
    } else {
        const deliveryDate = getFlexibleValue(payload, "deliveryDate", ["delivery_date"]);
        if (deliveryDate !== undefined) data.deliveryDate = deliveryDate;

        const deliveryAddress = getFlexibleValue(payload, "deliveryAddress", ["delivery_address", "destination"]);
        if (deliveryAddress !== undefined) data.deliveryAddress = deliveryAddress;

        const productType = getFlexibleValue(payload, "productType", ["product_type", "packageType", "package_type"]);
        if (productType !== undefined) data.productType = productType;
    }
    return data;
};

/**
 * Extracts and saves any non-standard/additional fields from booking payload.
 */
export const saveAdditionalDetails = async (tx, businessId, branchId, bookingId, payload) => {
    const standardFields = new Set([
        "businessId",
        "branchId",
        "createdById",
        "customerName",
        "customerNumber",
        "email",
        "note",
        "price",
        "businessType",
        "paymentStatus",
        "paymentMethod",
        "transactionId",
        "paymentDetails",
        "deliveryDate",
        "deliveryAddress",
        "productType",
        "appointmentDate",
        "appointmentTime",
        "platform",
        "duration",
        "pickupAddress",
        "pickupDate",
        "pickup_date",
        "pickupTime",
        "pickup_time",
        "productHeight",
        "productWeight",
        "userId",
        "status",
        "conversationId",
        "productName"
    ]);

    const additionalDetailsData = [];
    for (const key of Object.keys(payload)) {
        if (!standardFields.has(key) && payload[key] !== undefined && payload[key] !== null) {
            const val = typeof payload[key] === 'object' ? JSON.stringify(payload[key]) : String(payload[key]);
            additionalDetailsData.push({
                businessId,
                branchId: branchId || null,
                referenceId: bookingId,
                key,
                value: val,
            });
        }
    }

    if (additionalDetailsData.length > 0) {
        await tx.additionalDetail.createMany({
            data: additionalDetailsData
        });
    }
};

/**
 * Updates or creates additional detail fields.
 */
export const updateAdditionalDetails = async (tx, businessId, branchId, bookingId, payload) => {
    const standardFields = new Set([
        "businessId",
        "branchId",
        "createdById",
        "customerName",
        "customerNumber",
        "email",
        "note",
        "price",
        "businessType",
        "paymentStatus",
        "paymentMethod",
        "transactionId",
        "paymentDetails",
        "deliveryDate",
        "deliveryAddress",
        "productType",
        "appointmentDate",
        "appointmentTime",
        "platform",
        "duration",
        "pickupAddress",
        "pickupDate",
        "pickup_date",
        "pickupTime",
        "pickup_time",
        "productHeight",
        "productWeight",
        "userId",
        "status",
        "conversationId",
        "productName"
    ]);

    for (const key of Object.keys(payload)) {
        if (!standardFields.has(key) && payload[key] !== undefined) {
            const value = payload[key];
            const val = typeof value === 'object' ? JSON.stringify(value) : String(value);

            const existingDetail = await tx.additionalDetail.findFirst({
                where: { referenceId: bookingId, key }
            });

            if (existingDetail) {
                if (value === null) {
                    await tx.additionalDetail.delete({ where: { id: existingDetail.id } });
                } else {
                    await tx.additionalDetail.update({
                        where: { id: existingDetail.id },
                        data: { value: val }
                    });
                }
            } else if (value !== null) {
                await tx.additionalDetail.create({
                    data: {
                        businessId,
                        branchId: branchId || null,
                        referenceId: bookingId,
                        key,
                        value: val
                    }
                });
            }
        }
    }
};

/**
 * Fetches and attaches paymentDetail and additionalDetails to the booking(s).
 */
export const attachDetails = async (txOrPrisma, bookings) => {
    const isArray = Array.isArray(bookings);
    const list = isArray ? bookings : [bookings];
    if (list.length === 0) return bookings;

    const bookingIds = list.map(b => b.id);
    const [allPaymentDetails, allAdditionalDetails] = await Promise.all([
        txOrPrisma.paymentDetail.findMany({ where: { referenceId: { in: bookingIds } } }),
        txOrPrisma.additionalDetail.findMany({ where: { referenceId: { in: bookingIds } } }),
    ]);

    const paymentMap = {};
    for (const pd of allPaymentDetails) {
        paymentMap[pd.referenceId] = pd;
    }
    const additionalMap = {};
    for (const ad of allAdditionalDetails) {
        if (!additionalMap[ad.referenceId]) {
            additionalMap[ad.referenceId] = [];
        }
        additionalMap[ad.referenceId].push(ad);
    }

    const formatted = list.map(booking => ({
        ...booking,
        paymentDetails: paymentMap[booking.id] || null,
        additionalDetails: additionalMap[booking.id] || [],
    }));

    return isArray ? formatted : formatted[0];
};

