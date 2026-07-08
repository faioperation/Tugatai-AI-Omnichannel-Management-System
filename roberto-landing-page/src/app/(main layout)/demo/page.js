"use client";
import React, { useState } from "react";
import { FiMail, FiHeadphones, FiArrowRight } from "react-icons/fi";
import { motion } from "framer-motion";
import Image from "next/image";
import Link from "next/link";
import Container from "../../component/Container";
import { toast } from "react-hot-toast";
import { useMutation } from "@tanstack/react-query";

const DemoPage = () => {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    subject: "",
    description: "",
  });
  const mutation = useMutation({
    mutationFn: async (data) => {
      const baseUrl = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5000/api/v1";
      const response = await fetch(`${baseUrl}/demo-bookings/create`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: JSON.stringify(data),
      });

      const resData = await response.json();
      if (!response.ok) {
        throw new Error(resData.message || "Failed to submit demo request.");
      }
      return resData;
    },
    onSuccess: () => {
      toast.success("Demo request submitted successfully!");
      setFormData({ name: "", email: "", subject: "", description: "" });
    },
    onError: (error) => {
      toast.error(error.message || "Something went wrong.");
    }
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.name || !formData.email || !formData.description) {
      toast.error("Please fill in all required fields.");
      return;
    }
    mutation.mutate(formData);
  };

  return (
    <div className="min-h-screen bg-[#000000] text-white pt-12 pb-20 relative overflow-hidden">
      {/* Background Gradients */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-[#9810FA]/10 blur-[120px] rounded-full pointer-events-none" />
      <div className="absolute bottom-0 left-1/2 -translate-x-1/2 w-[800px] h-[400px] bg-[#AD46FF]/10 blur-[120px] rounded-full pointer-events-none" />

      <Container>
        {/* Header */}
        <div className="text-center mb-16 relative z-10">
          <motion.h1
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-5xl md:text-6xl font-bold font-inter mb-4 text-white"
          >
            Talk to OMNIRRA
          </motion.h1>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="text-[#AD46FF] font-medium text-sm md:text-base font-inter max-w-2xl mx-auto"
          >
            Questions about setup, pricing, or performance? We'll tell you straight if OMNIRRA is a fit.
          </motion.p>
        </div>

        <div className="grid md:grid-cols-2 gap-8 max-w-5xl mx-auto relative z-10">
          {/* Left Column: Contact Cards */}
          <div className="flex flex-col gap-6">
            {/* Email Us */}
            <motion.div
              initial={{ opacity: 0, x: -30 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.2 }}
              className="bg-white/5 border border-white/10 rounded-2xl p-8 hover:bg-white/10 transition-colors"
            >
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-lg bg-white/10 flex items-center justify-center text-white">
                  <FiMail size={20} />
                </div>
                <h3 className="font-semibold text-lg font-inter">Email Us</h3>
              </div>
              <p className="text-[#A3A3A3] text-sm leading-relaxed mb-6 font-inter">
                Product questions, technical issues, or general support. We usually reply within 1 business day.
              </p>
              <a href="mailto:support@omnirra.ai" className="text-[#AD46FF] hover:text-white transition-colors text-sm font-semibold font-inter">
                support@omnirra.ai
              </a>
            </motion.div>

            {/* Contact Sales */}
            <motion.div
              initial={{ opacity: 0, x: -30 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 }}
              className="bg-white/5 border border-white/10 rounded-2xl p-8 hover:bg-white/10 transition-colors"
            >
              <div className="flex items-center gap-3 mb-4">
                <div className="w-10 h-10 rounded-lg bg-white/10 flex items-center justify-center text-white">
                  <FiHeadphones size={20} />
                </div>
                <h3 className="font-semibold text-lg font-inter">Contact Sales</h3>
              </div>
              <p className="text-[#A3A3A3] text-sm leading-relaxed mb-6 font-inter">
                Discuss your use case, traffic volume, or booking targets. Best for businesses considering Growth or Scale plans.
              </p>
              <a href="mailto:hello@matrix.ai" className="text-[#AD46FF] hover:text-white transition-colors text-sm font-semibold font-inter">
                hello@omnirra.ai
              </a>
            </motion.div>
          </div>

          {/* Right Column: Form */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
            className="bg-[#0A0A0A] border border-white/10 rounded-3xl p-8 shadow-2xl relative"
          >
            <h2 className="text-xl font-bold text-white mb-6 font-inter leading-tight">
              Book a Live Demo. Let's see if OMNIRRA fits your business.
            </h2>
            
            <form onSubmit={handleSubmit} className="flex flex-col gap-5">
              <div className="flex flex-col gap-2">
                <label className="text-[13px] text-[#A3A3A3] font-inter">Name</label>
                <input 
                  type="text" 
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  placeholder="Your Name" 
                  required
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white placeholder:text-white/30 outline-none focus:border-[#AD46FF] transition-colors"
                />
              </div>

              <div className="flex flex-col gap-2">
                <label className="text-[13px] text-[#A3A3A3] font-inter">Email Address</label>
                <input 
                  type="email" 
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  placeholder="Work email preferred" 
                  required
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white placeholder:text-white/30 outline-none focus:border-[#AD46FF] transition-colors"
                />
              </div>

              <div className="flex flex-col gap-2">
                <label className="text-[13px] text-[#A3A3A3] font-inter">Subject</label>
                <input 
                  type="text" 
                  name="subject"
                  value={formData.subject}
                  onChange={handleChange}
                  placeholder="Pricing, demo, setup, or general question" 
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white placeholder:text-white/30 outline-none focus:border-[#AD46FF] transition-colors"
                />
              </div>

              <div className="flex flex-col gap-2">
                <label className="text-[13px] text-[#A3A3A3] font-inter">How can we help?</label>
                <textarea 
                  name="description"
                  value={formData.description}
                  onChange={handleChange}
                  placeholder="Tell us about your business, traffic source, and goals." 
                  required
                  className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-3 text-sm text-white placeholder:text-white/30 outline-none focus:border-[#AD46FF] transition-colors resize-none min-h-[100px]"
                ></textarea>
              </div>

              <button 
                type="submit"
                disabled={mutation.isPending}
                className="w-full bg-gradient-to-r from-[#9810FA] to-[#AD46FF] hover:from-[#8B0EE0] hover:to-[#9E3DE0] text-white font-semibold font-inter py-3.5 rounded-xl mt-2 transition-all shadow-[0_0_20px_rgba(152,16,250,0.3)] hover:shadow-[0_0_30px_rgba(152,16,250,0.5)] disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center"
              >
                {mutation.isPending ? (
                  <div className="w-5 h-5 border-2 border-white/20 border-t-white rounded-full animate-spin"></div>
                ) : (
                  "Submit"
                )}
              </button>
            </form>
          </motion.div>
        </div>

      
      </Container>
    </div>
  );
};

export default DemoPage;
