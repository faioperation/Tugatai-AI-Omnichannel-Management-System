import { SystemStaffService } from "./systemStaff.service.js";

const createStaff = async (req, res) => {
  try {
    const result = await SystemStaffService.createStaff(req.body);
    return res.status(201).json({
      success: true,
      message: "System Staff user created successfully",
      data: result,
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      message: error.message || "Failed to create System Staff user",
    });
  }
};

const getAllStaff = async (req, res) => {
  try {
    const result = await SystemStaffService.getAllStaff();
    return res.status(200).json({
      success: true,
      message: "System Staff users fetched successfully",
      data: result,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch System Staff users",
    });
  }
};

const getStaffById = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await SystemStaffService.getStaffById(id);
    return res.status(200).json({
      success: true,
      message: "System Staff user fetched successfully",
      data: result,
    });
  } catch (error) {
    return res.status(404).json({
      success: false,
      message: error.message || "System Staff user not found",
    });
  }
};

const updateStaff = async (req, res) => {
  try {
    const { id } = req.params;
    const result = await SystemStaffService.updateStaff(id, req.body);
    return res.status(200).json({
      success: true,
      message: "System Staff user updated successfully",
      data: result,
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      message: error.message || "Failed to update System Staff user",
    });
  }
};

const updateStaffPermissions = async (req, res) => {
  try {
    const { id } = req.params;
    const { permissions } = req.body;
    const result = await SystemStaffService.updateStaffPermissions(id, permissions);
    return res.status(200).json({
      success: true,
      message: "System Staff permissions updated successfully",
      data: result,
    });
  } catch (error) {
    return res.status(400).json({
      success: false,
      message: error.message || "Failed to update System Staff permissions",
    });
  }
};

const getAllAssignablePermissions = async (req, res) => {
  try {
    const result = await SystemStaffService.getAllAssignablePermissions();
    return res.status(200).json({
      success: true,
      message: "Assignable permissions fetched successfully",
      data: result,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch assignable permissions",
    });
  }
};

const getMyPermissions = async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await SystemStaffService.getMyPermissions(userId);
    return res.status(200).json({
      success: true,
      message: "My permissions fetched successfully",
      data: result,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch permissions",
    });
  }
};

export const SystemStaffController = {
  createStaff,
  getAllStaff,
  getStaffById,
  updateStaff,
  updateStaffPermissions,
  getAllAssignablePermissions,
  getMyPermissions,
};
