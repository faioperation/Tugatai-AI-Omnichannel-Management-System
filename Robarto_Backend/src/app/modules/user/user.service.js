import { envVars } from "../../config/env.js";
import DevBuildError from "../../lib/DevBuildError.js";
import bcrypt from "bcryptjs";
import { Role } from "../../utils/role.js";

export const UserService = {

  // BASIC FIND METHODS

  findByEmail: async (prisma, email) =>
    prisma.user.findUnique({ where: { email } }),

  findByUsername: async (prisma, username) =>
    prisma.user.findUnique({ where: { username } }),

  findById: async (prisma, id) =>
    prisma.user.findUnique({ where: { id } }),


  // ✅ ONLY USER INFO (NO PROFILE)

  findUserInfoById: async (prisma, id) =>
    prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        profilePicture: true,
        roles: { include: { role: true } },
        userPermissions: { include: { permission: true } },
        isVerified: true,
        createdAt: true,
        updatedAt: true,
      },
    }),


  // UPDATE / DELETE

  update: async (prisma, id, data) =>
    prisma.user.update({
      where: { id },
      data,
    }),

  delete: async (prisma, id) =>
    prisma.user.delete({
      where: { id },
    }),

  deleteUser: async (prisma, id) => {
    try {
      await prisma.userRole.deleteMany({ where: { userId: id } }).catch(() => {});
      await prisma.userPermission.deleteMany({ where: { userId: id } }).catch(() => {});
      await prisma.fCMToken.deleteMany({ where: { userId: id } }).catch(() => {});
      await prisma.notification.deleteMany({ where: { userId: id } }).catch(() => {});
      return await prisma.user.delete({ where: { id } });
    } catch (e) {
      return await prisma.user.update({
        where: { id },
        data: {
          deletedAt: new Date(),
          status: "INACTIVE",
        },
      });
    }
  },

  // USER + FULL PROFILE

  findByIdWithProfile: async (prisma, id) =>
    prisma.user.findUnique({
      where: { id },
    }),

  findAllWithProfile: async (prisma) =>
    prisma.user.findMany({
      where: {
        deletedAt: null,
      },
      orderBy: { createdAt: "desc" },
    }),

  updateAvatar: async (prisma, id, profilePicture) =>
    prisma.user.update({
      where: { id },
      data: { profilePicture },
    }),
};


export const createUserService = async (payload) => {
  const { prisma, email, password, picture, role, ...rest } = payload;

  if (!email || !password) {
    throw new DevBuildError("Email and password are required", 400);
  }

  // Check if user already exists
  const existingUser = await prisma.user.findUnique({
    where: { email },
  });

  if (existingUser) {
    throw new DevBuildError("User already exists", 400);
  }

  // Hash password
  const hashedPassword = await bcrypt.hash(
    password,
    Number(envVars.BCRYPT_SALT_ROUND || 10)
  );

  // Create user
  const { passwordHash: _, ...userWithoutPassword } = await prisma.user.create({
    data: {
      email,
      passwordHash: hashedPassword,
      profilePicture: picture?.url,
      isVerified: false,
      roles: {
        create: {
          role: {
            connect: { name: "CUSTOMER" }
          }
        }
      },
      ...rest,
    },
  });

  return userWithoutPassword;
};



