"use client";
import React, { useState } from "react";
import InputField from "../../component/InputField";
import Image from "next/image";
import Password from "@/app/component/Password";
import Link from "next/link";
import { useMutation } from "@tanstack/react-query";
import { toast } from "react-hot-toast";
import Cookies from "js-cookie";
import { useRouter } from "next/navigation";

const Signin = () => {
  const router = useRouter();
  const [formData, setFormData] = useState({
    email: "",
    password: "",
  });

  const handleInputChange = (field, value) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const mutation = useMutation({
    mutationFn: async (data) => {
      const baseUrl = process.env.NEXT_PUBLIC_API_URL;
      const res = await fetch(`${baseUrl}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true'
        },
        body: JSON.stringify(data)
      });
      if (!res.ok) {
        throw new Error('Invalid credentials');
      }
      return res.json();
    },
    onSuccess: (response) => {
      // Save tokens
      Cookies.set("accessToken", response.data.accessToken, { expires: 7 }); // Expires in 7 days
      Cookies.set("refreshToken", response.data.refreshToken, { expires: 30 }); // Expires in 30 days
      
      // Save primary role and user info
      const userRole = response.data.user.roles?.[0]?.role?.name;
      if (userRole) {
        Cookies.set("userRole", userRole, { expires: 7 });
      }
      if (response.data.user.firstName) {
        Cookies.set("userName", response.data.user.firstName, { expires: 7 });
      }
      if (response.data.user.profilePicture) {
        Cookies.set("userImage", response.data.user.profilePicture, { expires: 7 });
      }
      if (response.data.user.businessId) {
        Cookies.set("businessId", response.data.user.businessId, { expires: 7 });
      }

      toast.success("Signed in successfully!");
      // Redirect to landing page
      router.push("/");
    },
    onError: (err) => {
      toast.error(err.message);
    }
  });

  const handleSignIn = (e) => {
    e.preventDefault();
    mutation.mutate(formData);
  };

  return (
    <div className="min-h-screen flex items-center justify-center py-8 px-4">
      <div className="bg-white rounded-[24px] w-full max-w-[500px] h-auto px-6 md:py-10 py-8 md:px-10 shadow-2xl flex flex-col justify-center">
        {/* Logo and Header */}
        <div className="flex flex-col items-center mb-8">
          <Link href="/">
            <div className="bg-[#EA2B33] rounded-xl flex items-center justify-center mb-5 p-2 cursor-pointer hover:opacity-90 transition-opacity">
              <Image src={"/logo.png"} alt="logo" width={60} height={80} className="object-contain" />
            </div>
          </Link>
          <h1 className="text-[28px] font-medium text-black mb-2 tracking-tight">
            Sign in
          </h1>
          <p className="text-[#5B5B5B] text-[14px] text-center">
            Welcome back! Please enter your details.
          </p>
        </div>

        {/* Form Content */}
        <form onSubmit={handleSignIn} className="flex flex-col justify-between flex-1">
          <div className="space-y-5">
            <InputField
              label="Email"
              placeholder="email@example.com"
              type="email"
              labelClass="text-[14px] font-semibold"
              inputClass="!p-3.5 !text-sm !rounded-xl"
              value={formData.email}
              onChange={(e) => handleInputChange("email", e.target.value)}
            />

            <Password
              label="Password"
              placeholder="Enter your password"
              labelClass="text-[14px] font-semibold"
              inputClass="!p-3.5 !text-sm !rounded-xl"
              value={formData.password}
              onChange={(e) => handleInputChange("password", e.target.value)}
            />
            
            
          </div>

          {/* Action Buttons */}
          <div className="flex flex-col gap-4 mt-8">
            <button
              type="submit"
              disabled={mutation.isPending}
              className={`w-full py-3.5 rounded-xl bg-[#EA2B33] text-white font-semibold text-[15px] hover:bg-[#d1232a] transition-colors ${mutation.isPending ? 'opacity-70 cursor-not-allowed' : ''}`}
            >
              {mutation.isPending ? "Signing in..." : "Sign in"}
            </button>
            
            <p className="text-center text-[14px] text-[#5B5B5B] mt-2">
              Don't have an account?{" "}
              <Link href="/signup" className="text-[#EA2B33] font-semibold hover:underline">
                Sign up
              </Link>
            </p>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Signin;
