"use client";
import React, { useState, useEffect } from "react";
import { FiX, FiMenu } from "react-icons/fi";
import { FaWhatsapp, FaFacebookF, FaInstagram, FaLinkedinIn } from "react-icons/fa";
import { motion, AnimatePresence } from "framer-motion";
import Image from "next/image";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import Container from "../Container";
import Cookies from "js-cookie";

const navitems = [
  { name: "Home", href: "home", isRoute: false },
  { name: "Features", href: "feature", isRoute: false },
  { name: "Pricing", href: "pricing", isRoute: false },
  { name: "FAQ", href: "faq", isRoute: false },
];

const Navbar = () => {
  const [open, setOpen] = useState(false);
  const [activeSection, setActiveSection] = useState("");
  const [userName, setUserName] = useState(null);
  const [userImage, setUserImage] = useState(null);
  const [showDropdown, setShowDropdown] = useState(false);
  
  const pathname = usePathname();
  const router = useRouter();

  const formatName = (name) => {
    if (!name) return "";
    const words = name.split(" ");
    if (words.length > 2) {
      return `${words[0]} ${words[1]}...`;
    }
    return name;
  };

  const handleLogout = () => {
    Cookies.remove("accessToken");
    Cookies.remove("refreshToken");
    Cookies.remove("userRole");
    Cookies.remove("userName");
    Cookies.remove("userImage");
    Cookies.remove("businessId");
    setUserName(null);
    setUserImage(null);
    setShowDropdown(false);
    router.push("/signin");
  };

  useEffect(() => {
    // Check auth state
    const name = Cookies.get("userName");
    const image = Cookies.get("userImage");
    if (name) setUserName(name);
    if (image) setUserImage(image);

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
                src="/OmnirraAI.png"
                alt="Logo"
                width={250}
                height={50}
                className="h-12 w-auto object-contain"
              />

              
            </motion.div>
          </Link>

          {/* Mobile Menu Button */}
          <button
            className="lg:hidden text-3xl cursor-pointer p-2 rounded-xl bg-gradient-to-r from-[#9810FA] to-[#AD46FF] transition-colors"
            onClick={() => setOpen(!open)}
            aria-label="Toggle menu"
          >
            {open ? <FiX /> : <FiMenu />}
          </button>
          {/* Desktop Menu */}
          <ul className="hidden lg:flex items-center justify-end gap-1 ">
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

          <div className="hidden lg:flex items-center gap-6">
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

            <motion.div
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              className="relative"
            >
            {userName ? (
              <div className="relative">
                <div 
                  onClick={() => setShowDropdown(!showDropdown)}
                  className="flex items-center gap-3 bg-white/5 border border-white/10 px-4 py-2.5 rounded-xl cursor-pointer hover:bg-white/10 transition-colors"
                >
                  {userImage ? (
                    <img src={userImage} alt={userName} className="w-8 h-8 rounded-full object-cover" />
                  ) : (
                    <div className="w-8 h-8 rounded-full bg-gradient-to-r from-[#9810FA] to-[#AD46FF] flex items-center justify-center text-white font-bold shadow-[0_0_10px_rgba(152,16,250,0.5)]">
                      {userName.charAt(0).toUpperCase()}
                    </div>
                  )}
                  <span className="text-white font-semibold text-sm font-inter tracking-wide select-none">{formatName(userName)}</span>
                </div>
                
                {/* Dropdown Menu */}
                <AnimatePresence>
                  {showDropdown && (
                    <motion.div 
                      initial={{ opacity: 0, y: 10 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: 10 }}
                      className="absolute right-0 mt-3 w-48 bg-[#1A1A1A] border border-white/10 rounded-xl shadow-[0_10px_30px_rgba(0,0,0,0.5)] overflow-hidden z-50"
                    >
                      <button 
                        onClick={handleLogout}
                        className="w-full text-left px-5 py-3.5 text-white hover:bg-[#EA2B33] transition-colors font-inter text-sm font-semibold"
                      >
                        Log out
                      </button>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            ) : (
              <Link href="/signin">
                <button className="bg-gradient-to-r from-[#9810FA] to-[#AD46FF] text-white font-bold text-base px-6 py-3 rounded-xl cursor-pointer shadow shadow-[#9810FA] hover:shadow-[#9810FA]/30 transition-shadow">
                 Sign In
                </button>
              </Link>
            )}
            </motion.div>
          </div>
        </motion.div>

        {/* Mobile Slide Menu */}
        <AnimatePresence>
          {open && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              className="lg:hidden absolute left-0 right-0 top-full w-full bg-[#000000] border-b border-white/80 shadow-[0_20px_50px_rgba(0,0,0,0.8)] overflow-hidden z-40"
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
                  {userName ? (
                    <div className="flex flex-col gap-3">
                      <div className="flex items-center gap-4 bg-white/5 border border-white/10 px-4 py-4 rounded-xl">
                        {userImage ? (
                          <img src={userImage} alt={userName} className="w-10 h-10 rounded-full object-cover" />
                        ) : (
                          <div className="w-10 h-10 rounded-full bg-gradient-to-r from-[#9810FA] to-[#AD46FF] flex items-center justify-center text-white font-bold text-lg shadow-[0_0_15px_rgba(152,16,250,0.5)]">
                            {userName.charAt(0).toUpperCase()}
                          </div>
                        )}
                        <span className="text-white font-semibold text-[17px] font-inter">{formatName(userName)}</span>
                      </div>
                      <button 
                        onClick={() => {
                          setOpen(false);
                          handleLogout();
                        }}
                        className="w-full bg-white/5 border border-white/10 text-white font-bold text-[17px] px-4 py-4 rounded-xl hover:bg-[#EA2B33] transition-all text-left"
                      >
                        Log out
                      </button>
                    </div>
                  ) : (
                    <Link href="/signin" onClick={() => setOpen(false)}>
                      <button className="bg-gradient-to-r from-[#9810FA] to-[#AD46FF] w-full text-white font-bold text-[17px] px-4 py-4 rounded-xl shadow-[0_0_20px_rgba(152,16,250,0.4)] hover:shadow-[0_0_30px_rgba(152,16,250,0.6)] transition-all">
                        Sign In
                      </button>
                    </Link>
                  )}
                </motion.div>
                
                <motion.div 
                  className="w-full pt-6 pb-2 flex items-center justify-center gap-4"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.3 }}
                >
                  <Link href="https://wa.me/97477631991" target="_blank" className="w-10 h-10 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white hover:bg-gradient-to-r hover:from-[#9810FA] hover:to-[#AD46FF] hover:border-transparent transition-all shadow-lg hover:shadow-[0_0_15px_rgba(152,16,250,0.5)]">
                    <FaWhatsapp size={18} />
                  </Link>
                  <Link href="#" className="w-10 h-10 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white hover:bg-gradient-to-r hover:from-[#9810FA] hover:to-[#AD46FF] hover:border-transparent transition-all shadow-lg hover:shadow-[0_0_15px_rgba(152,16,250,0.5)]">
                    <FaFacebookF size={18} />
                  </Link>
                  <Link href="#" className="w-10 h-10 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white hover:bg-gradient-to-r hover:from-[#9810FA] hover:to-[#AD46FF] hover:border-transparent transition-all shadow-lg hover:shadow-[0_0_15px_rgba(152,16,250,0.5)]">
                    <FaInstagram size={18} />
                  </Link>
                  <Link href="#" className="w-10 h-10 rounded-full bg-white/5 border border-white/10 flex items-center justify-center text-white hover:bg-gradient-to-r hover:from-[#9810FA] hover:to-[#AD46FF] hover:border-transparent transition-all shadow-lg hover:shadow-[0_0_15px_rgba(152,16,250,0.5)]">
                    <FaLinkedinIn size={18} />
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
