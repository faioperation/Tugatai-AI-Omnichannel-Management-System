import axios from "axios";
import fs from "fs";
import path from "path";
import { envVars } from "../config/env.js";

const getExtensionFromMimeType = (mimeType) => {
  if (!mimeType) return "";
  const cleanMime = mimeType.split(";")[0].trim().toLowerCase();
  const mapping = {
    "image/jpeg": ".jpg",
    "image/jpg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
    "image/gif": ".gif",
    "audio/mpeg": ".mp3",
    "audio/mp3": ".mp3",
    "audio/ogg": ".ogg",
    "audio/wav": ".wav",
    "audio/webm": ".webm",
    "audio/aac": ".aac",
    "audio/mp4": ".m4a",
    "video/mp4": ".mp4",
    "video/mpeg": ".mp4",
    "video/ogg": ".ogv",
    "video/webm": ".webm",
    "application/pdf": ".pdf",
    "application/msword": ".doc",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": ".docx",
    "application/vnd.ms-excel": ".xls",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": ".xlsx",
    "application/zip": ".zip",
    "text/plain": ".txt",
  };
  return mapping[cleanMime] || "";
};

export const downloadAndSaveMedia = async (url, folderName, prefix, headers = {}) => {
  try {
    const response = await axios({
      method: "get",
      url,
      headers,
      responseType: "stream",
      timeout: 30000,
    });

    const contentType = response.headers["content-type"];
    const ext = getExtensionFromMimeType(contentType) || "";
    
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const filename = `${prefix}-${uniqueSuffix}${ext}`;
    
    const uploadPath = path.join("uploads", folderName);
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
    
    const filePath = path.join(uploadPath, filename);
    const writer = fs.createWriteStream(filePath);
    
    response.data.pipe(writer);
    
    await new Promise((resolve, reject) => {
      writer.on("finish", resolve);
      writer.on("error", reject);
    });

    let backendUrl = envVars.BACKEND_URL || "";
    if (backendUrl.endsWith("/")) {
      backendUrl = backendUrl.slice(0, -1);
    }
    const publicUrl = `${backendUrl}/uploads/${folderName}/${filename}`;
    
    return {
      success: true,
      filename,
      filePath,
      publicUrl,
    };
  } catch (error) {
    console.error(`[mediaDownloader] Error downloading from ${url}:`, error.message);
    return {
      success: false,
      error: error.message,
    };
  }
};
