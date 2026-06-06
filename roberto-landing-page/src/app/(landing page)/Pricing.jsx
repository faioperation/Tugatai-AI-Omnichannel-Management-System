"use client"
import React from 'react'
import Header from '../component/Header'
import Container from '../component/Container'
import { FiCheck } from 'react-icons/fi'
import { motion } from 'framer-motion'

const HalfMoonIcon = () => (
  <div className="transition-all duration-500 drop-shadow-none group-hover:drop-shadow-[0_0_15px_rgba(152,16,250,0.6)]">
    <div className='w-[56px] h-[56px] bg-[#D1CEFF] rounded-full'>
      <svg
        className="w-[56px] h-[56px]"
        viewBox="0 0 48 48"
        xmlns="http://www.w3.org/2000/svg"
      >
        <defs>
          <linearGradient id="moonGradient" x1="100%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#9810FA" />
            <stop offset="100%" stopColor="#4F46E5" />
          </linearGradient>
        </defs>

        <circle cx="24" cy="24" r="16" fill="#D1CEFF" />

        <path
          d="M24 8 A16 16 0 0 0 24 40 Z"
          fill="url(#moonGradient)"
        />
      </svg>
    </div>
  </div>
)

const FullMoonIcon = () => (
  <div className="w-[80px] h-[80px] flex items-center justify-center">
    <svg width="64" height="64" viewBox="0 0 48 48">
      <defs>
        {/* Gradient ring */}
        <linearGradient id="ringGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor="#9810FA" />
          <stop offset="100%" stopColor="#4F46E5" />
        </linearGradient>

        {/* Soft glow */}
        <filter id="glow">
          <feGaussianBlur stdDeviation="0" result="coloredBlur" />
          <feMerge>
            <feMergeNode in="coloredBlur" />
            <feMergeNode in="SourceGraphic" />
          </feMerge>
        </filter>
      </defs>

      {/* Outer circle */}
      <circle cx="24" cy="24" r="20" fill="#D1CEFF" />

      {/* Inner subtle fill */}
      <circle cx="24" cy="24" r="12" fill="#C7C3E6" />

      {/* Gradient ring */}
      <circle
        cx="24"
        cy="24"
        r="14"
        fill="none"
        stroke="url(#ringGradient)"
        strokeWidth="3"
        filter="url(#glow)"
      />
    </svg>
  </div>
)

const pricingPlans = [
  {
    name: "CONNECT",
    description: "Best for businesses getting started with AI automation",
    price: "700",
    icon: <HalfMoonIcon />,
    features: [
      "2 Channels",
      "Up to 1,000 chats/month",
      "Shared inbox",
      "Basic AI instant replies",
      "Basic lead capture",
      "Basic booking form",
      "Limited analytics",
      "No advanced automation",
      "No campaigns",
      "No voice AI",
    ]
  },
  {
    name: "CONVERT",
    description: "Best for growing businesses that need more leads, bookings, and automation",
    price: "1250",
    icon: <FullMoonIcon />,
    features: [
      "Multi-channel",
      "Up to 5,000 chats/month",
      "Everything in CONNECT, plus:",
      "Advanced AI assistant",
      "CRM pipeline",
      "Full booking workflow",
      "Pricing engine",
      "Quote generation",
      "Workflow automation",
      "Chat summaries",
      "WhatsApp campaigns (basic)",
      "Analytics dashboard",
      "AI assist for agents",
    ]
  },
  {
    name: "CONTROL",
    description: "Best for high-volume teams and serious businesses",
    price: "2050",
    icon: <FullMoonIcon />,
    features: [
      "Unlimited or high-volume chats",
      "Everything in CONVERT, plus:",
      "Multi-branch / multi-country",
      "Advanced workflow automation",
      "Advanced campaigns",
      "API integrations",
      "Advanced analytics",
      "Dedicated onboarding",
      "Priority support",
      "Voice AI included or as premium add-on",
    ]
  }
]

const Pricing = () => {
  return (
    <section id='pricing' className="py-20 ">
      <Container>
        <Header
          titleText={`Simple, Scalable Pricing`}
          subtitleText={`Choose the plan that fits your business. Upgrade or downgrade anytime`}
        />

        <div className="grid grid-cols-1 md:grid-cols-3 gap-25 mt-35  mx-auto">
          {pricingPlans.map((plan, idx) => (
            <motion.div
              key={idx}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: false, margin: "-50px" }}
              transition={{ duration: 0.6, delay: idx * 0.15 }}
              className={`group relative flex flex-col px-8 py-8 rounded-4xl bg-[#12131C] border transition-all duration-500 hover:bg-gradient-to-r from-[#9810FA]/35  to-[#AD46FF]/35 hover:border-[#9810FA]/90 hover:shadow-[0_0_40px_rgba(173,70,255,0.2)] hover:-translate-y-10  border-white/5 ${idx === 1
                  ? "z-10 md:-mt-20"
                  : "border-white/5 z-0"
                }`}
            >
              <div className="flex flex-col items-center text-center mb-8">
                <div className="mb-4">
                  {plan.icon}
                </div>
                <h3 className="text-2xl font-semibold text-white font-inter mb-2">
                  {plan.name}
                </h3>
                <p className="text-[#9CA3AF] text-sm font-inter group-hover:text-white/70 transition-colors">
                  {plan.description}
                </p>
                <div className="mt-6 flex items-baseline justify-center gap-1">
                  <span className="text-white text-5xl font-bold font-inter">${plan.price}</span>
                  <span className="text-[#9CA3AF] text-sm font-inter">/month</span>
                </div>
              </div>

              <div className="flex-1">
                <ul className="space-y-4 mt-8">
                  {plan.features.map((feature, featureIdx) => (
                    <li key={featureIdx} className="flex items-center gap-3">
                      <FiCheck className="text-[#6A7282] text-lg shrink-0 group-hover:text-[#AD46FF] transition-colors" />
                      <span className="text-[#D1D5DC] text-smfont-inter group-hover:text-[#E5E7EB] transition-colors">
                        {feature}
                      </span>
                    </li>
                  ))}
                </ul>
              </div>

              <button className="mt-5 w-full py-4 rounded-xl text-white font-inter font-semibold bg-white/5 border border-white/10 group-hover:bg-gradient-to-r group-hover:from-[#9810FA] group-hover:to-[#AD46FF] group-hover:border-transparent transition-all duration-500 group-hover:shadow-[0_0_20px_rgba(173,70,255,0.4)] ">
                Upgrade
              </button>
            </motion.div>
          ))}
        </div>
      </Container>
    </section>
  )
}

export default Pricing