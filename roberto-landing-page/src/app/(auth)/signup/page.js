"use client";
import React, { useState } from "react";
import InputField from "../../component/InputField";
import Dropdown from "../../component/Dropdown";
import Image from "next/image";
import Password from "@/app/component/Password";
import Link from "next/link";
import { useMutation } from "@tanstack/react-query";
import { toast } from "react-hot-toast";
import { useRouter } from "next/navigation";

const Signup = () => {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState(0);

  const [formData, setFormData] = useState({
    businessName: "",
    businessType: "ORDER_BOOKING",
    industry: "",
    description: "",
    ownerName: "",
    ownerEmail: "",
    ownerPassword: "",
    ownerPhone: "",
    branch: {
      name: "",
      email: "",
      phone: "",
      address: "",
    },
  });

  const handleInputChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handleBranchChange = (field, value) => {
    setFormData((prev) => ({
      ...prev,
      branch: {
        ...prev.branch,
        [field]: value
      }
    }));
  };

  const mutation = useMutation({
    mutationFn: async (data) => {
      const baseUrl = process.env.NEXT_PUBLIC_API_URL;
      const res = await fetch(`${baseUrl}/global/business/create`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: JSON.stringify(data)
      });
      if (!res.ok) {
        throw new Error('Failed to create account');
      }
      return res.json();
    },
    onSuccess: () => {
      toast.success("Account created successfully!");
      router.push("/signin");
    },
    onError: (err) => {
      toast.error(err.message);
    }
  });

  const tabs = ["Business Info", "Branch Details", "Owner Details"];

  const nextStep = () => {
    if (activeTab < 2) setActiveTab(activeTab + 1);
  };

  const prevStep = () => {
    if (activeTab > 0) setActiveTab(activeTab - 1);
  };

  return (
    <div className="min-h-screen flex items-center justify-center py-8 px-4">
      <div className="bg-white rounded-[24px] w-full max-w-[600px] h-auto min-h-[800px] px-2 md:py-5 py-5  md:px-14   shadow-2xl">
        {/* Logo and Header */}
        <div className="flex flex-col items-center mb-8">
          <Link href="/">
            {/* <div className="bg-[#EA2B33] rounded-xl flex items-center justify-center mb-5 cursor-pointer hover:opacity-90 transition-opacity"> */}
              <Image src={"/authLogo.png"} alt="logo" width={180} height={180} />
            
          </Link>
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
                  type="text"
                  value={formData.businessName}
                  onChange={(e) => handleInputChange("businessName", e.target.value)}
                />
                <Dropdown
                  label="Business Type"
                  placeholder="Select type"
                  options={[
                    { label: "Order Booking", value: "ORDER_BOOKING", description: "Manage customer orders, food delivery, or product sales." },
                    { label: "Appointment Booking", value: "APPOINTMENT_BOOKING", description: "Schedule and manage appointments for salons, clinics, or consulting." },
                    { label: "Cargo", value: "PARCEL_DELIVERY", description: "Manage logistics, parcel delivery, or cargo tracking." },
                  ]}
                  value={formData.businessType}
                  onSelect={(val) => handleInputChange("businessType", val)}
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                />
                <InputField
                  label="Industry"
                  placeholder="e.g. CARGO"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  type="text"
                  value={formData.industry}
                  onChange={(e) => handleInputChange("industry", e.target.value)}
                />

                <div className="flex flex-col w-full gap-2">
                  <label className="font-inter text-[#000000] text-[13px] font-semibold">
                    Description
                  </label>
                  <textarea
                    placeholder="Brief description of the business..."
                    value={formData.description}
                    onChange={(e) => handleInputChange("description", e.target.value)}
                    className="border border-[#D1D5DC] outline-none p-3 text-sm text-[#000000] placeholder:text-[#0A0A0A]/50 rounded-xl w-full min-h-[90px] resize-none"
                  ></textarea>
                </div>
              </>
            )}

            {activeTab === 1 && (
              <>
                <InputField
                  label="Branch Name"
                  placeholder="Enter branch name"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  type="text"
                  value={formData.branch.name}
                  onChange={(e) => handleBranchChange("name", e.target.value)}
                />
                <InputField
                  label="Branch Email"
                  placeholder="email@branch.com"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  type="email"
                  value={formData.branch.email}
                  onChange={(e) => handleBranchChange("email", e.target.value)}
                />
                <InputField
                  label="Branch Phone"
                  placeholder="+1 234 567 8900"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  type="tel"
                  value={formData.branch.phone}
                  onChange={(e) => handleBranchChange("phone", e.target.value)}
                />
                <InputField
                  label="Branch Address"
                  placeholder="e.g. Doha, Qatar"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  type="text"
                  value={formData.branch.address}
                  onChange={(e) => handleBranchChange("address", e.target.value)}
                />
              </>
            )}

            {activeTab === 2 && (
              <>
                <InputField
                  label="Owner Name"
                  placeholder="Enter full name"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  type="text"
                  value={formData.ownerName}
                  onChange={(e) => handleInputChange("ownerName", e.target.value)}
                />
                <InputField
                  label="Email"
                  placeholder="email@example.com"
                  type="email"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  value={formData.ownerEmail}
                  onChange={(e) => handleInputChange("ownerEmail", e.target.value)}
                />
                <InputField
                  label="Phone"
                  placeholder="+1 234 567 8900"
                  type="tel"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  value={formData.ownerPhone}
                  onChange={(e) => handleInputChange("ownerPhone", e.target.value)}
                />

                <Password
                  label="Initial Password"
                  placeholder="Create password"
                  labelClass="text-[13px] font-semibold"
                  inputClass="!p-3 !text-sm !rounded-xl"
                  value={formData.ownerPassword}
                  onChange={(e) => handleInputChange("ownerPassword", e.target.value)}
                />
              </>
            )}
          </div>

          {/* Action Buttons */}
          <div className="flex justify-center items-center sm:justify-end gap-4 mt-8">

            <div className="">
            <p className="text-[14px] text-[#5B5B5B]">
              Already have an account?{" "}
              <Link href="/signin" className="text-[#9810FA] font-semibold hover:underline">
                Sign in
              </Link>
            </p>
          </div>
            <button
              onClick={prevStep}
              className={`px-8 py-2.5 rounded-xl border border-[#E5E7EB] bg-[#F9FAFB] text-[#374151] font-semibold text-sm hover:bg-gray-100 transition-colors w-full sm:w-auto ${activeTab === 0 ? 'invisible pointer-events-none' : ''}`}
            >
              Cancel
            </button>
            <button
              onClick={
                activeTab === 2 ? () => mutation.mutate(formData) : nextStep
              }
              disabled={mutation.isPending}
              className={`px-10 py-2.5 rounded-xl bg-[#9810FA] text-white font-semibold text-sm hover:bg-[#800cd6] transition-colors w-full sm:w-auto ${mutation.isPending ? 'opacity-70 cursor-not-allowed' : ''}`}
            >
              {mutation.isPending ? "Creating..." : activeTab === 2 ? "Create" : "Next"}
            </button>
          </div>
          
          
        </div>
      </div>
    </div>
  );
};

export default Signup;
