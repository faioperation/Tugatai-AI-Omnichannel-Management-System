"use client";
import React from "react";
import Container from "../component/Container";
import Header from "../component/Header";
import {
  FiMessageSquare,
  FiCalendar,
  FiUsers,
  FiDollarSign,
  FiGlobe,
  FiZap,
  FiClock,
  FiPhone,
  FiMail,
  FiCode,
  FiMic,
} from "react-icons/fi";
import { FaWhatsapp, FaInstagram, FaTelegramPlane, FaFacebookMessenger, FaLine, FaSms } from "react-icons/fa";
import { LuBot } from "react-icons/lu";
import { motion } from "framer-motion";

const featuresData = [
  {
    id: 1,
    icon: <FiMessageSquare className="text-white w-7 h-7" />,
    iconBg: "bg-[#1E65FF]",
    bulletColor: "bg-[#1E65FF]",
    title: "AI Chat Automation",
    subtitle: "Instant intelligent responses in any language",
    bullets: [
      "Auto replies",
      "Multi-language support",
      "Context understanding",
      "Natural conversations",
    ],
  },
  {
    id: 2,
    icon: <FiCalendar className="text-white w-7 h-7" />,
    iconBg: "bg-[#00D06A]",
    bulletColor: "bg-[#00D06A]",
    title: "Smart Booking System",
    subtitle: "Automated scheduling and calendar management",
    bullets: [
      "Auto scheduling",
      "Calendar integration",
      "Confirmation system",
      "Reminders & notifications",
    ],
  },
  {
    id: 3,
    icon: <FiUsers className="text-white w-7 h-7" />,
    iconBg: "bg-[#AD46FF]",
    bulletColor: "bg-[#AD46FF]",
    title: "CRM & Lead Tracking",
    subtitle: "Complete customer relationship management",
    bullets: [
      "Pipeline tracking",
      "Customer history",
      "Lead scoring",
      "Automated follow-ups",
    ],
  },
  {
    id: 4,
    icon: <FiDollarSign className="text-white w-7 h-7" />,
    iconBg: "bg-[#FF6A00]",
    bulletColor: "bg-[#FF6A00]",
    title: "Intelligent Pricing Engine",
    subtitle: "Dynamic quote generation and pricing rules",
    bullets: [
      "Rule-based pricing",
      "Auto quote generation",
      "Discount management",
      "Price optimization",
    ],
  },
];

const MultiChannelAnimation = () => {
  const iconsRow1 = [
    <FaWhatsapp className="w-5 h-5 text-white" />,
    <FaFacebookMessenger className="w-5 h-5 text-white" />,
    <FaInstagram className="w-5 h-5 text-white" />,
    <FiGlobe className="w-5 h-5 text-white" />,
    <FaTelegramPlane className="w-5 h-5 text-white" />,
    <FaSms className="w-5 h-5 text-white" />,
    <FiMail className="w-5 h-5 text-white" />,
    <FaLine className="w-5 h-5 text-white" />,
    <FiMic className="w-5 h-5 text-white" />,
  ];

  const iconsRow2 = [
    <FaWhatsapp className="w-5 h-5 text-white" />,
    <FaFacebookMessenger className="w-5 h-5 text-white" />,
    <FaInstagram className="w-5 h-5 text-white" />,
    <FiGlobe className="w-5 h-5 text-white" />,
    <FaTelegramPlane className="w-5 h-5 text-white" />,
    <FaSms className="w-5 h-5 text-white" />,
    <FiMail className="w-5 h-5 text-white" />,
    <FaLine className="w-5 h-5 text-white" />,
    <FiMic className="w-5 h-5 text-white" />,
  ];

  const IconBox = ({ icon }) => (
    <div className="w-10 h-10 rounded-[12px] bg-gradient-to-r from-[#9810FA] to-[#AD46FF] flex items-center justify-center shrink-0  border border-white/20">
      {icon}
    </div>
  );

  return (
    <div
      className="w-full h-28 relative overflow-hidden flex flex-col justify-center gap-4 mb-4"
      style={{
        WebkitMaskImage:
          "linear-gradient(to right, transparent, black 15%, black 85%, transparent)",
        maskImage:
          "linear-gradient(to right, transparent, black 15%, black 85%, transparent)",
      }}
    >
      <motion.div
        animate={{ x: [0, -300] }}
        transition={{ repeat: Infinity, duration: 10, ease: "linear" }}
        className="flex gap-2.5 w-max"
      >
        {[...iconsRow1, ...iconsRow1, ...iconsRow1].map((icon, i) => (
          <IconBox key={`r1-${i}`} icon={icon} />
        ))}
      </motion.div>
      <motion.div
        animate={{ x: [-300, 0] }}
        transition={{ repeat: Infinity, duration: 10, ease: "linear" }}
        className="flex gap-2.5 w-max"
      >
        {[...iconsRow2, ...iconsRow2, ...iconsRow2].map((icon, i) => (
          <IconBox key={`r2-${i}`} icon={icon} />
        ))}
      </motion.div>
    </div>
  );
};

