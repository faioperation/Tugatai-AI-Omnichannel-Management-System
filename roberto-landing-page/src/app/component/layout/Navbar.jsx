"use client";
import React, { useState, useEffect } from "react";
import { FiX, FiMenu } from "react-icons/fi";
import { motion, AnimatePresence } from "framer-motion";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import Container from "../Container";

const navitems = [
  { name: "Home", href: "home", isRoute: false },
  { name: "Features", href: "feature", isRoute: false },
  { name: "Pricing", href: "pricing", isRoute: false },
  { name: "FAQ", href: "faq", isRoute: false },
];

const Navbar = () => {
  const [open, setOpen] = useState(false);
  const [activeSection, setActiveSection] = useState("");
  const pathname = usePathname();
  const router = useRouter();

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setActiveSection(entry.target.id);
          }
        });
      },
      { rootMargin: "-30% 0px -70% 0px" }
    );

    
    setTimeout(() => {
      navitems.forEach((item) => {
        if (!item.isRoute) {
          const el = document.getElementById(item.href);
          if (el) observer.observe(el);
        }
      });
    }, 100);

    return () => observer.disconnect();
  }, [pathname]);

  const scrollToSection = (id, closeMenu = false) => {
    if (closeMenu) setOpen(false);

    const doScroll = () => {
      const el = document.getElementById(id);
      if (el) {
        el.scrollIntoView({ behavior: "smooth", block: "start" });
      }
    };

    if (pathname !== "/") {
      router.push(`/#${id}`);
    } else {
      
      setTimeout(doScroll, closeMenu ? 350 : 0);
    }
  };

  return (
    <div className="sticky top-0 z-[999] border-b border-white/80 w-full bg-[#000000]">
      <Container>
        <motion.div
          initial={{ y: -20, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          transition={{ duration: 0.6 }}
          className=" py-4 flex items-center justify-between "
        >

          <Link href="/" onClick={(e) => {
            if (pathname === "/") {
              e.preventDefault();
              scrollToSection("home");
            }
          }}>
            <motion.div 
            whileHover={{ scale: 1.05 }} 
            whileTap={{ scale: 0.95 }}
            className="flex items-center gap-4"
            >

              <Image
                src="/logo.png"
                alt="Logo"
                width={120}
                height={40}
                className="h-12 w-auto object-contain"
              />

              <div>
                <p className="text-2xl font-bold text-[#EB232D] font-inter">
                    TUGATAI
                </p>

                {/* <span className="text-xs font-marope text-[#1E8380]">
                    Cargo Logistics
                </span> */}
              </div>
            </motion.div>
          </Link>

          {/* Mobile Menu Button */}
          <button
            className="md:hidden text-3xl cursor-pointer p-2 rounded-xl bg-gradient-to-r from-[#9810FA] to-[#AD46FF] transition-colors"
            onClick={() => setOpen(!open)}
            aria-label="Toggle menu"
          >
            {open ? <FiX /> : <FiMenu />}
          </button>
          {/* Desktop Menu */}
          <ul className="hidden md:flex items-center justify-end gap-1 ">
            {navitems.map((item, index) => (
              <motion.li key={index} whileHover={{ y: -2 }}>
                {item.isRoute ? (
                  <Link
                    href={item.href}
                    className={`py-2 px-4 font-inter text-lg font-medium transition-colors rounded-lg cursor-pointer ${
                      activeSection === item.href
                        ? "text-[#AD46FF] "
                        : "text-white hover:text-[#AD46FF]"
                    }`}
                  >
                    {item.name}
                  </Link>
                ) : (
                  <button
                    onClick={() => scrollToSection(item.href)}
                    className={`py-2 px-4 font-inter text-lg font-medium transition-colors rounded-lg cursor-pointer ${
                      activeSection === item.href
                        ? "text-[#AD46FF]"
                        : "text-white hover:text-[#AD46FF]"
                    }`}
                  >
                    {item.name}
                  </button>
                )}
              </motion.li>
            ))}
          </ul>

          <motion.div
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="hidden md:block"
          >
            <Link href="/signup">
              <button className="bg-gradient-to-r from-[#9810FA] to-[#AD46FF] text-white font-bold text-base px-6 py-3 rounded-xl cursor-pointer shadow shadow-[#9810FA] hover:shadow-[#9810FA]/30 transition-shadow">
               Sign Up
              </button>
            </Link>
          </motion.div>
        </motion.div>

        {/* Mobile Slide Menu */}
        <AnimatePresence>
          {open && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              className="md:hidden absolute left-0 right-0 top-full w-full bg-[#000000] border-b border-white/80 shadow-[0_20px_50px_rgba(0,0,0,0.8)] overflow-hidden z-40"
            >
              <ul className="flex flex-col items-start gap-1 p-6 sm:px-8">
                {navitems.map((item, index) => (
                  <motion.li
                    key={index}
                    className="w-full"
                    initial={{ x: -20, opacity: 0 }}
                    animate={{ x: 0, opacity: 1 }}
                    transition={{ delay: index * 0.05 }}
                  >
                    {item.isRoute ? (
                      <Link
                        href={item.href}
                        onClick={() => setOpen(false)}
                        className={`py-3.5 px-4 font-inter text-[17px] font-medium block rounded-xl transition-all ${
                          activeSection === item.href
                            ? "text-white bg-gradient-to-r from-[#9810FA]/50 to-[#AD46FF]/50"
                            : "text-white hover:bg-gradient-to-r hover:from-[#9810FA]/50 hover:to-[#AD46FF]/50"
                        }`}
                      >
                        {item.name}
                      </Link>
                    ) : (
                      <button
                        onClick={() => scrollToSection(item.href, true)}
                        className={`py-3.5 px-4 font-inter text-[17px] font-medium block rounded-xl transition-all w-full text-left ${
                          activeSection === item.href
                            ? "text-white bg-gradient-to-r from-[#9810FA]/50 to-[#AD46FF]/50"
                            : "text-white hover:bg-gradient-to-r hover:from-[#9810FA]/50 hover:to-[#AD46FF]/50"
                        }`}
                      >
                        {item.name}
                      </button>
                    )}
                  </motion.li>
                ))}

                <motion.div
                  className="w-full pt-6 mt-2 border-t border-white/20"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.2 }}
                >
                  <Link href="/signup" onClick={() => setOpen(false)}>
                    <button className="bg-gradient-to-r from-[#9810FA] to-[#AD46FF] w-full text-white font-bold text-[17px] px-4 py-4 rounded-xl shadow-[0_0_20px_rgba(152,16,250,0.4)] hover:shadow-[0_0_30px_rgba(152,16,250,0.6)] transition-all">
                      Sign Up
                    </button>
                  </Link>
                </motion.div>
              </ul>
            </motion.div>
          )}
        </AnimatePresence>
      </Container>
    </div>
  );
};

export default Navbar;
