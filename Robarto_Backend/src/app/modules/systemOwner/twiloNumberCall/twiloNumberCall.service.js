import axios from "axios";
import { StatusCodes } from "http-status-codes";
import { envVars } from "../../../config/env.js";
import DevBuildError from "../../../lib/DevBuildError.js";
import prisma from "../../../prisma/client.js";

const setupTwilioService = async (payload) => {
  const {
    twilio_sid,
    twilio_auth_token,
    twilio_number,
    transfer_number,
    assistant_id,
    vapiId,
  } = payload;

  const targetAssistantId = vapiId || assistant_id;

  if (!twilio_sid || !twilio_auth_token || !twilio_number || !transfer_number || !targetAssistantId) {
    throw new DevBuildError(
      "All fields (twilio_sid, twilio_auth_token, twilio_number, transfer_number, vapiId or assistant_id) are required",
      StatusCodes.BAD_REQUEST
    );
  }

  const vapiApiKey = envVars.VAPI_API_KEY;
  if (!vapiApiKey) {
    throw new DevBuildError(
      "VAPI_API_KEY is not defined in backend environment variables",
      StatusCodes.INTERNAL_SERVER_ERROR
    );
  }

  const vapiHeaders = {
    Authorization: `Bearer ${vapiApiKey}`,
    "Content-Type": "application/json",
  };

  // 1. Fetch assistant details to get existing tools
  let currentModel = {};
  try {
    console.log(`[Vapi] Fetching assistant details for assistant_id: ${targetAssistantId}`);
    const assistantResponse = await axios.get(`https://api.vapi.ai/assistant/${targetAssistantId}`, {
      headers: vapiHeaders,
    });
    currentModel = assistantResponse.data?.model || {};
    console.log(`[Vapi] Current assistant model config:`, currentModel);
  } catch (error) {
    console.error(
      `[Vapi] Error fetching assistant ${targetAssistantId}:`,
      error.response?.data || error.message
    );
    throw new DevBuildError(
      `Failed to fetch assistant details from Vapi: ${
        error.response?.data?.message || error.message
      }`,
      error.response?.status || StatusCodes.BAD_REQUEST
    );
  }

  // 2. Create the transferCall tool
  let createdTool = null;
  try {
    console.log(`[Vapi] Creating transferCall tool pointing to: ${transfer_number}`);
    const toolPayload = {
      type: "transferCall",
      destinations: [
        {
          type: "number",
          number: transfer_number,
          message: "Forwarding your call now.",
        },
      ],
    };

    const toolResponse = await axios.post(`https://api.vapi.ai/tool`, toolPayload, {
      headers: vapiHeaders,
    });
    createdTool = toolResponse.data;
    console.log(`[Vapi] Created transferCall tool with ID: ${createdTool.id}`);
  } catch (error) {
    console.error(
      `[Vapi] Error creating transferCall tool:`,
      error.response?.data || error.message
    );
    throw new DevBuildError(
      `Failed to create transferCall tool on Vapi: ${
        error.response?.data?.message || error.message
      }`,
      error.response?.status || StatusCodes.BAD_REQUEST
    );
  }

  // 3. Attach the tool to the assistant
  try {
    const existingToolIds = currentModel.toolIds || [];
    const updatedToolIds = [...new Set([...existingToolIds, createdTool.id])];
    const updatedModel = {
      ...currentModel,
      toolIds: updatedToolIds,
    };
    console.log(
      `[Vapi] Updating assistant ${targetAssistantId} with new model config:`,
      updatedModel
    );
    await axios.patch(
      `https://api.vapi.ai/assistant/${targetAssistantId}`,
      { model: updatedModel },
      { headers: vapiHeaders }
    );
    console.log(`[Vapi] Assistant tools updated successfully.`);
  } catch (error) {
    console.error(
      `[Vapi] Error updating assistant tools:`,
      error.response?.data || error.message
    );
    throw new DevBuildError(
      `Failed to attach transferCall tool to assistant: ${
        error.response?.data?.message || error.message
      }`,
      error.response?.status || StatusCodes.BAD_REQUEST
    );
  }

  // 4. Import/setup Twilio number
  let importedPhoneNumber = null;
  try {
    console.log(`[Vapi] Importing Twilio number ${twilio_number} to Vapi...`);
    const phoneNumberPayload = {
      provider: "twilio",
      number: twilio_number,
      twilioAccountSid: twilio_sid,
      twilioAuthToken: twilio_auth_token,
      assistantId: targetAssistantId,
      name: `Twilio ${twilio_number}`,
    };

    const phoneResponse = await axios.post(`https://api.vapi.ai/phone-number`, phoneNumberPayload, {
      headers: vapiHeaders,
    });
    importedPhoneNumber = phoneResponse.data;
    console.log(`[Vapi] Twilio number imported successfully. ID: ${importedPhoneNumber.id}`);
  } catch (error) {
    console.error(
      `[Vapi] Error importing Twilio number:`,
      error.response?.data || error.message
    );

    const errMsg = error.response?.data?.message || "";
    const isConflict =
      errMsg.toLowerCase().includes("already exists") ||
      errMsg.toLowerCase().includes("conflict") ||
      errMsg.toLowerCase().includes("existing phone number") ||
      errMsg.toLowerCase().includes("identical") ||
      error.response?.status === 409;

    if (isConflict) {
      console.log(`[Vapi] Phone number might already exist. Attempting to locate and update it...`);
      try {
        const listResponse = await axios.get(`https://api.vapi.ai/phone-number`, {
          headers: vapiHeaders,
        });
        const numbers = listResponse.data || [];
        const matchedNumber = numbers.find((n) => n.number === twilio_number);
        if (matchedNumber) {
          console.log(
            `[Vapi] Found existing phone number with ID: ${matchedNumber.id}. Binding to assistant...`
          );
          const patchResponse = await axios.patch(
            `https://api.vapi.ai/phone-number/${matchedNumber.id}`,
            { assistantId: targetAssistantId },
            { headers: vapiHeaders }
          );
          importedPhoneNumber = patchResponse.data;
          console.log(`[Vapi] Existing phone number successfully bound to assistant.`);
        } else {
          throw error;
        }
      } catch (fallbackError) {
        console.error(
          `[Vapi] Fallback failed:`,
          fallbackError.response?.data || fallbackError.message
        );
        throw new DevBuildError(
          `Failed to setup Twilio number (conflict, fallback failed): ${
            error.response?.data?.message || error.message
          }`,
          error.response?.status || StatusCodes.BAD_REQUEST
        );
      }
    } else {
      throw new DevBuildError(
        `Failed to import Twilio number: ${error.response?.data?.message || error.message}`,
        error.response?.status || StatusCodes.BAD_REQUEST
      );
    }
  }

  // Save the full response in the agent's metadata in the database
  try {
    const existingAgent = await prisma.agent.findFirst({
      where: { vapiId: targetAssistantId },
    });

    if (existingAgent) {
      const existingMetadata = typeof existingAgent.metadata === "object" && existingAgent.metadata !== null
        ? existingAgent.metadata
        : {};

      await prisma.agent.update({
        where: { id: existingAgent.id },
        data: {
          metadata: {
            ...existingMetadata,
            twilioResponse: {
              tool: createdTool,
              phoneNumber: importedPhoneNumber,
            },
          },
        },
      });
      console.log(`[Database] Successfully saved Twilio response inside Agent metadata for assistant: ${targetAssistantId}`);
    } else {
      console.warn(`[Database] Agent with vapiId ${targetAssistantId} not found in database. Skipping metadata save.`);
    }
  } catch (dbError) {
    console.error(`[Database] Error updating Agent metadata with Twilio setup details:`, dbError);
  }

  return {
    success: true,
    message: "Twilio number setup and transfer routing configured successfully",
    data: {
      tool: createdTool,
      phoneNumber: importedPhoneNumber,
    },
  };
};

