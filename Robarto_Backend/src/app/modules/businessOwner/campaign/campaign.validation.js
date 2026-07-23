import { z } from "zod";

const createCampaignSchema = z.object({
    body: z.preprocess((val) => {
        if (typeof val === "object" && val !== null) {
            const cleaned = {};
            for (const [key, value] of Object.entries(val)) {
                cleaned[key.trim()] = value;
            }
            return cleaned;
        }
        return val;
    }, z.object({
        title: z.string({ required_error: "Title is required" }),
        selectedPeople: z.union([
            z.string(),
            z.array(z.string())
        ]).optional()
        .transform((val) => (val === undefined ? [] : Array.isArray(val) ? val : [val])),
        productTypes: z.union([
            z.string(),
            z.array(z.string())
        ]).optional()
        .transform((val) => (val === undefined ? [] : Array.isArray(val) ? val : [val])),
        countries: z.union([
            z.string(),
            z.array(z.string())
        ]).optional()
        .transform((val) => (val === undefined ? [] : Array.isArray(val) ? val : [val])),
        scheduledTime: z.string().optional(),
        scheduled_time: z.string().optional(),
        endDate: z.string().optional().nullable(),
        end_date: z.string().optional().nullable(),
        message: z.string({ required_error: "Message is required" }),
        branchId: z.string().uuid().optional().nullable(),
        country: z.string().optional().nullable(),
    }).refine(data => data.scheduledTime || data.scheduled_time, {
        message: "Scheduled time is required",
        path: ["scheduledTime"]
    })),
});

const updateCampaignSchema = z.object({
    body: z.preprocess((val) => {
        if (typeof val === "object" && val !== null) {
            const cleaned = {};
            for (const [key, value] of Object.entries(val)) {
                cleaned[key.trim()] = value;
            }
            return cleaned;
        }
        return val;
    }, z.object({
        title: z.string().optional(),
        selectedPeople: z.union([
            z.string(),
            z.array(z.string())
        ]).optional()
        .transform((val) => (val === undefined ? undefined : Array.isArray(val) ? val : [val])),
        productTypes: z.union([
            z.string(),
            z.array(z.string())
        ]).optional()
        .transform((val) => (val === undefined ? undefined : Array.isArray(val) ? val : [val])),
        countries: z.union([
            z.string(),
            z.array(z.string())
        ]).optional()
        .transform((val) => (val === undefined ? undefined : Array.isArray(val) ? val : [val])),
        scheduledTime: z.string().optional(),
        scheduled_time: z.string().optional(),
        endDate: z.string().optional().nullable(),
        end_date: z.string().optional().nullable(),
        message: z.string().optional(),
        branchId: z.string().uuid().optional().nullable(),
        country: z.string().optional().nullable(),
    })),
});

export const CampaignValidation = {
    createCampaignSchema,
    updateCampaignSchema,
};
