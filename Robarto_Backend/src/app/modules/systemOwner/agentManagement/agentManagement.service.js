import prisma from "../../../prisma/client.js";
import DevBuildError from "../../../lib/DevBuildError.js";
import { StatusCodes } from "http-status-codes";
import { QueryBuilder } from "../../../utils/QueryBuilder.js";
import { envVars } from "../../../config/env.js";
import { extractTextFromFile } from "../../../utils/textExtractor.js";
import axios from "axios";
import fs from "fs";
import path from "path";

/**
 * Helper to call the external voice agent creation API
 */
const callExternalCreateAgent = async (agentName, file, productFile = null) => {
    const apiBaseUrl = envVars.VOICE_AGENT_API;
    if (!apiBaseUrl) {
        throw new DevBuildError("VOICE_AGENT_API is not defined in environment variables", StatusCodes.INTERNAL_SERVER_ERROR);
    }

    try {
        const fileBuffer = fs.readFileSync(file.path);
        const blob = new Blob([fileBuffer], { type: file.mimetype });

        const formData = new FormData();
        formData.append("business_id", agentName);
        formData.append("rules_file", blob, file.originalname);

        if (productFile) {
            const productFileBuffer = fs.readFileSync(productFile.path);
            const productBlob = new Blob([productFileBuffer], { type: productFile.mimetype });
            formData.append("product_file", productBlob, productFile.originalname);
        }

        console.log(`[Voice Agent API] Calling create endpoint at: ${apiBaseUrl}/api/agents/create`);
        const response = await axios.post(`${apiBaseUrl}/api/agents/create`, formData, {
            headers: {
                "Content-Type": "multipart/form-data",
            },
        });

        console.log("[Voice Agent API] Create Response:", response.data);
        return response.data;
    } catch (error) {
        console.error(
            "[Voice Agent API] Error during agent creation:",
            error.response?.data ? JSON.stringify(error.response.data, null, 2) : error.message
        );
        throw new DevBuildError(
            error.response?.data?.message || error.response?.data?.detail || "Failed to create agent on external voice agent API",
            error.response?.status || StatusCodes.INTERNAL_SERVER_ERROR
        );
    }
};

/**
 * Helper to call the external update product file API
 */
const callExternalUpdateProductFile = async (assistantId, productFile) => {
    const apiBaseUrl = envVars.VOICE_AGENT_API;
    if (!apiBaseUrl) {
        throw new DevBuildError("VOICE_AGENT_API is not defined in environment variables", StatusCodes.INTERNAL_SERVER_ERROR);
    }

    try {
        const fileBuffer = fs.readFileSync(productFile.path);
        const blob = new Blob([fileBuffer], { type: productFile.mimetype });

        const formData = new FormData();
        formData.append("product_file", blob, productFile.originalname);

        console.log(`[Voice Agent API] Calling update product file endpoint at: ${apiBaseUrl}/api/agents/${assistantId}/product-file`);
        const response = await axios.put(`${apiBaseUrl}/api/agents/${assistantId}/product-file`, formData, {
            headers: {
                "Content-Type": "multipart/form-data",
            },
        });

        console.log("[Voice Agent API] Update Product File Response:", response.data);
        return response.data;
    } catch (error) {
        console.error(
            "[Voice Agent API] Error during updating product file:",
            error.response?.data ? JSON.stringify(error.response.data, null, 2) : error.message
        );
        throw new DevBuildError(
            error.response?.data?.message || error.response?.data?.detail || "Failed to update product file on external voice agent API",
            error.response?.status || StatusCodes.INTERNAL_SERVER_ERROR
        );
    }
};

/**
 * Helper to call the external delete agent API
 */
const callExternalDeleteAgent = async (assistantId) => {
    const apiBaseUrl = envVars.VOICE_AGENT_API;
    if (!apiBaseUrl) {
        throw new DevBuildError("VOICE_AGENT_API is not defined in environment variables", StatusCodes.INTERNAL_SERVER_ERROR);
    }

    try {
        console.log(`[Voice Agent API] Calling delete agent endpoint at: ${apiBaseUrl}/api/assistant/${assistantId}`);
        const response = await axios.delete(`${apiBaseUrl}/api/assistant/${assistantId}`);
        console.log("[Voice Agent API] Delete Agent Response:", response.data);
        return response.data;
    } catch (error) {
        console.error(
            "[Voice Agent API] Error during deleting agent:",
            error.response?.data ? JSON.stringify(error.response.data, null, 2) : error.message
        );
        throw new DevBuildError(
            error.response?.data?.message || error.response?.data?.detail || "Failed to delete agent on external voice agent API",
            error.response?.status || StatusCodes.INTERNAL_SERVER_ERROR
        );
    }
};

/**
 * Helper to compile/merge multiple rules files into one
 */
