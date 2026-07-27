import prisma from "../../../prisma/client.js";
// Triggering nodemon restart with schema update
import DevBuildError from "../../../lib/DevBuildError.js";
import { StatusCodes } from "http-status-codes";
import { QueryBuilder } from "../../../utils/QueryBuilder.js";
import { extractLeadPayload } from "../../../utils/workflowHelpers.js";

const createCrmLeadService = async (payload) => {
    const cleanPayload = await extractLeadPayload(payload.businessId, payload);
    const result = await prisma.crmLead.create({
        data: cleanPayload,
    });
    return result;
};

const getAllCrmLeadsService = async (query = {}) => {
    const queryBuilder = new QueryBuilder(query)
        .search(["name", "email", "phone"])
        .filter()
        .sort()
        .paginate()
        .fields();

    const queryParams = queryBuilder.build();

    if (query.country && query.country !== '') {
        delete queryParams.where.country;
        queryParams.where.AND = [
            ...(queryParams.where.AND || []),
            {
                OR: [
                    { country: { contains: query.country, mode: "insensitive" } },
                    { address: { contains: query.country, mode: "insensitive" } }
                ]
            }
        ];
    }

    if (!queryParams.select) {
        queryParams.include = {
            createdBy: {
                select: {
                    id: true,
                    email: true,
                    firstName: true,
                    lastName: true,
                }
            },
            branch: {
                select: {
                    id: true,
                    name: true
                }
            }
        };
    }

    const [result, total, totalBooked, callLead] = await Promise.all([
        prisma.crmLead.findMany(queryParams),
        prisma.crmLead.count({ where: queryParams.where }),
        prisma.crmLead.count({ where: { ...queryParams.where, status: "BOOKED" } }),
        prisma.crmLead.count({ where: { ...queryParams.where, source: "COLD_CALL" } }),
    ]);

    const meta = queryBuilder.getMeta(total);

    return {
        meta: {
            ...meta,
            totalCount: total,
            totalBooked,
            callLead,
        },
        data: result,
    };
};

const getCrmLeadByIdService = async (id, query = {}) => {
    const queryBuilder = new QueryBuilder(query).fields();
    const queryParams = queryBuilder.build();

    const findArgs = {
        where: { id },
    };

    if (queryParams.select) {
        findArgs.select = queryParams.select;
    } else {
        findArgs.include = {
            createdBy: {
                select: {
                    id: true,
                    email: true,
                    firstName: true,
                    lastName: true,
                }
            },
            branch: {
                select: {
                    id: true,
                    name: true
                }
            }
        };
    }

    const result = await prisma.crmLead.findUnique(findArgs);
    
    if (!result) {
        throw new DevBuildError("CRM Lead not found", StatusCodes.NOT_FOUND);
    }

    return result;
};

const updateCrmLeadService = async (id, payload) => {
    const isExist = await prisma.crmLead.findUnique({
        where: { id },
    });

    if (!isExist) {
        throw new DevBuildError("CRM Lead not found", StatusCodes.NOT_FOUND);
    }

    const cleanPayload = await extractLeadPayload(isExist.businessId, payload);
    const result = await prisma.crmLead.update({
        where: { id },
        data: cleanPayload,
    });
    
    return result;
};

const deleteCrmLeadService = async (id) => {
    const isExist = await prisma.crmLead.findUnique({
        where: { id },
    });

    if (!isExist) {
        throw new DevBuildError("CRM Lead not found", StatusCodes.NOT_FOUND);
    }

    const result = await prisma.crmLead.delete({
        where: { id },
    });
    
    return result;
};

const getCrmLeadProductTypesService = async (businessId, branchId) => {
    const where = {
        businessId,
        productType: { not: null },
    };
    if (branchId) where.branchId = branchId;

    const result = await prisma.crmLead.findMany({
        where,
        select: { productType: true },
        distinct: ["productType"],
    });

    const leadTypes = result
        .map((r) => r.productType)
        .filter((t) => t && t.trim() !== "");

    // Fetch booking product types as well
    const business = await prisma.business.findUnique({
        where: { id: businessId },
        select: { businessType: true },
    });
    const businessType = business?.businessType || "ORDER_BOOKING";

    const detailsModelMap = {
        ORDER_BOOKING: "orderDetails",
        PARCEL_DELIVERY: "parcelDetails",
    };

    const detailsModelName = detailsModelMap[businessType];
    let bookingTypes = [];

    if (detailsModelName) {
        const bookingWhere = {
            businessId,
            productType: { not: null },
        };
        if (branchId) bookingWhere.branchId = branchId;

        const bookingResult = await prisma[detailsModelName].findMany({
            where: bookingWhere,
            select: { productType: true },
            distinct: ["productType"],
        });

        bookingTypes = bookingResult
            .map((r) => r.productType)
            .filter((t) => t && t.trim() !== "");
    }

    const typesSet = new Set([...leadTypes, ...bookingTypes]);
    return Array.from(typesSet);
};

export const CrmLeadService = {
    createCrmLeadService,
    getAllCrmLeadsService,
    getCrmLeadByIdService,
    updateCrmLeadService,
    deleteCrmLeadService,
    getCrmLeadProductTypesService,
};
