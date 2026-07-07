import fs from "fs/promises";
import path from "path";
import { createRequire } from "module";
import mammoth from "mammoth";
import xlsx from "xlsx";

const require = createRequire(import.meta.url);
const { PDFParse } = require("pdf-parse");

export const extractTextFromFile = async (filePath, mimetype) => {
  try {
    const fullPath = path.resolve(filePath);
    
    // Check if file exists
    await fs.access(fullPath);
    
    // TXT file extraction
    if (mimetype === "text/plain" || filePath.endsWith(".txt")) {
      const content = await fs.readFile(fullPath, "utf-8");
      return content.trim();
    }
    
    // PDF file extraction
    if (mimetype === "application/pdf" || filePath.endsWith(".pdf")) {
      const dataBuffer = await fs.readFile(fullPath);
      const parser = new PDFParse({ data: dataBuffer });
      const result = await parser.getText();
      await parser.destroy();
      return (result.text || "").trim();
    }
    
    // DOCX Word file extraction
    if (
      mimetype === "application/vnd.openxmlformats-officedocument.wordprocessingml.document" || 
      filePath.endsWith(".docx")
    ) {
      const dataBuffer = await fs.readFile(fullPath);
      const result = await mammoth.extractRawText({ buffer: dataBuffer });
      return (result.value || "").trim();
    }

    // Excel file extraction
    if (
      mimetype === "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ||
      mimetype === "application/vnd.ms-excel" ||
      filePath.endsWith(".xlsx") ||
      filePath.endsWith(".xls")
    ) {
      const workbook = xlsx.readFile(fullPath);
      const textParts = [];
      workbook.SheetNames.forEach(sheetName => {
        const worksheet = workbook.Sheets[sheetName];
        const csvData = xlsx.utils.sheet_to_csv(worksheet);
        if (csvData.trim()) {
          textParts.push(`Sheet: ${sheetName}\n${csvData}`);
        }
      });
      return textParts.join("\n\n").trim();
    }
    
    console.warn(`[TextExtractor] Unsupported file type for text extraction: ${mimetype} (${filePath})`);
    return "";
  } catch (error) {
    console.error(`[TextExtractor] Error extracting text from file ${filePath}:`, error.message);
    return "";
  }
};

export const extractExcelData = async (filePath) => {
  try {
    const fullPath = path.resolve(filePath);
    const workbook = xlsx.readFile(fullPath);
    const sheetsData = {};
    
    workbook.SheetNames.forEach(sheetName => {
      const worksheet = workbook.Sheets[sheetName];
      const jsonData = xlsx.utils.sheet_to_json(worksheet);
      sheetsData[sheetName] = jsonData;
    });
    
    return sheetsData;
  } catch (error) {
    console.error(`[TextExtractor] Error parsing Excel to JSON ${filePath}:`, error.message);
    return null;
  }
};