const mergeRulesFiles = async (files) => {
    let combinedTextParts = [];
    for (const file of files) {
        const text = await extractTextFromFile(file.path, file.mimetype);
        if (text) {
            combinedTextParts.push(text);
        }
    }
    const combinedText = combinedTextParts.join("\n\n").trim();
    
    // Write combined text into a merged file in uploads/agents
    const uploadPath = path.join(process.cwd(), "uploads", "agents");
    if (!fs.existsSync(uploadPath)) {
        fs.mkdirSync(uploadPath, { recursive: true });
    }
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const filename = `merged-rules-${uniqueSuffix}.txt`;
    const mergedFilePath = path.join(uploadPath, filename);
    
    fs.writeFileSync(mergedFilePath, combinedText, "utf-8");
    
    // Cleanup original uploaded files since they are merged
    for (const file of files) {
        fs.unlink(file.path, (err) => {
            if (err) console.error("[Service] Error deleting original file during merge:", err.message);
        });
    }

    return {
        path: mergedFilePath,
        filename,
        originalname: "merged-rules.txt",
        mimetype: "text/plain"
    };
};

const createAgentService = async (businessId, agentName, files, productFile, branchId) => {
    const targetBranchId = (branchId === "null" || branchId === "") ? null : branchId;
    if (targetBranchId) {
        const existingAgent = await prisma.agent.findFirst({
            where: { branchId: targetBranchId },
        });
        if (existingAgent) {
            throw new DevBuildError("An agent already exists for this branch", StatusCodes.BAD_REQUEST);
        }
    }

    if (!files || files.length === 0) {
        throw new DevBuildError("rules_file is required for agent creation", StatusCodes.BAD_REQUEST);
    }

    let fileToUse;
    if (files.length === 1) {
        fileToUse = files[0];
    } else {
        fileToUse = await mergeRulesFiles(files);
    }

    // Call external Voice Agent API
    const externalResponse = await callExternalCreateAgent(agentName, fileToUse, productFile);
    const vapiId = externalResponse?.assistant_id || externalResponse?.id || externalResponse?.vapiId || externalResponse?.assistantId || null;

    const relativePath = `/uploads/agents/${fileToUse.filename}`;
    const relativeProductPath = productFile ? `/uploads/agents/${productFile.filename}` : null;

    const result = await prisma.agent.create({
        data: {
            businessId,
            branchId: targetBranchId,
            rulesFile: relativePath,
            productFile: relativeProductPath,
            vapiId,
            metadata: externalResponse ? { ...externalResponse, agentName } : { agentName },
        },
    });

    return result;
};

const getAllAgentsService = async (query = {}) => {
    const queryBuilder = new QueryBuilder(query)
        .search(["businessId", "vapiId"])
        .filter()
        .sort("-createdAt")
        .paginate()
        .fields();

    const queryParams = queryBuilder.build();

    const result = await prisma.agent.findMany(queryParams);
    const total = await prisma.agent.count({ where: queryBuilder.where });

    return {
        meta: queryBuilder.getMeta(total),
        data: result,
    };
};

const getAgentByIdService = async (id, query = {}) => {
    const queryBuilder = new QueryBuilder(query).fields();
    const queryParams = queryBuilder.build();

    const findArgs = {
        where: { id },
    };

    if (queryParams.select) {
        findArgs.select = queryParams.select;
    }

    const result = await prisma.agent.findUnique(findArgs);
    if (!result) {
        throw new DevBuildError("Agent not found", StatusCodes.NOT_FOUND);
    }

    return result;
};

