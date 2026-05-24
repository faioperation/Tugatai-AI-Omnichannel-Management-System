import prisma from "../../../prisma/client.js";
import DevBuildError from "../../../lib/DevBuildError.js";
import { StatusCodes } from "http-status-codes";

import { QueryBuilder } from "../../../utils/QueryBuilder.js";

const createBusinessService = async (payload) => {
    const result = await prisma.$transaction(async (transactionClient) => {
        const business = await transactionClient.systemBusiness.create({
            data: payload,
        });

        await transactionClient.activityLog.create({
            data: {
                activityName: "System Business Created",
                activityTitle: `A new business named "${business.businessName}" has been created.`,
                activityType: "CREATE",
                createdById: payload.createdById || null,
            }
        });

        return business;
    });

    return result;
};

const getAllBusinessesService = async (query = {}) => {
    const queryBuilder = new QueryBuilder(query)
        .search(["businessName", "ownerName", "ownerEmail"])
        .filter()
        .sort()
        .paginate()
        .fields();

    const queryParams = queryBuilder.build();

    if (!queryParams.select) {
        queryParams.include = {
            createdBy: {
                select: {
                    id: true,
                    email: true,
                    firstName: true,
                    lastName: true,
                }
            }
        };
    }

    const result = await prisma.systemBusiness.findMany(queryParams);
    const total = await prisma.systemBusiness.count({ where: queryBuilder.where });

    // Exclude fields
    result.forEach((item) => {
        delete item.createdById;
        delete item.planId;
    });

    return {
        meta: queryBuilder.getMeta(total),
        data: result,
    };
};

const getBusinessByIdService = async (id, query = {}) => {
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
            }
        };
    }

    const result = await prisma.systemBusiness.findUnique(findArgs);
    
    if (!result) {
        throw new DevBuildError("Business not found", StatusCodes.NOT_FOUND);
    }

    delete result.createdById;
    delete result.planId;
    
    return result;
};

const updateBusinessService = async (id, payload) => {
    const isExist = await prisma.systemBusiness.findUnique({
        where: { id },
    });

    if (!isExist) {
        throw new DevBuildError("Business not found", StatusCodes.NOT_FOUND);
    }

    const result = await prisma.systemBusiness.update({
        where: { id },
        data: payload,
    });
    return result;
};

const deleteBusinessService = async (id) => {
    const isExist = await prisma.systemBusiness.findUnique({
        where: { id },
    });

    if (!isExist) {
        throw new DevBuildError("Business not found", StatusCodes.NOT_FOUND);
    }

    const result = await prisma.systemBusiness.delete({
        where: { id },
    });
    return result;
};

export const BusinessService = {
    createBusinessService,
    getAllBusinessesService,
    getBusinessByIdService,
    updateBusinessService,
    deleteBusinessService,
};
