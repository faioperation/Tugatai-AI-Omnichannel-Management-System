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
    country: "",
    address: "",
    ownerName: "",
    ownerEmail: "",
    ownerPassword: "",
    ownerPhone: "",
  });

  const handleInputChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const mutation = useMutation({
    mutationFn: async (data) => {
      const baseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1';
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

  const tabs = ["Business Info", "Owner Details"];

  const nextStep = () => {
    if (activeTab < 1) setActiveTab(activeTab + 1);
  };

  const prevStep = () => {
    if (activeTab > 0) setActiveTab(activeTab - 1);
  };

  return (
    <div className="min-h-screen flex items-center justify-center py-8 px-4">
      <div className="bg-white rounded-[24px] w-full max-w-[600px] h-auto min-h-[800px] px-2 md:py-7 py-5  md:px-14   shadow-2xl">
        {/* Logo and Header */}
        <div className="flex flex-col items-center mb-8">
          <Link href="/">
            <div className="bg-[#EA2B33] rounded-xl flex items-center justify-center mb-5 cursor-pointer hover:opacity-90 transition-opacity">
              <Image src={"/logo.png"} alt="logo" width={60} height={100} />
            </div>
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
                    { label: "Order Booking", value: "ORDER_BOOKING" },
                    { label: "Appointment Booking", value: "APPOINTMENT_BOOKING" },
                    { label: "Cargo", value: "PARCEL_DELIVERY" },
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
                <div className="grid grid-cols-2 gap-4">
                  <InputField
                    label="Country"
                    placeholder="e.g. Qatar"
                    labelClass="text-[13px] font-semibold"
                    inputClass="!p-3 !text-sm !rounded-xl"
                    type="text"
                    value={formData.country}
                    onChange={(e) => handleInputChange("country", e.target.value)}
                  />
                  <InputField
                    label="Address"
                    placeholder="e.g. Doha"
                    labelClass="text-[13px] font-semibold"
                    inputClass="!p-3 !text-sm !rounded-xl"
                    type="text"
                    value={formData.address}
                    onChange={(e) => handleInputChange("address", e.target.value)}
                  />
                </div>

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
              <Link href="/signin" className="text-[#EA2B33] font-semibold hover:underline">
                Sign in
              </Link>
            </p>
          </div>
            <button
              onClick={prevStep}
              className="px-8 py-2.5 rounded-xl border border-[#E5E7EB] bg-[#F9FAFB] text-[#374151] font-semibold text-sm hover:bg-gray-100 transition-colors w-full sm:w-auto"
            >
              Cancel
            </button>
            <button
              onClick={
                activeTab === 1 ? () => mutation.mutate(formData) : nextStep
              }
              disabled={mutation.isPending}
              className={`px-10 py-2.5 rounded-xl bg-[#EA2B33] text-white font-semibold text-sm hover:bg-[#d1232a] transition-colors w-full sm:w-auto ${mutation.isPending ? 'opacity-70 cursor-not-allowed' : ''}`}
            >
              {mutation.isPending ? "Creating..." : activeTab === 1 ? "Create" : "Next"}
            </button>
          </div>
          
          
        </div>
      </div>
    </div>
  );
};

export default Signup;