const updateAgentService = async (id, payload, files, productFile) => {
    const existingAgent = await prisma.agent.findUnique({
        where: { id },
    });

    if (!existingAgent) {
        throw new DevBuildError("Agent not found", StatusCodes.NOT_FOUND);
    }

    const targetBranchId = (payload.branchId === "null" || payload.branchId === "") ? null : payload.branchId;
    if (targetBranchId && targetBranchId !== existingAgent.branchId) {
        const existingBranchAgent = await prisma.agent.findFirst({
            where: { branchId: targetBranchId },
        });
        if (existingBranchAgent) {
            throw new DevBuildError("An agent already exists for this branch", StatusCodes.BAD_REQUEST);
        }
    }

    const updateData = {};
    if (payload.businessId) {
        updateData.businessId = payload.businessId;
    }
    if (payload.branchId !== undefined) {
        updateData.branchId = targetBranchId;
    }

    const existingMetadata = existingAgent.metadata || {};
    let updatedMetadata = { ...existingMetadata };
    if (payload.agentName) {
        updatedMetadata.agentName = payload.agentName;
        updateData.metadata = updatedMetadata;
    }

    if (files && files.length > 0) {
        let fileToUse;
        if (files.length === 1) {
            fileToUse = files[0];
        } else {
            fileToUse = await mergeRulesFiles(files);
        }

        const agentNameForApi = payload.agentName || existingMetadata.agentName || "";
        const externalResponse = await callExternalCreateAgent(agentNameForApi, fileToUse, productFile);

        updateData.rulesFile = `/uploads/agents/${fileToUse.filename}`;
        updateData.vapiId = externalResponse?.assistant_id || externalResponse?.id || externalResponse?.vapiId || externalResponse?.assistantId || null;
        updateData.metadata = {
            ...updatedMetadata,
            ...(externalResponse || {}),
            agentName: agentNameForApi
        };

        // Optionally delete old local file to save storage
        if (existingAgent.rulesFile) {
            const oldPath = `.${existingAgent.rulesFile}`;
            fs.unlink(oldPath, (err) => {
                if (err) console.error("[Service] Error deleting old rules file:", err.message);
            });
        }
    } else if (productFile) {
        const assistantId = existingAgent.vapiId;
        if (!assistantId) {
            throw new DevBuildError("Assistant ID (vapiId) not found for this agent", StatusCodes.BAD_REQUEST);
        }

        const externalResponse = await callExternalUpdateProductFile(assistantId, productFile);
        updateData.metadata = {
            ...updatedMetadata,
            ...(externalResponse || {}),
        };
    }

    if (productFile) {
        updateData.productFile = `/uploads/agents/${productFile.filename}`;
        if (existingAgent.productFile) {
            const oldProductPath = `.${existingAgent.productFile}`;
            fs.unlink(oldProductPath, (err) => {
                if (err) console.error("[Service] Error deleting old product file:", err.message);
            });
        }
    }

    const result = await prisma.agent.update({
        where: { id },
        data: updateData,
    });

    return result;
};

const updateProductFileService = async (id, productFile) => {
    const existingAgent = await prisma.agent.findUnique({
        where: { id },
    });

    if (!existingAgent) {
        throw new DevBuildError("Agent not found", StatusCodes.NOT_FOUND);
    }

    const assistantId = existingAgent.vapiId;
    if (!assistantId) {
        throw new DevBuildError("Assistant ID (vapiId) not found for this agent", StatusCodes.BAD_REQUEST);
    }

    if (!productFile) {
        throw new DevBuildError("product_file is required", StatusCodes.BAD_REQUEST);
    }

    // Call external voice agent PUT endpoint
    const externalResponse = await callExternalUpdateProductFile(assistantId, productFile);

    const relativeProductPath = `/uploads/agents/${productFile.filename}`;

    // Update in DB
    const result = await prisma.agent.update({
        where: { id },
        data: {
            productFile: relativeProductPath,
            metadata: {
                ...(existingAgent.metadata || {}),
                ...(externalResponse || {}),
            }
        },
    });

    // Optionally delete old product file to save space
    if (existingAgent.productFile) {
        const oldPath = `.${existingAgent.productFile}`;
        fs.unlink(oldPath, (err) => {
            if (err) console.error("[Service] Error deleting old product file:", err.message);
        });
    }

    return result;
};

const deleteAgentService = async (id, payload = {}) => {
    const existingAgent = await prisma.agent.findUnique({
        where: { id },
    });

    if (!existingAgent) {
        throw new DevBuildError("Agent not found", StatusCodes.NOT_FOUND);
    }

    // Check if there is an active Twilio number connected to this agent in metadata
    const metadata = typeof existingAgent.metadata === "object" && existingAgent.metadata !== null
        ? existingAgent.metadata
        : {};
    
    if (metadata.twilioResponse && metadata.twilioResponse.phoneNumber) {
        throw new DevBuildError(
            "An active Twilio phone number is connected to this agent. Please delete/teardown the phone number first before deleting the agent.",
            StatusCodes.BAD_REQUEST
        );
    }

    const assistantId = payload.assistant_id || payload.assistantId || existingAgent.vapiId;

    if (assistantId) {
        try {
            await callExternalDeleteAgent(assistantId);
        } catch (apiError) {
            console.error(`[Service] Failed to delete external agent resources for assistantId ${assistantId}:`, apiError.message);
            throw apiError;
        }
    }

    // Delete local rules file
    if (existingAgent.rulesFile) {
        const filePath = `.${existingAgent.rulesFile}`;
        fs.unlink(filePath, (err) => {
            if (err) console.error("[Service] Error deleting rules file:", err.message);
        });
    }

    // Delete local product file
    if (existingAgent.productFile) {
        const filePath = `.${existingAgent.productFile}`;
        fs.unlink(filePath, (err) => {
            if (err) console.error("[Service] Error deleting product file:", err.message);
        });
    }

    const result = await prisma.agent.delete({
        where: { id },
    });

    return result;
};

export const AgentService = {
    createAgentService,
    getAllAgentsService,
    getAgentByIdService,
    updateAgentService,
    updateProductFileService,
    deleteAgentService,
};
