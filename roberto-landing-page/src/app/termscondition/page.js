import React from "react";
import { IoArrowBack } from "react-icons/io5";
import { MdOutlineEmail, MdOutlinePhone } from "react-icons/md";
import Link from "next/link";

const page = () => {
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
          Terms & Conditions
        </h1>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Welcome to Omnirra AI.
          <br />
          By accessing or using Omnirra AI, you agree to these Terms & Conditions.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          1. Acceptance of Terms
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          By creating an account or using our platform, you agree to comply with these Terms. If you do not agree, you should not use the platform.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          2. About Omnirra AI
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Omnirra AI is an omnichannel AI platform developed by Matrix Trading & Services W.L.L. The platform helps businesses manage:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>WhatsApp</li>
          <li>Facebook Messenger</li>
          <li>Instagram</li>
          <li>Google Calendar</li>
          <li>AI-powered customer conversations</li>
          <li>CRM workflows</li>
          <li>Customer support automation</li>
        </ul>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          3. Subscription & Billing
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Omnirra AI is offered through subscription-based plans. Subscription fees are billed according to the selected monthly or yearly plan.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Payments are securely processed through our authorized payment providers, including Stripe.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Subscription pricing may be updated from time to time. Existing customers will be notified of any applicable pricing changes before renewal where required by law.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Customers are responsible for providing accurate billing information and ensuring timely payment of subscription fees.
        </p>

        <h3 className="text-xl sm:text-2xl lg:text-3xl font-bold text-[#E9D4FF] mb-3 mt-6">
          Cancellation & Refund Policy
        </h3>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Customers may cancel their subscription at any time through their account settings or by contacting Omnirra AI support.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Unless otherwise required by applicable law or agreed in writing, subscription fees already paid are non-refundable.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Cancellation prevents future renewals but does not automatically entitle the customer to a refund for the current billing period.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          3. User Responsibilities
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          You agree to:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Provide accurate information</li>
          <li>Keep your login credentials secure</li>
          <li>Use the platform lawfully</li>
          <li>Respect third-party platform policies</li>
          <li>Avoid misuse of the service</li>
        </ul>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          8. Prohibited Activities
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Users must not:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Use the platform for illegal activities</li>
          <li>Send spam</li>
          <li>Distribute malware</li>
          <li>Attempt unauthorized access</li>
          <li>Interfere with platform security</li>
          <li>Violate intellectual property rights</li>
        </ul>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          5. Third-Party Services
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Omnirra AI integrates with third-party platforms including Google, Meta (Facebook and Instagram), WhatsApp Business Platform, OpenAI, Stripe, and other supported services.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          The availability and functionality of these integrations depend on the respective third-party providers.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Omnirra AI is not responsible for interruptions, service outages, API changes, or policy changes introduced by third-party platforms.
        </p>
        
        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          AI Services Disclaimer
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Omnirra AI provides AI-generated content, recommendations, and automated responses using artificial intelligence technologies.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          While we strive to provide accurate and reliable AI-generated outputs, such content may not always be complete, accurate, or suitable for every situation.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Customers remain responsible for reviewing AI-generated content before relying on or using it for business decisions or customer communications.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          9. Intellectual Property
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          All software, branding, content, logos, and technology remain the property of Omnirra AI and Matrix Trading & Services W.L.L.
          <br />
          Users may not copy, modify, or distribute platform content without written permission.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          10. Availability
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We strive to maintain high service availability. However, uninterrupted service cannot be guaranteed. Maintenance, upgrades, or third-party outages may temporarily affect availability.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          11. Limitation of Liability
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          To the maximum extent permitted by law, Omnirra AI shall not be liable for:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Business interruption</li>
          <li>Data loss</li>
          <li>Lost profits</li>
          <li>Third-party platform failures</li>
          <li>Indirect or consequential damages</li>
        </ul>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          12. Termination
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We may suspend or terminate accounts that:
        </p>
        <ul className="list-disc list-inside text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4 space-y-2 ml-2 sm:ml-4">
          <li>Violate these Terms</li>
          <li>Abuse the platform</li>
          <li>Engage in fraudulent activities</li>
          <li>Present security risks</li>
        </ul>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          10. Governing Law
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          These Terms and Conditions shall be governed by and construed in accordance with the laws of the State of Qatar.
        </p>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          Any disputes arising from or relating to these Terms or the use of Omnirra AI shall be subject to the exclusive jurisdiction of the competent courts of the State of Qatar.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          14. Changes to These Terms
        </h2>
        <p className="text-[#DBDBDB] text-lg sm:text-xl lg:text-2xl leading-relaxed mb-4">
          We may update these Terms from time to time. Continued use of the platform constitutes acceptance of the updated Terms.
        </p>

        <hr className="border-[#DBDBDB]/30 my-8" />

        <h2 className="text-2xl sm:text-3xl lg:text-4xl font-bold text-[#E9D4FF] mb-4">
          15. Contact Us
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

export default page;
