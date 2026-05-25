import { z } from "zod";

const createPricingSchema = z.object({
    body: z.object({
        ruleName: z.string({ required_error: "Rule name is required" }),
        type: z.string().optional(),
        configuration: z.string().optional(),
        status: z.boolean().optional(),
    }),
});

const updatePricingSchema = z.object({
    body: z.object({
        ruleName: z.string().optional(),
        type: z.string().optional(),
        configuration: z.string().optional(),
        status: z.boolean().optional(),
    }),
});

export const PricingValidation = {
    createPricingSchema,
    updatePricingSchema,
};
