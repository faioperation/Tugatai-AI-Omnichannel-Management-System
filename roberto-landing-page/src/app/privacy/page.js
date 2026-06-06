import React from "react";
import { IoArrowBack } from "react-icons/io5";
import { MdOutlineEmail, MdOutlinePhone } from "react-icons/md";
import Link from "next/link";

const Privacy = () => {
  return (
    <div className="min-h-screen bg-black">
      {/* Top Info Bar */}
      <div className="w-full border-b border-[#DBDBDB] px-4 sm:px-8 py-3 flex items-center justify-between text-xs sm:text-sm text-[#DBDBDB]">
        <Link
          href="/"
          className="flex items-center justify-center w-8 h-8 sm:w-9 sm:h-9 rounded-full border border-[#DBDBDB] hover:bg-gray-100 transition-colors flex-shrink-0 group"
        >
          <IoArrowBack className="w-4 h-4 text-[#DBDBDB] group-hover:text-black" />
        </Link>

        <span className="text-[#DBDBDB]">
          Hello!! Welcome to Tufatai Cargo logistics
        </span>

        <div className="flex items-center gap-2 sm:gap-6">
          <span className="flex items-center gap-1 text-[#DBDBDB]">
            <MdOutlineEmail className="w-4 h-4" />
            <span className="">tugatai@gmail.com</span>
          </span>
          <span className="flex items-center gap-1 text-[#DBDBDB]">
            <MdOutlinePhone className="w-4 h-4" />
            <span className="">+757 699-4478</span>
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="w-full px-4 sm:px-8 pt-12 pb-24  mx-auto">
        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold bg-gradient-to-r from-[#E9D4FF] to-[#FFFFFF] bg-clip-text text-transparent mb-6">
          Privacy Policy
        </h1>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We value your privacy and are committed to protecting your personal
          and business data.This privacy policy explains how we collect, use,
          and safeguard your information when you use our platform.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We may collect:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-12 space-y-2 ml-2 sm:ml-4">
          <li>Account information</li>
          <li> Business data provided by users</li>
          <li>Messages and conversations processed by the AI system</li>
          <li>Usage and analytics data</li>
        </ul>

        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold bg-gradient-to-r from-[#E9D4FF] to-[#FFFFFF] bg-clip-text text-transparent mb-6">
          Data Sharing and Disclosure
        </h1>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We do not sell your personal data.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We only share data when necessary to:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-12 space-y-2 ml-2 sm:ml-4">
          <li>Provide Services</li>
          <li>Comply with legal obligations </li>
        </ul>
      </div>
    </div>
  );
};

export default Privacy;
