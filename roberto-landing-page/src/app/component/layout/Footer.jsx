"use client";
import React from 'react';
import Container from '../Container';
import Image from 'next/image';
import Link from 'next/link';
import { FaWhatsapp, FaFacebookF, FaInstagram, FaLinkedinIn } from 'react-icons/fa';
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
                {/* <div className="w-12 h-12 rounded-xl bg-[#EB232D] flex items-center justify-center p-1.5 shadow-lg shadow-red-500/20"> */}
                  <Image
                    src="/OmnirraAI.png"
                    alt="Logo"
                    width={250}
                    height={50}
                    className="h-full w-auto object-contain"
                  />
              
                
              </div>
            </Link>
            
            <p className="text-sm font-inter text-[#DEDEDE] pr-4 leading-relaxed max-w-sm">
              AI Voice & Chat Agent for businesses. Automate customer conversations, bookings, and operations 24/7.
            </p>

            <div className="flex items-center gap-3">
              <Link href="https://wa.me/97477631991" target="_blank" className="w-9 h-9 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white hover:bg-gradient-to-r hover:from-[#9810FA] hover:to-[#AD46FF] hover:border-transparent transition-all shadow-lg hover:shadow-[0_0_15px_rgba(152,16,250,0.5)]">
                <FaWhatsapp size={16} />
              </Link>
              <Link href="https://www.facebook.com/tugataicargo" className="w-9 h-9 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white hover:bg-gradient-to-r hover:from-[#9810FA] hover:to-[#AD46FF] hover:border-transparent transition-all shadow-lg hover:shadow-[0_0_15px_rgba(152,16,250,0.5)]">
                <FaFacebookF size={16} />
              </Link>
              <Link href="https://www.instagram.com/tugataicago" className="w-9 h-9 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white hover:bg-gradient-to-r hover:from-[#9810FA] hover:to-[#AD46FF] hover:border-transparent transition-all shadow-lg hover:shadow-[0_0_15px_rgba(152,16,250,0.5)]">
                <FaInstagram size={16} />
              </Link>
              <Link href="#" className="w-9 h-9 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white hover:bg-gradient-to-r hover:from-[#9810FA] hover:to-[#AD46FF] hover:border-transparent transition-all shadow-lg hover:shadow-[0_0_15px_rgba(152,16,250,0.5)]">
                <FaLinkedinIn size={16} />
              </Link>
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
            <Link href="/termscondition" className="text-sm font-inter text-[#CDCDCD] hover:text-[#AD46FF] transition-colors">Terms & Conditions</Link>
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
            © {new Date().getFullYear()} Omnirra AI. All rights reserved.
          </p>
        </motion.div>
      </Container>
    </footer>
  );
};

export default Footer;