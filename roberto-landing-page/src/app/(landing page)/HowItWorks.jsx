"use client";
import React from "react";
import Header from "../component/Header";
import { motion } from "framer-motion";
import Container from "../component/Container";
import {
  FiMessageSquare,
  FiZap,
  FiFileText,
  FiCalendar,
  FiDatabase,
  FiCheckCircle,
  FiChevronRight
} from "react-icons/fi";

const StepCard = ({ icon: Icon, title, description, iconBg, isLast }) => {
  return (
    <div className="flex flex-col md:flex-row items-center gap-4 w-full md:w-auto">
      <motion.div
        whileHover={{ y: -8, borderColor: "rgba(255,255,255,0.2)" }}
        className="relative px-6 py-8 rounded-[2rem] border border-white/5 bg-gradient-to-br from-[#1A1A27]  to-[#0F0F18] backdrop-blur-2xl flex flex-col items-start justify-center gap-4 transition-colors w-full "
      >
        {/* Checkmark Icon */}
        <div className="absolute top-5 right-5">
          <FiCheckCircle className="text-[#00C853] text-xl" />
        </div>

        {/* Step Icon */}
        <div className={`w-14 h-14 rounded-2xl flex items-center justify-center ${iconBg} shadow-xl shadow-black/20`}>
          <Icon className="text-white text-2xl" />
        </div>

        {/* Content */}
        <div className="space-y-1">
          <h3 className="text-white font-manrope font-bold text-lg">
            {title}
          </h3>
          <p className="text-[#888888] font-inter text-[13px] leading-relaxed">
            {description}
          </p>
        </div>
      </motion.div>

      {/* Connection Arrow */}
      {!isLast && (
        <div className="hidden lg:flex items-center justify-center text-[#5D3FD3]/40">
          <FiChevronRight className="text-2xl" />
        </div>
      )}
    </div>
  );
};

const steps = [
  {
    icon: FiMessageSquare,
    title: "Customer Message",
    description: "I need to ship a package to New York",
    iconBg: "bg-[#007AFF]",
  },
  {
    icon: FiZap,
    title: "AI Processes",
    description: "AI analyzes request and context",
    iconBg: "bg-[#A033FF]",
  },
  {
    icon: FiFileText,
    title: "Quote Generated",
    description: "$45 for express shipping to NY",
    iconBg: "bg-[#00C853]",
  },
  {
    icon: FiCalendar,
    title: "Booking Created",
    description: "Scheduled for pickup tomorrow 2PM",
    iconBg: "bg-[#FF6D00]",
  },
  {
    icon: FiDatabase,
    title: "CRM Updated",
    description: "Lead moved to 'Hot' pipeline",
    iconBg: "bg-[#FF4081]",
  },
];

const HowItWorks = () => {
  return (
    <section id="how-it-works" className="relative bg-gradient-to-t from-[#000000] via-[#3C0366] to-[#000000] py-20 overflow-hidden">
      <Container>
        <div className="flex flex-col items-center gap-16">
          <Header
            titleText="How It Works"
            subtitleText="Watch AI handle everything from first message to confirmed booking"
          />

          {/* Cards Grid */}
          <div className="grid grid-cols-1 md:grid-cols-5 justify-center items-center gap-4 lg:gap-0 w-full">
            {steps.map((step, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: false }}
                transition={{ delay: index * 0.15, duration: 0.5 }}
                className=""
              >
                <StepCard
                  {...step}
                  isLast={index === steps.length - 1}
                />
              </motion.div>
            ))}
          </div>

          {/* Bottom Badge */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: false }}
            transition={{ delay: 0.8 }}
            className="px-6 py-3 rounded-full border border-purple-500/30 bg-purple-500/10 backdrop-blur-md flex items-center gap-3"
          >
            <div className="w-2 h-2 rounded-full bg-purple-500 animate-pulse" />
            <span className="text-sm font-inter font-medium text-purple-300">
              Complete automation in under 3 seconds
            </span>
          </motion.div>
        </div>
      </Container>


    </section>
  );
};

export default HowItWorks;
