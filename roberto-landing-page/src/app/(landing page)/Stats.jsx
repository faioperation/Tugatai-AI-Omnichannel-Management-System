'use client';
import React from 'react';
import Container from '../component/Container';
import { LuTrendingUp, LuZap, LuTarget, LuBot } from "react-icons/lu";
import Header from '../component/Header';
import { motion } from 'framer-motion';

const statsData = [
  {
    id: 1,
    icon: LuTrendingUp,
    value: "+45%",
    title: "Increase in Booking Conversion",
    desc: "More chats turning into confirmed bookings",
    iconBg: "bg-gradient-to-br from-[#9810FA]  to-[#AD46FF]",
    shadow: "shadow-[0_0_30px_rgba(155,81,224,0.6)]"
  },
  {
    id: 2,
    icon: LuZap,
    value: "<2s",
    title: "Instant Response Time",
    desc: "Every customer gets immediate replies",
    iconBg: "bg-gradient-to-br from-[#9810FA]  to-[#AD46FF]",
    shadow: "shadow-[0_0_30px_rgba(187,107,217,0.6)]"
  },
  {
    id: 3,
    icon: LuTarget,
    value: "3x",
    title: "More Leads Captured",
    desc: "Never miss another opportunity",
    iconBg: "bg-gradient-to-br from-[#9810FA]  to-[#AD46FF]",
    shadow: "shadow-[0_0_30px_rgba(165,94,234,0.6)]"
  },
  {
    id: 4,
    icon: LuBot,
    value: "80%",
    title: "Conversations Fully Automated",
    desc: "From first message to booking confirmation",
    iconBg: "bg-gradient-to-br from-[#9810FA]  to-[#AD46FF]",
    shadow: "shadow-[0_0_30px_rgba(142,68,173,0.6)]"
  }
];

const Stats = () => {
  return (
    <section className="py-10 bg-[#000000] relative" id="stats">
      <Container>
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: false }}
          transition={{ duration: 0.6 }}
          className="flex flex-col items-center text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-purple-500/20 bg-purple-500/10 mb-8">
            <div className="w-1.5 h-1.5 rounded-full bg-purple-500"></div>
            <span className="text-sm text-purple-300 font-medium">Proven Results</span>
          </div>
          <Header
            className="text-center"
            titleText="Real Results. Real Growth."
            subtitleText="Our AI system helps businesses automate operations and increase conversions."
          />
        </motion.div>

        {/* Grid Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
          {statsData.map((stat, index) => (
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: false }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              key={stat.id}
              className="bg-gradient-to-br from-[#1A1A2E]  to-[#0F0F1A] border border-[#AD46FF33] rounded-3xl p-8 hover:bg-[#131318] transition-colors duration-300"
            >
              <div className={`w-14 h-14 rounded-xl flex items-center justify-center text-white mb-8 ${stat.iconBg} ${stat.shadow}`}>
                <stat.icon className="text-2xl" />
              </div>
              <h3 className="text-5xl font-bold  mb-4 tracking-tight bg-gradient-to-l from-[#C27AFF] via-[#DAB2FF]  to-[#C27AFF] bg-clip-text text-transparent">{stat.value}</h3>
              <h4 className="text-lg font-bold text-white mb-3 font-inter">{stat.title}</h4>
              <p className="text-[#9CA3AF] text-sm font-inter">{stat.desc}</p>
            </motion.div>
          ))}
        </div>

        {/* Bottom Banner */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          whileInView={{ opacity: 1, scale: 1 }}
          viewport={{ once: false }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="bg-gradient-to-b from-[#AD46FF]/10  to-[#9810FA]/5 border border-[#AD46FF]/20 rounded-2xl p-10 text-center mx-auto w-fit   "
        >

          <div className="">
            <h3 className="text-2xl md:text-3xl font-bold text-white mb-3">
              Join 500+ businesses already growing with MoonAI
            </h3>
            <p className="text-white/60 text-lg">
              Start automating your customer conversations today
            </p>
          </div>
        </motion.div>

      </Container>
    </section>
  );
};

export default Stats;