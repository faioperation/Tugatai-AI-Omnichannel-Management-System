"use client"
import React, { useState } from 'react'
import Header from '../component/Header'
import Container from '../component/Container'
import { FiCheck } from 'react-icons/fi'
import { motion } from 'framer-motion'
import { useQuery, useMutation } from '@tanstack/react-query'
import Cookies from 'js-cookie'
import { toast } from 'react-hot-toast'

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

// Mock data removed in favor of API

const Pricing = () => {
  const [processingPlanId, setProcessingPlanId] = useState(null);

  const { data: plans, isLoading, error } = useQuery({
    queryKey: ['subscriptionPlans'],
    queryFn: async () => {
      const baseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1';
      const res = await fetch(`${baseUrl}/public/subscription-plans`, {
        headers: {
          'ngrok-skip-browser-warning': 'true'
        }
      });
      if (!res.ok) {
        throw new Error('Failed to fetch plans');
      }
      const json = await res.json();
      return json.data;
    }
  });

  const checkoutMutation = useMutation({
    mutationFn: async (data) => {
      const baseUrl = process.env.NEXT_PUBLIC_API_URL;
      const token = Cookies.get("accessToken");
      if (!token) throw new Error("Please log in to upgrade your plan.");

      const res = await fetch(`${baseUrl}/payment/create-checkout-session`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'ngrok-skip-browser-warning': 'true'
        },
        body: JSON.stringify(data)
      });
      if (!res.ok) {
        throw new Error('Failed to create checkout session');
      }
      return res.json();
    },
    onSuccess: (response) => {
      if (response.data && response.data.url) {
         window.location.href = response.data.url;
      } else if (response.url) {
         window.location.href = response.url;
      } else {
         toast.error("Checkout URL not found");
      }
    },
    onError: (err) => {
      toast.error(err.message);
      setProcessingPlanId(null);
    },
    onSettled: () => {
      // Re-enable if there is a failure or if redirect takes time
      // But if successful redirect happens, it doesn't matter
    }
  });

  const getIcon = (idx) => idx === 0 ? <HalfMoonIcon /> : <FullMoonIcon />;

  // Sort plans if needed based on sortOrder, though API already returns sorted likely
  const sortedPlans = plans?.slice().sort((a, b) => a.sortOrder - b.sortOrder) || [];

  return (
    <section id='pricing' className="py-20 ">
      <Container>
        <Header
          titleText={`Simple, Scalable Pricing`}
          subtitleText={`Choose the plan that fits your business. Upgrade or downgrade anytime`}
        />

        {isLoading ? (
          <div className="flex justify-center items-center h-64 mt-10">
            <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-[#9810FA]"></div>
          </div>
        ) : error ? (
          <div className="text-center text-red-500 mt-10">
            Error loading plans: {error.message}
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 lg:gap-12 mt-16 lg:mt-24 mx-auto">
            {sortedPlans.map((plan, idx) => (
              <motion.div
                key={plan.id}
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
                    {getIcon(idx)}
                  </div>
                  <h3 className="text-2xl font-semibold text-white font-inter mb-2">
                    {plan.name}
                  </h3>
                  <p className="text-[#9CA3AF] text-sm font-inter group-hover:text-white/70 transition-colors">
                    {plan.description}
                  </p>
                  <div className="mt-6 flex items-baseline justify-center gap-1">
                    <span className="text-white text-5xl font-bold font-inter">${plan.monthlyPrice}</span>
                    <span className="text-[#9CA3AF] text-sm font-inter">/month</span>
                  </div>
                </div>

                <div className="flex-1">
                  <ul className="space-y-4 mt-8">
                    {plan.features.map((feature) => (
                      <li key={feature.id} className="flex items-center gap-3">
                        <FiCheck className="text-[#6A7282] text-lg shrink-0 group-hover:text-[#AD46FF] transition-colors" />
                        <span className="text-[#D1D5DC] text-sm font-inter group-hover:text-[#E5E7EB] transition-colors">
                          {feature.value}
                        </span>
                      </li>
                    ))}
                  </ul>
                </div>

                <button 
                  onClick={() => {
                    setProcessingPlanId(plan.id);
                    checkoutMutation.mutate({ planId: plan.id, billingCycle: "monthly" });
                  }}
                  disabled={checkoutMutation.isPending && processingPlanId === plan.id}
                  className={`mt-5 w-full py-4 rounded-xl text-white font-inter font-semibold bg-white/5 border border-white/10 group-hover:bg-gradient-to-r group-hover:from-[#9810FA] group-hover:to-[#AD46FF] group-hover:border-transparent transition-all duration-500 group-hover:shadow-[0_0_20px_rgba(173,70,255,0.4)] ${(checkoutMutation.isPending && processingPlanId === plan.id) ? 'opacity-70 cursor-not-allowed' : ''}`}>
                  {(checkoutMutation.isPending && processingPlanId === plan.id) ? 'Processing...' : 'Upgrade'}
                </button>
              </motion.div>
            ))}
          </div>
        )}
      </Container>
    </section>
  )
}

export default Pricing