"use client";
import React, { useState } from "react";
import InputField from "../../component/InputField";
import Dropdown from "../../component/Dropdown";
import Image from "next/image";
import Password from "@/app/component/Password";

const Signup = () => {
  const [activeTab, setActiveTab] = useState(0);

  const tabs = ["Business Info", "Owner Details", "Plan & Settings"];

  const nextStep = () => {
    if (activeTab < 2) setActiveTab(activeTab + 1);
  };

  const prevStep = () => {
    if (activeTab > 0) setActiveTab(activeTab - 1);
  };

  return (
    <div className="min-h-screen flex items-center justify-center py-10 px-4">
      <div className="bg-white rounded-[24px] w-full max-w-[600px] h-[800px] px-2 md:py-7 py-5  md:px-14   shadow-2xl">
        {/* Logo and Header */}
        <div className="flex flex-col items-center mb-8">
          <div className="bg-[#EA2B33] rounded-xl flex items-center justify-center mb-5">
            <Image src={"/logo.png"} alt="logo" width={60} height={100} />
          </div>
          <h1 className="text-[28px] font-medium text-black mb-2 tracking-tight">
            Sign up
          </h1>
          <p className="text-[#5B5B5B] text-[13px] text-center">
            Set up a new business account with all required information
          </p>
        </div>

        {/* Navigation Pills */}
        <div className="bg-[#EDEDED] p-1.5 rounded-full flex justify-between mb-8">
          {tabs.map((tab, index) => (
            <button
              key={index}
              onClick={() => setActiveTab(index)}
              className={`flex-1 text-center py-2 text-sm rounded-full transition-all duration-300 font-bold ${
                activeTab === index ? "bg-white text-black" : "text-[#000000]"
              }`}
            >
              {tab}
            </button>
          ))}
        </div>

        {/* Form Content */}
        <div className=" flex flex-col justify-between">
          <div className="space-y-4">
            {activeTab === 0 && (
              <>
                <InputField
                  label="Business Name"
                  placeholder="Enter business name"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  type={`text`}
                />
                <Dropdown
                  label="Business Type"
                  placeholder="Select type"
                  options={[
                    "Sole Proprietorship",
                    "Partnership",
                    "LLC",
                    "Corporation",
                  ]}
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                />
                <Dropdown
                  label="Select Branch"
                  placeholder="2"
                  options={["1", "2", "3", "4", "5+"]}
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                />

                <div className="flex flex-col w-full gap-2">
                  <label className="font-inter text-[#000000] text-[13px] font-semibold">
                    Description
                  </label>
                  <textarea
                    placeholder="Brief description of the business..."
                    className="border border-[#D1D5DC] outline-none p-3 text-sm text-[#000000] placeholder:text-[#0A0A0A]/50 rounded-xl w-full min-h-[90px] resize-none"
                  ></textarea>
                </div>
              </>
            )}

            {activeTab === 1 && (
              <>
                <InputField
                  label="Owner Name"
                  placeholder="Enter full name"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  type={`text`}
                />
                <InputField
                  label="Email"
                  placeholder="email@example.com"
                  type="email"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                />
                <InputField
                  label="Phone"
                  placeholder="+1 234 567 8900"
                  type="tel"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                />
                

                <Password
                  label="Initial Password"
                  placeholder="Create password"
                  type="password"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                />
              </>
            )}

            {activeTab === 2 && (
              <>
                <Dropdown
                  label="Subscription Plan"
                  placeholder="Basic - $49/mo"
                  options={[
                    "Basic - $49/mo",
                    "Pro - $99/mo",
                    "Enterprise - Custom",
                  ]}
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                />
                <Dropdown
                  label="Billing Cycle"
                  placeholder="Monthly"
                  options={["Monthly", "Annually"]}
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                />
                {/* <InputField
                  label="Trial Period (days)"
                  placeholder="14"
                  type="number"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                /> */}
              </>
            )}
          </div>

          {/* Action Buttons */}
          <div className="flex justify-center sm:justify-end gap-4 mt-10">
            <button
              onClick={prevStep}
              className="px-8 py-2.5 rounded-xl border border-[#E5E7EB] bg-[#F9FAFB] text-[#374151] font-semibold text-sm hover:bg-gray-100 transition-colors w-full sm:w-auto"
            >
              Cancel
            </button>
            <button
              onClick={
                activeTab === 2 ? () => console.log("Create account") : nextStep
              }
              className="px-10 py-2.5 rounded-xl bg-[#EA2B33] text-white font-semibold text-sm hover:bg-[#d1232a] transition-colors w-full sm:w-auto"
            >
              {activeTab === 2 ? "Create" : "Next"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Signup;
