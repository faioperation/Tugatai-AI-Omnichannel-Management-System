"use client";
import React, { useState, useRef, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Container from "../component/Container";
import { IoChevronDown } from "react-icons/io5";

import { countries } from "./countries";

const Call = () => {
  const [selectedCountry, setSelectedCountry] = useState(countries[0]);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const dropdownRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);
  return (
    <section
      id="contact"
      className="relative bg-gradient-to-t from-[#000000] via-[#1A0B2E] to-[#000000] py-20 overflow-hidden"
    >
      <Container className="flex flex-col items-center gap-16">
        <div className="md:grid grid-cols-12 space-y-8 md:space-y-0  w-full mx-auto items-center ">
          {/* Left Content - Call Form */}
          <motion.div
            initial={{ opacity: 0, x: -30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: false }}
            transition={{ duration: 0.8 }}
            className="col-span-8  w-full"
          >
            <div className="bg-[#050925] backdrop-blur-xl  rounded-3xl py-16 px-6 shadow-2xl flex flex-col gap-6 md:w-[420px]">
              <h3 className="text-2xl font-bold font-inter text-white text-center">
               Connect with us
              </h3>

              <div className="flex flex-col gap-4 mt-2 ">
                {/* Phone Input */}
                <div className="relative flex items-center border border-white rounded-xl overflow-visible focus-within:border-[#AD46FF]/50 transition-colors">
                  <div className="relative" ref={dropdownRef}>
                    <button
                      type="button"
                      onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                      className="flex items-center gap-2 pl-4 pr-2 py-3 border-r border-white/90  transition-colors cursor-pointer rounded-l-xl"
                    >
                      <img
                        src={`https://flagcdn.com/w40/${selectedCountry.code.toLowerCase()}.png`}
                        alt={selectedCountry.name}
                        className="w-6 h-4 rounded-[3px] object-cover"
                      />
                      <IoChevronDown
                        className={`text-transparent text-sm transition-transform duration-300 ${isDropdownOpen ? "rotate-180" : ""}`}
                      />
                    </button>

                    <AnimatePresence>
                      {isDropdownOpen && (
                        <motion.div
                          initial={{ opacity: 0, y: 10 }}
                          animate={{ opacity: 1, y: 0 }}
                          exit={{ opacity: 0, y: 10 }}
                          transition={{ duration: 0.2 }}
                          className="absolute top-full left-0 mt-2 w-[280px] bg-[#1A1A24] border border-white/10 rounded-xl shadow-2xl z-50 overflow-hidden"
                        >
                          <div className="max-h-[240px] overflow-y-auto [&::-webkit-scrollbar]:w-2 [&::-webkit-scrollbar-track]:bg-transparent [&::-webkit-scrollbar-thumb]:bg-white/10 [&::-webkit-scrollbar-thumb]:rounded-full hover:[&::-webkit-scrollbar-thumb]:bg-white/20">
                            {countries.map((country) => (
                              <button
                                key={country.code}
                                type="button"
                                onClick={() => {
                                  setSelectedCountry(country);
                                  setIsDropdownOpen(false);
                                }}
                                className={`w-full flex items-center gap-3 px-4 py-3 hover:bg-white/5 transition-colors text-left ${selectedCountry.code === country.code ? "bg-white/5" : ""}`}
                              >
                                <img
                                  src={`https://flagcdn.com/w40/${country.code.toLowerCase()}.png`}
                                  alt={country.name}
                                  className="w-6 h-4 rounded-[3px] object-cover shrink-0"
                                />
                                <span className="text-white/90 font-inter text-sm flex-1">
                                  {country.name}
                                </span>
                                <span className="text-white/50 font-inter text-sm">
                                  {country.dialCode}
                                </span>
                              </button>
                            ))}
                          </div>
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </div>

                  <div className="flex items-center bg-transparent w-full">
                    <span className="text-white text-sm font-inter pl-3">
                      {selectedCountry.dialCode}
                    </span>
                    <input
                      type="tel"
                      placeholder="Enter phone number"
                      className="w-full bg-transparent text-white px-2 py-3.5 outline-none text-sm font-inter placeholder:text-white/30"
                    />
                  </div>
                </div>

                {/* Email Input */}
                <div className="relative flex items-center  border border-white rounded-xl overflow-hidden focus-within:border-[#AD46FF]/50 transition-colors">
                  <input
                    type="email"
                    placeholder="Enter email address"
                    className="w-full bg-transparent text-white px-4 py-3.5 outline-none text-sm font-inter placeholder:text-white/30"
                  />
                </div>

                {/* Submit Button */}
                <button className="w-full bg-gradient-to-r from-[#9810FA] to-[#AD46FF] hover:bg-[#9810FA] text-white font-inter font-semibold py-3.5 rounded-xl shadow-[0_0_20px_rgba(173,70,255,0.3)] hover:shadow-[0_0_25px_rgba(173,70,255,0.5)] transition-all mt-2">
                  Get a call
                </button>
              </div>
            </div>
          </motion.div>

          {/* Right Content - Video Animation */}
          <motion.div
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: false }}
            transition={{ duration: 0.8, delay: 0.2 }}
            className="col-span-4 w-full flex items-center justify-center relative"
          >
            {/* The Video Container */}
            <div className="relative w-full aspect-video md:aspect-[16/10]  rounded-3xl">
              <video
                src="/AiVoice.mp4"
                autoPlay
                loop
                muted
                playsInline
                className="w-full object-cover rounded-3xl opacity-90 group-hover:opacity-100 transition-opacity duration-500 relative z-10"
              />
            </div>
          </motion.div>
        </div>
      </Container>
    </section>
  );
};

export default Call;
