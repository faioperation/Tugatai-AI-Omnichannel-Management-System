import React from 'react'

const InputField = ({
  label,
  className,
  placeholder,
  inputClass,
  labelClass,
  value,
  onChange,
  type
}) => {
  return (
    <div className={`flex flex-col w-full gap-2 ${className}`}>
      <label className={`font-inter  text-[#000000]  ${labelClass}`}>
        {label}
      </label>

      <input
        type={type}
        placeholder={placeholder}
        value={value}           
        onChange={onChange}     
        className={`border border-[#D1D5DC]  outline-none p-4 text-[#000000] placeholder:text-[#0A0A0A]/50 rounded-2xl ${inputClass}`}
      />
    </div>
  );
}

export default InputField;

