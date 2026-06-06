"use client";
import React from 'react';
import Container from '../Container';
import Image from 'next/image';
import Link from 'next/link';
import { FiTwitter, FiLinkedin, FiGithub, FiMail } from 'react-icons/fi';
import { motion } from 'framer-motion';

const Footer = () => {
  return (
    <footer className="bg-gradient-to-t from-[#000000] via-[#3C0366]/30 to-[#000000] pt-16">
      <Container>
        <motion.div 
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: false }}
          transition={{ duration: 0.8 }}
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8 mb-12"
        >
          {/* Logo & Description */}
          <div className="lg:col-span-2 flex flex-col gap-6">
            <Link href="/">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-xl bg-[#EB232D] flex items-center justify-center p-1.5 shadow-lg shadow-red-500/20">
                  <Image
                    src="/logo.png"
                    alt="Logo"
                    width={48}
                    height={48}
                    className="h-full w-auto object-contain"
                  />
                </div>
                <div>
                  <p className="text-2xl font-bold text-[#EB232D] font-inter uppercase">
                      Tugatai
                  </p>
                  {/* <span className="text-xs font-inter text-[#1E8380]">
                      Cargo Logistics
                  </span> */}
                </div>
              </div>
            </Link>
            
            <p className="text-sm font-inter text-[#DEDEDE] pr-4 leading-relaxed max-w-sm">
              AI Voice & Chat Agent for businesses. Automate customer conversations, bookings, and operations 24/7.
            </p>

            <div className="flex items-center gap-4">
              <a href="#" className="w-10 h-10 rounded-xl bg-white/10 border border-white/10 flex items-center justify-center text-[#888888] hover:text-white hover:bg-white/10 transition-all">
                <FiTwitter className="w-5 h-5" />
              </a>
              <a href="#" className="w-10 h-10 rounded-xl bg-white/10 border border-white/10 flex items-center justify-center text-[#888888] hover:text-white hover:bg-white/10 transition-all">
                <FiLinkedin className="w-5 h-5" />
              </a>
              <a href="#" className="w-10 h-10 rounded-xl bg-white/10 border border-white/10 flex items-center justify-center text-[#888888] hover:text-white hover:bg-white/10 transition-all">
                <FiGithub className="w-5 h-5" />
              </a>
              <a href="#" className="w-10 h-10 rounded-xl bg-white/10 border border-white/10 flex items-center justify-center text-[#888888] hover:text-white hover:bg-white/10 transition-all">
                <FiMail className="w-5 h-5" />
              </a>
            </div>
          </div>

          {/* Links */}
          <div className="flex flex-col gap-4 ">
            <h4 className="text-white font-inter font-semibold mb-2">Product</h4>
            <Link href="#feature" className="text-sm font-inter text-[#CDCDCD] hover:text-[#AD46FF] transition-colors">Features</Link>
            <Link href="#pricing" className="text-sm font-inter text-[#CDCDCD] hover:text-[#AD46FF] transition-colors">Pricing</Link>
          </div>

          <div className="flex flex-col gap-4">
            <h4 className="text-white font-inter font-semibold mb-2">Company</h4>
            <Link href="/about" className="text-sm font-inter text-[#CDCDCD] hover:text-[#AD46FF] transition-colors">About</Link>
            <Link href="#contact" className="text-sm font-inter text-[#CDCDCD] hover:text-[#AD46FF] transition-colors">Contact</Link>
          </div>

          {/* <div className="flex flex-col gap-4">
            <h4 className="text-white font-inter font-semibold mb-2">Resources</h4>
            <Link href="#" className="text-sm font-inter text-[#CDCDCD] hover:text-[#AD46FF] transition-colors">Help Center</Link>
          </div> */}

          <div className="flex flex-col gap-4">
            <h4 className="text-white font-inter font-semibold mb-2">Legal</h4>
            <Link href="/privacy" className="text-sm font-inter text-[#CDCDCD] hover:text-[#AD46FF] transition-colors">Privacy Policy</Link>
            <Link href="/termscondition" className="text-sm font-inter text-[#CDCDCD] hover:text-[#AD46FF] transition-colors">Terms of Service</Link>
          </div>
        </motion.div>

        <motion.div 
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: false }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="py-8 border-t border-white/10"
        >
          <p className="text-sm font-inter text-[#99A1AF]">
            © {new Date().getFullYear()} Tugatai. All rights reserved.
          </p>
        </motion.div>
      </Container>
    </footer>
  );
};

export default Footer;