const AiPoweredAnimation = () => {
  return (
    <div className="w-full h-28 relative flex items-center justify-center overflow-hidden mb-4">
      {/* Orbiting particles */}
      <motion.div
        animate={{ rotate: 360 }}
        transition={{ repeat: Infinity, duration: 8, ease: "linear" }}
        className="absolute w-[100px] h-[100px]"
      >
        <div className="w-2 h-2 rounded-full bg-[#AD46FF] absolute top-0 left-1/2 -translate-x-1/2 shadow-[0_0_8px_rgba(173,70,255,0.8)]" />
      </motion.div>
      <motion.div
        animate={{ rotate: -360 }}
        transition={{ repeat: Infinity, duration: 12, ease: "linear" }}
        className="absolute w-20 h-20"
      >
        <div className="w-1.5 h-1.5 rounded-full bg-white absolute bottom-0 left-1/2 -translate-x-1/2 shadow-[0_0_8px_rgba(255,255,255,0.8)]" />
      </motion.div>

      <motion.div
        animate={{ scale: [1, 1.15, 1] }}
        transition={{ repeat: Infinity, duration: 2, ease: "easeInOut" }}
        className="relative z-10 w-14 h-14 rounded-[14px] bg-gradient-to-br from-[#1A1A27] to-[#AD46FF]/30 border border-[#9810FA]/40 flex items-center justify-center shadow-[0_0_25px_rgba(173,70,255,0.4)] backdrop-blur-md"
      >
        <LuBot className="w-7 h-7 text-[#AD46FF]" />
      </motion.div>
    </div>
  );
};

const RealTimeAnimation = () => {
  return (
    <div className="w-full h-28 flex items-center justify-center relative mb-4">
      {/* Expanding ripples */}
      <motion.div
        animate={{ scale: [1, 2.5], opacity: [0.6, 0] }}
        transition={{ repeat: Infinity, duration: 2, ease: "easeOut" }}
        className="absolute w-12 h-12 rounded-full border-[1.5px] border-[#AD46FF]"
      />
      <motion.div
        animate={{ scale: [1, 2.5], opacity: [0.6, 0] }}
        transition={{ repeat: Infinity, duration: 2, ease: "easeOut", delay: 0.6 }}
        className="absolute w-12 h-12 rounded-full border-[1.5px] border-[#AD46FF]"
      />
      <motion.div
        animate={{ scale: [1, 2.5], opacity: [0.6, 0] }}
        transition={{ repeat: Infinity, duration: 2, ease: "easeOut", delay: 1.2 }}
        className="absolute w-12 h-12 rounded-full border-[1.5px] border-[#AD46FF]"
      />
      {/* Center dot */}
      <div className="relative z-10 w-10 h-10 rounded-full bg-gradient-to-br from-[#1A1A27] to-[#AD46FF]/30 border border-[#9810FA]/40 flex items-center justify-center shadow-[0_0_20px_rgba(173,70,255,0.6)] backdrop-blur-md">
        <FiZap className="w-5 h-5 text-[#AD46FF]" />
      </div>
    </div>
  );
};