const teardownTelephonyService = async (payload) => {
  const { phone_number_id, transfer_tool_id, assistant_id } = payload;

  if (!phone_number_id && !transfer_tool_id) {
    throw new DevBuildError(
      "Either phone_number_id or transfer_tool_id must be provided",
      StatusCodes.BAD_REQUEST
    );
  }

  const voiceAgentApi = envVars.VOICE_AGENT_API;
  if (!voiceAgentApi) {
    throw new DevBuildError(
      "VOICE_AGENT_API is not defined in environment variables",
      StatusCodes.INTERNAL_SERVER_ERROR
    );
  }

  let apiResponse = null;
  try {
    console.log(`[Voice Agent API] Calling teardown telephony endpoint at: ${voiceAgentApi}/api/telephony/teardown`);
    const response = await axios.request({
      method: "delete",
      url: `${voiceAgentApi}/api/telephony/teardown`,
      data: {
        phone_number_id,
        transfer_tool_id,
        assistant_id,
      },
    });
    apiResponse = response.data;
    console.log("[Voice Agent API] Teardown Telephony Response:", apiResponse);
  } catch (error) {
    console.error(
      "[Voice Agent API] Error during teardown telephony:",
      error.response?.data || error.message
    );
    throw new DevBuildError(
      error.response?.data?.detail || error.response?.data?.message || "Failed to teardown telephony on external voice agent API",
      error.response?.status || StatusCodes.BAD_REQUEST
    );
  }

  // Update Agent's metadata in database to remove twilioResponse
  const targetAssistantId = assistant_id;
  if (targetAssistantId) {
    try {
      const existingAgent = await prisma.agent.findFirst({
        where: { vapiId: targetAssistantId },
      });

      if (existingAgent) {
        const existingMetadata = typeof existingAgent.metadata === "object" && existingAgent.metadata !== null
          ? { ...existingAgent.metadata }
          : {};

        if (existingMetadata.twilioResponse) {
          delete existingMetadata.twilioResponse;
        }

        await prisma.agent.update({
          where: { id: existingAgent.id },
          data: {
            metadata: existingMetadata,
          },
        });
        console.log(`[Database] Successfully cleared twilioResponse from Agent metadata for assistant: ${targetAssistantId}`);
      }
    } catch (dbError) {
      console.error(`[Database] Error clearing Twilio response from Agent metadata:`, dbError);
    }
  }

  return {
    success: true,
    message: "Telephony resources torn down successfully",
    data: apiResponse,
  };
};

export const TwiloNumberCallService = {
  setupTwilioService,
  teardownTelephonyService,
};
