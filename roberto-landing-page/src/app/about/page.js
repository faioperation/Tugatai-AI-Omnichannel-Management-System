import React from 'react'
import { IoArrowBack } from 'react-icons/io5'
import { MdOutlineEmail, MdOutlinePhone } from 'react-icons/md'
import Link from 'next/link'

const About = () => {
  return (
    <div className="min-h-screen bg-black">

      {/* Top Info Bar */}
      <div className="w-full border-b border-[#DBDBDB] px-4 sm:px-8 py-3 flex items-center justify-between text-xs sm:text-sm text-[#DBDBDB]">
        <Link
          href="/"
          className="flex items-center justify-center w-8 h-8 sm:w-9 sm:h-9 rounded-full border border-[#DBDBDB] hover:bg-gray-100 transition-colors flex-shrink-0 group"
        >
          <IoArrowBack className="w-4 h-4 text-[#DBDBDB] group-hover:text-black" />
        </Link>

        <span className="text-[#DBDBDB]">Hello!! Welcome to Tufatai Cargo logistics</span>

        <div className="flex items-center gap-2 sm:gap-6">
          <span className="flex items-center gap-1 text-[#DBDBDB]">
            <MdOutlineEmail className="w-4 h-4" />
            <span className="">tugatai@gmail.com</span>
          </span>
          <span className="flex items-center gap-1 text-[#DBDBDB]">
            <MdOutlinePhone className="w-4 h-4" />
            <span className="">+757 699-4478</span>
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="w-full px-4 sm:px-8 pt-12 pb-24  mx-auto">
        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold bg-gradient-to-r from-[#E9D4FF] to-[#FFFFFF] bg-clip-text text-transparent mb-6">About Us</h1>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-12">
          We are building an AI-powered multi-channel automation platform designed to help
          businesses streamline communication, bookings, and operations.
        </p>

        <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold bg-gradient-to-r from-[#E9D4FF] to-[#FFFFFF] bg-clip-text text-transparent mb-6">Our Mission</h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Our mission is to simplify business operations through intelligent automation.
          We aim to help businesses:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-12 space-y-2 ml-2 sm:ml-4">
          <li>Respond instantly to customers</li>
          <li>Automate bookings and workflows</li>
          <li>Increase efficiency and revenue</li>
        </ul>

        <h2 className="text-3xl sm:text-4xl lg:text-5xl font-bold bg-gradient-to-r from-[#E9D4FF] to-[#FFFFFF] bg-clip-text text-transparent mb-6">Our Vision</h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed">
          We believe the future of business is automated, intelligent, and scalable.
          Our goal is to empower businesses of all sizes with tools that were previously only
          available to large enterprises.
        </p>
      </div>

    </div>
  )
}

export default About