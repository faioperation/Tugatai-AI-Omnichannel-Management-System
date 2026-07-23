import React from "react";
import { IoArrowBack } from "react-icons/io5";
import { MdOutlineEmail, MdOutlinePhone } from "react-icons/md";
import Link from "next/link";

const Privacy = () => {
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

        <span className="text-[#DBDBDB]">
          Hello!! Welcome to Omnirra AI
        </span>

        <div className="flex items-center gap-2 sm:gap-6">
          <span className="flex items-center gap-1 text-[#DBDBDB]">
            <MdOutlineEmail className="w-4 h-4" />
            <span className="">info@omnirraai.com</span>
          </span>
          <span className="flex items-center gap-1 text-[#DBDBDB]">
            <MdOutlinePhone className="w-4 h-4" />
            <span className="">+974 7796 9600</span>
          </span>
        </div>
      </div>

      {/* Content */}
      <div className="w-full px-4 sm:px-8 pt-12 pb-24 mx-auto">
        <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold bg-gradient-to-r from-[#E9D4FF] to-[#FFFFFF] bg-clip-text text-transparent mb-6">
          Privacy Policy
        </h1>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Welcome to Omnirra AI. Your privacy is important to us. This Privacy Policy explains how Omnirra AI collects, uses, stores, and protects your information when you use our platform.
          <br />
          Omnirra AI is a product of Matrix Trading & Services W.L.L.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          1. Information We Collect
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We may collect the following information:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Account information (name, email address, phone number)</li>
          <li>Company information</li>
          <li>Connected social media account information</li>
          <li>Google Calendar information (only after your authorization)</li>
          <li>WhatsApp Business account information</li>
          <li>Facebook and Instagram account information</li>
          <li>Messages and conversations processed through the platform</li>
          <li>Usage statistics and analytics</li>
          <li>Device and browser information</li>
          <li>Log files and security information</li>
        </ul>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          2. How We Use Your Information
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We use your information to:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Provide Omnirra AI services</li>
          <li>Connect your messaging channels</li>
          <li>Manage customer conversations</li>
          <li>Create and manage Google Calendar events</li>
          <li>Improve platform performance</li>
          <li>Provide customer support</li>
          <li>Maintain platform security</li>
          <li>Comply with legal obligations</li>
        </ul>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          3. Google User Data
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          When you connect your Google Account, Omnirra AI may request access to your Google Calendar. Google Calendar information is used only to:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Create calendar events</li>
          <li>Update calendar events</li>
          <li>Delete calendar events</li>
          <li>Display calendar information requested by you</li>
        </ul>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We do not read or use your calendar for advertising. We do not sell Google user data. We do not transfer Google user data to third parties except when required to provide the requested functionality or when legally required.
        </p>
        <h3 className="text-xl sm:text-2xl lg:text-3xl font-bold text-[#E9D4FF] mb-3 mt-6">
          Google API Services Compliance
        </h3>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          <strong>Google API Services User Data Policy</strong><br />
          Omnirra AI's use and transfer of information received from Google APIs will comply with the <a href="https://developers.google.com/terms/api-services-user-data-policy" target="_blank" rel="noopener noreferrer" className="hover:text-white transition-colors underline">Google API Services User Data Policy</a>, including the Limited Use requirements.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Google Calendar data is accessed only for the purpose of providing the functionality requested by the user, including creating, updating, displaying, and deleting calendar events. Omnirra AI does not use Google user data for advertising, marketing, or profiling purposes.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We do not sell Google user data. We do not share Google user data with third parties except when necessary to provide the requested functionality, comply with applicable law, or protect our legal rights.
        </p>
        <h3 className="text-xl sm:text-2xl lg:text-3xl font-bold text-[#E9D4FF] mb-3 mt-6">
          Revoking Google Access
        </h3>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Users may revoke Omnirra AI's access to their Google Account at any time by visiting their Google Account Security settings under Third-party apps with account access.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Once access is revoked, Omnirra AI will no longer be able to access or modify the user's Google Calendar until authorization is granted again.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          4. Third-Party Integrations
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Omnirra AI integrates with services including:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Google</li>
          <li>Meta (Facebook & Instagram)</li>
          <li>WhatsApp Business Platform</li>
          <li>OpenAI</li>
          <li>Other communication platforms connected by the user</li>
        </ul>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Each third-party service is governed by its own Privacy Policy.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          5. Data Sharing
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We do not sell your personal information. Information may only be shared:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>To provide requested services</li>
          <li>With service providers under confidentiality obligations</li>
          <li>When required by law</li>
          <li>To protect our legal rights</li>
        </ul>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          6. Data Security
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We implement industry-standard security measures including:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Encryption</li>
          <li>Secure authentication</li>
          <li>Access controls</li>
          <li>Server monitoring</li>
          <li>Secure cloud infrastructure</li>
        </ul>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Although we strive to protect your data, no internet transmission can be guaranteed to be 100% secure.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          7. Data Retention
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We retain your information only as long as necessary to:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Provide services</li>
          <li>Meet legal obligations</li>
          <li>Resolve disputes</li>
          <li>Enforce agreements</li>
        </ul>
        <h3 className="text-xl sm:text-2xl lg:text-3xl font-bold text-[#E9D4FF] mb-3 mt-6">
          Google Calendar Data Retention
        </h3>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Google Calendar information is retained only for as long as necessary to provide the requested scheduling functionality and maintain synchronization between Omnirra AI and the user's Google Calendar.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Omnirra AI stores only the minimum information required for platform functionality. Google Calendar data is never used for advertising or unrelated purposes.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          8. Cookies
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Omnirra AI uses cookies to:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Maintain login sessions</li>
          <li>Improve user experience</li>
          <li>Analyze website usage</li>
          <li>Enhance security</li>
        </ul>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          9. Your Rights
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Depending on your jurisdiction, you may request to:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Access your information</li>
          <li>Correct inaccurate information</li>
          <li>Delete your information</li>
          <li>Export your data</li>
          <li>Withdraw consent</li>
        </ul>
        <h3 className="text-xl sm:text-2xl lg:text-3xl font-bold text-[#E9D4FF] mb-3 mt-6">
          Data Deletion Requests
        </h3>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Users may request deletion of their personal information and Google-related data by contacting <a href="mailto:info@omnirraai.com" className="hover:text-white transition-colors underline">info@omnirraai.com</a>.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Upon verification of the request, Omnirra AI will delete the applicable data from its systems unless retention is required by applicable law or necessary for legitimate business purposes.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          10. Children's Privacy
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Omnirra AI is not intended for individuals under 18 years of age.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          11. Changes to This Privacy Policy
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We may update this Privacy Policy from time to time. The updated version will always display the latest revision date.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          12. Contact Us
        </h2>
        <div className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-4">
          <p>
            <strong className="text-white block mb-1">Omnirra AI</strong>
          </p>
          <p>
            <strong className="text-white mr-2">Website:</strong> 
            <a href="https://omnirraai.com" target="_blank" rel="noopener noreferrer" className="hover:text-white transition-colors">https://omnirraai.com</a>
          </p>
          <p>
            <strong className="text-white mr-2">Support Email:</strong> 
            <a href="mailto:info@omnirraai.com" className="hover:text-white transition-colors">info@omnirraai.com</a>
          </p>
          <p>
            <strong className="text-white mr-2">Company:</strong> 
            <span>Matrix Trading & Services W.L.L.</span>
          </p>
        </div>

        <div className="mt-12 text-[#99A1AF] text-base sm:text-lg">
          <p>Effective Date: July 2026</p>
          <p>Last Updated: July 2026</p>
        </div>
      </div>
    </div>
  );
};

export default Privacy;
