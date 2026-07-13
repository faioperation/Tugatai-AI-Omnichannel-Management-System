import prisma from "../../prisma/client.js";
import DevBuildError from "../../lib/DevBuildError.js";
import { StatusCodes } from "http-status-codes";
import { QueryBuilder } from "../../utils/QueryBuilder.js";
import { NotificationService } from "../notification/notification.service.js";

const createDemoBookingService = async (payload) => {
    const result = await prisma.demoBooking.create({
        data: payload,
    });

    // Trigger notification to System Owners
    NotificationService.createAndSendNotification({
        title: "New Demo Booking",
        message: `A new demo booking has been requested by ${result.name} (${result.email}).`,
        type: "DEMO_BOOKING",
    }).catch(err => console.error("Error sending demo booking notification:", err));

    return result;
};

const getAllDemoBookingsService = async (query = {}) => {
    const queryBuilder = new QueryBuilder(query)
        .search(["name", "email", "subject", "description"])
        .filter()
        .sort("-createdAt")
        .paginate()
        .fields();

    const queryParams = queryBuilder.build();

    const [result, total] = await Promise.all([
        prisma.demoBooking.findMany(queryParams),
        prisma.demoBooking.count({ where: queryParams.where }),
    ]);

    return {
        meta: queryBuilder.getMeta(total),
        data: result,
    };
};

const getDemoBookingByIdService = async (id) => {
    const result = await prisma.demoBooking.findUnique({
        where: { id },
    });

    if (!result) {
        throw new DevBuildError("Demo Booking not found", StatusCodes.NOT_FOUND);
    }

    return result;
};

const updateDemoBookingService = async (id, payload) => {
    const isExist = await prisma.demoBooking.findUnique({
        where: { id },
    });

    if (!isExist) {
        throw new DevBuildError("Demo Booking not found", StatusCodes.NOT_FOUND);
    }

    const result = await prisma.demoBooking.update({
        where: { id },
        data: payload,
    });

    return result;
};

const deleteDemoBookingService = async (id) => {
    const isExist = await prisma.demoBooking.findUnique({
        where: { id },
    });

    if (!isExist) {
        throw new DevBuildError("Demo Booking not found", StatusCodes.NOT_FOUND);
    }

    const result = await prisma.demoBooking.delete({
        where: { id },
    });

    return result;
};

export const DemoBookingService = {
    createDemoBookingService,
    getAllDemoBookingsService,
    getDemoBookingByIdService,
    updateDemoBookingService,
    deleteDemoBookingService,
};
