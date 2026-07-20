"use client";
import React from "react";

export default function ToggleButton({ isAnnual, setIsAnnual }) {
  return (
    <div className="flex items-center justify-center">
      <div className="relative flex items-center p-1.5 bg-[#0D0E15]/60 backdrop-blur-xl border border-white/5 rounded-full shadow-[inset_0_4px_20px_rgba(0,0,0,0.5)]">
        {/* Active background pill */}
        <div
          className={`absolute h-[calc(100%-12px)] w-[calc(50%-6px)] rounded-full bg-gradient-to-r from-[#9810FA] to-[#AD46FF] shadow-[0_0_25px_rgba(152,16,250,0.5)] transition-transform duration-500 cubic-bezier(0.4, 0, 0.2, 1) ${
            isAnnual ? "translate-x-[100%]" : "translate-x-0"
          }`}
        ></div>

        {/* Monthly Button */}
        <button
          onClick={() => setIsAnnual(false)}
          className={`relative z-10 w-40 py-3 text-sm font-semibold rounded-full transition-all duration-500 cursor-pointer flex items-center justify-center ${
            !isAnnual ? "text-white drop-shadow-md" : "text-[#9CA3AF] hover:text-white"
          }`}
        >
          Monthly
        </button>

        {/* Yearly Button */}
        <button
          onClick={() => setIsAnnual(true)}
          className={`relative z-10 w-40 py-3 text-sm font-semibold rounded-full transition-all duration-500 cursor-pointer flex items-center justify-center gap-2 ${
            isAnnual ? "text-white drop-shadow-md" : "text-[#9CA3AF] hover:text-white"
          }`}
        >
          Yearly
          <span
            className={`text-[10px] px-2 py-0.5 rounded-full border transition-all duration-500 ${
              isAnnual
                ? "bg-white/20 border-white/20 text-white"
                : "bg-[#9810FA]/10 border-[#9810FA]/30 text-[#AD46FF]"
            }`}
          >
            Save 10%
          </span>
        </button>
      </div>
    </div>
  );
}