const Active247Animation = () => {
  return (
    <div className="w-full h-28 relative flex items-center justify-center mb-4">
      {/* Dashed spinning circle */}
      <motion.div
        animate={{ rotate: 360 }}
        transition={{ repeat: Infinity, duration: 10, ease: "linear" }}
        className="absolute w-[88px] h-[88px] rounded-full border-[2px] border-dashed border-[#AD46FF]/30"
      />
      {/* Outer spinning gradient line */}
      <div className="absolute w-[104px] h-[104px] rounded-full flex items-center justify-center">
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ repeat: Infinity, duration: 3, ease: "linear" }}
          className="w-full h-full rounded-full"
          style={{
            background:
              "conic-gradient(from 0deg, transparent 0%, transparent 80%, rgba(173,70,255,0.8) 100%)",
            WebkitMaskImage: "radial-gradient(transparent 65%, black 66%)",
            maskImage: "radial-gradient(transparent 65%, black 66%)",
          }}
        />
      </div>
      {/* Center clock */}
      <div className="relative z-10 w-12 h-12 rounded-full bg-gradient-to-b from-[#1A1A27] to-[#AD46FF]/20 flex items-center justify-center shadow-[0_0_15px_rgba(173,70,255,0.4)] border border-[#9810FA]/30 backdrop-blur-sm">
        <FiClock className="w-5 h-5 text-[#AD46FF]" />
      </div>
    </div>
  );
};

const smallFeaturesData = [
  {
    id: 5,
    animation: <MultiChannelAnimation />,
    title: "Multi-Channel",
    subtitle: "WhatsApp, Messenger, Instagram, Website Chat, Telegram, SMS, Email ,API, Line, Voice AI",
  },
  {
    id: 6,
    animation: <AiPoweredAnimation />,
    title: "AI Powered",
    subtitle: "GPT-4 Based",
  },
  {
    id: 7,
    animation: <RealTimeAnimation />,
    title: "Real-Time",
    subtitle: "Instant Updates",
  },
  {
    id: 8,
    animation: <Active247Animation />,
    title: "24/7 Active",
    subtitle: "Never Miss a Lead",
  },
];

const Features = () => {
  return (
    <section id="feature" className="py-10">
      <Container>
        <Header
          titleText={`Core Features`}
          subtitleText={`Everything you need to automate and grow your business`}
        />

        <div className="grid grid-cols-12 gap-6 mt-16">
          {/* Top 4 Large Cards */}
          {featuresData.map((feature, idx) => (
            <motion.div
              key={feature.id}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: false, margin: "-50px" }}
              transition={{ duration: 0.6, delay: idx * 0.15 }}
              className="col-span-12 md:col-span-6 bg-gradient-to-br from-[#1A1A27]  to-[#0F0F18] border border-white/10 rounded-3xl p-8 "
            >
              <div
                className={`w-14 h-14 rounded-2xl ${feature.iconBg} flex items-center justify-center mb-8 shadow-md`}
              >
                {feature.icon}
              </div>
              <h3 className="text-2xl font-semibold text-white mb-2 font-inter">
                {feature.title}
              </h3>
              <p className="text-[#99A1AF] text-base mb-8 font-inter">
                {feature.subtitle}
              </p>

              <ul className="space-y-3.5">
                {feature.bullets.map((bullet, bulletIdx) => (
                  <li key={bulletIdx} className="flex items-center gap-4">
                    <div
                      className={`w-1.5 h-1.5 rounded-full ${feature.bulletColor} `}
                    />
                    <span className="text-white/70 text-sm font-inter">
                      {bullet}
                    </span>
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}

          {/* Bottom 4 Small Cards */}
          {smallFeaturesData.map((feature, idx) => (
            <motion.div
              key={feature.id}
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              whileInView={{ opacity: 1, scale: 1, y: 0 }}
              viewport={{ once: false, margin: "-50px" }}
              transition={{ duration: 0.5, delay: 0.4 + idx * 0.1 }}
              className=" col-span-12 sm:col-span-6 lg:col-span-3 bg-gradient-to-br from-[#1A1A27]  to-[#0F0F18] border border-white/10 rounded-[24px] pt-8 pb-6 px-6 flex flex-col items-center justify-center text-center  mt-2 overflow-hidden relative group"
            >
              {feature.animation}
              <h4 className="text-white font-semibold text-base mb-1.5 font-inter relative z-10">
                {feature.title}
              </h4>
              <p className="text-[#99A1AF] text-sm font-inter relative z-10">
                {feature.subtitle}
              </p>

              {/* Optional background glow on hover */}
              <div className="absolute inset-0 bg-gradient-to-b from-transparent to-[#AD46FF]/10 opacity-0 group-hover:opacity-100 transition-opacity duration-500" />
            </motion.div>
          ))}
        </div>
      </Container>
    </section>
  );
};

export default Features;
