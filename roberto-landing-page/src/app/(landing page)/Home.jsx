"use client";
import React from "react";
import Container from "../component/Container";
import { motion } from "framer-motion";
import { FiPlay, FiArrowRight } from "react-icons/fi";
import { RiSparklingFill } from "react-icons/ri";
import Link from "next/link";

const Home = () => {
  return (
    <section
      id="home"
      className="relative  bg-[#000000] overflow-hidden flex items-center py-20 "
    >
      <Container>
        <div className=" grid lg:grid-cols-2 gap-5  items-center ">
          {/* Left Content */}
          <motion.div
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: false }}
            transition={{ duration: 0.8, ease: "easeOut" }}
            className="flex flex-col items-center lg:items-start gap-6 "
          >
            {/* Badge */}
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2 }}
              className="px-4 py-1.5 rounded-full border border-purple-500/30 bg-[#AD46FF]/10 backdrop-blur-sm "
            >
              <span className="text-sm font-inter font-medium text-purple-300 flex items-center gap-2 ">
                <RiSparklingFill className="text-[#AD46FF] w-5 h-5" />
                AI-Powered Business Automation
              </span>
            </motion.div>

            {/* Heading */}
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold bg-gradient bg-gradient-to-r from-[#ffffff] via-[#E9D4FF] to-[#ffffff] bg-clip-text text-transparent leading-[1.1] font-inter text-center lg:text-start">
              Run Your Entire Customer Communication with AI
            </h1>

            {/* Subheading */}
            <p className="text-base md:text-lg lg:text-xl text-[#DBDBDB]  font-inter text-center lg:text-start">
             WhatsApp, Email, Voice, SMS & More — All in One AI Platform
            </p>

            {/* Buttons */}
            <div className="flex  items-center gap-4 pt-4">
              <Link href="/demo">
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className="group relative px-2 md:px-8 py-4 bg-gradient-to-r from-[#9810FA] to-[#AD46FF] rounded-2xl text-white font-medium font-inter text-base flex items-center gap-2 shadow-[0_0_20px_rgba(147,51,234,0.3)] hover:shadow-[0_0_30px_rgba(147,51,234,0.5)] transition-all"
                >
                 Book Live Demo
                  <FiArrowRight className="group-hover:translate-x-1 transition-transform" />
                </motion.button>
              </Link>

              <motion.button
                whileHover={{
                  scale: 1.02,
                  backgroundColor: "rgba(255,255,255,0.05)",
                }}
                className="px-2 md:px-8 py-4 border border-white/10 rounded-2xl text-white font-medium text-base flex items-center gap-3 backdrop-blur-sm transition-all"
              >
                <div className="w-7 h-7  flex items-center justify-center">
                  <FiPlay className="text-white" />
                </div>
                Schedule Demo
              </motion.button>
            </div>
          </motion.div>

          {/* Right Content - Video Animation */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: false }}
            transition={{ duration: 1, ease: "easeOut" }}
            className=" flex items-center justify-center"
          >
            <div className="relative w-full backdrop-blur-2xl shadow-2xl overflow-hidden">
              <video
                src="/hero.mp4"
                autoPlay
                loop
                muted
                playsInline
                className="w-full h-full object-cover rounded-2xl "
              />
            </div>
          </motion.div>
        </div>
      </Container>
    </section>
  );
};

export default Home;
