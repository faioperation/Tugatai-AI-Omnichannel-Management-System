import { StatusCodes } from "http-status-codes";
import { sendResponse } from "../../../utils/sendResponse.js";
import { AgentService } from "./agentManagement.service.js";
import { envVars } from "../../../config/env.js";

const formatAgentResponse = (agent) => {
    if (!agent) return null;
    return {
        ...agent,
        rulesFile: agent.rulesFile ? `${envVars.BACKEND_URL}${agent.rulesFile}` : null,
        productFile: agent.productFile ? `${envVars.BACKEND_URL}${agent.productFile}` : null
    };
};

const createAgent = async (req, res, next) => {
    try {
        const { businessId, agentName, branchId } = req.body;
        const rulesFiles = req.files && req.files["rules_file"] ? req.files["rules_file"] : [];
        const productFiles = req.files && (req.files["product_file"] || req.files["productFile"]) ? (req.files["product_file"] || req.files["productFile"]) : [];
        const productFile = productFiles[0] || null;

        const result = await AgentService.createAgentService(businessId, agentName, rulesFiles, productFile, branchId);

        sendResponse(res, {
            success: true,
            message: "Agent created successfully",
            statusCode: StatusCodes.CREATED,
            data: formatAgentResponse(result),
        });
    } catch (error) {
        next(error);
    }
};

const getAllAgents = async (req, res, next) => {
    try {
        const result = await AgentService.getAllAgentsService(req.query);

        sendResponse(res, {
            success: true,
            message: "Agents retrieved successfully",
            statusCode: StatusCodes.OK,
            data: result.data.map(formatAgentResponse),
            meta: result.meta,
        });
    } catch (error) {
        next(error);
    }
};

const getAgentById = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await AgentService.getAgentByIdService(id, req.query);

        sendResponse(res, {
            success: true,
            message: "Agent retrieved successfully",
            statusCode: StatusCodes.OK,
            data: formatAgentResponse(result),
        });
    } catch (error) {
        next(error);
    }
};

const updateAgent = async (req, res, next) => {
    try {
        const { id } = req.params;
        const payload = req.body;
        const rulesFiles = req.files && req.files["rules_file"] ? req.files["rules_file"] : [];
        const productFiles = req.files && (req.files["product_file"] || req.files["productFile"]) ? (req.files["product_file"] || req.files["productFile"]) : [];
        const productFile = productFiles[0] || null;

        const result = await AgentService.updateAgentService(id, payload, rulesFiles, productFile);

        sendResponse(res, {
            success: true,
            message: "Agent updated successfully",
            statusCode: StatusCodes.OK,
            data: formatAgentResponse(result),
        });
    } catch (error) {
        next(error);
    }
};

const updateProductFile = async (req, res, next) => {
    try {
        const { id } = req.params;
        const productFiles = req.files && (req.files["product_file"] || req.files["productFile"]) ? (req.files["product_file"] || req.files["productFile"]) : [];
        const productFile = productFiles[0] || null;

        const result = await AgentService.updateProductFileService(id, productFile);

        sendResponse(res, {
            success: true,
            message: "Agent product file updated successfully",
            statusCode: StatusCodes.OK,
            data: formatAgentResponse(result),
        });
    } catch (error) {
        next(error);
    }
};

const deleteAgent = async (req, res, next) => {
    try {
        const { id } = req.params;
        const result = await AgentService.deleteAgentService(id);

        sendResponse(res, {
            success: true,
            message: "Agent deleted successfully",
            statusCode: StatusCodes.OK,
            data: formatAgentResponse(result),
        });
    } catch (error) {
        next(error);
    }
};

export const AgentController = {
    createAgent,
    getAllAgents,
    getAgentById,
    updateAgent,
    updateProductFile,
    deleteAgent,
};
