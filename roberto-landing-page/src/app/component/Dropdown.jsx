"use client";
import React, { useState, useEffect, useRef } from "react";
import { FaCaretDown, FaCaretUp } from "react-icons/fa";

const Dropdown = ({
  label = "",
  placeholder = "",
  options = [],
  onSelect,
  className,
  inputClass,
  spanClass,
  optionClass,
  labelClass,
  icon,
  value
}) => {
  const [selected, setSelected] = useState(value || "");

  useEffect(() => {
    if (value) {
      setSelected(value);
    }
  }, [value]);
  const [show, setShow] = useState(false);
  const dropdownRef = useRef(null);

  const handleSelect = (value) => {
    setSelected(value);
    setShow(false);
    if (onSelect) onSelect(value);
  };

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setShow(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  return (
    <div
      ref={dropdownRef}
      className={`flex flex-col gap-2   relative ${className}`}
    >
      {/* Label */}
      <label className={`font-inter text-[#000000]   ${labelClass}`}>
        {label}
       
      </label>

      {/* Input Box */}
      <div className="relative">
        <div onClick={() => setShow(!show)}>
          <input
            readOnly
            value={selected || ""}
            className={`w-full bg-transparent outline-none text-[#000000] border border-[#D1D5DC] p-4 rounded-lg  placeholder:text-[#0A0A0A]/50    cursor-pointer ${inputClass}`}
            placeholder={placeholder}
          />

          {/* Arrow Icon */}
          <div className={`w-6 h-6  flex items-center justify-center absolute top-1/2 -translate-y-1/2 right-6 text-[#000000]  ${icon}`}>
            {show ? <FaCaretUp /> : <FaCaretDown />}
          </div>
        </div>

        {/* Dropdown Menu */}
        <div
          className={`absolute left-0 top-[105%] w-full bg-white  border border-[#D1D5DC] rounded-md shadow-md  text-[#000000] z-30 transition-all duration-300 text-center overflow-y-scroll hide-scrollbar  ${optionClass} ${
            show
              ? "opacity-100 visible max-h-60 "
              : "opacity-0 invisible max-h-0 "
          }`}
        >
          {options.map((item, index) => (
            <div
              key={index}
              onClick={() => handleSelect(item)}
              className="py-2 hover:bg-[#EA2B33] hover:text-white cursor-pointer"
            >
              {item}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Dropdown;



