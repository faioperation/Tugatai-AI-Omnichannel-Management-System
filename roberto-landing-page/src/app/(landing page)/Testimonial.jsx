'use client';
import React from 'react';
import Container from '../component/Container';
import Header from '../component/Header';
import { FaStar, FaQuoteLeft } from 'react-icons/fa';
import { Swiper, SwiperSlide } from 'swiper/react';
import { Autoplay } from 'swiper/modules';
import { motion } from 'framer-motion';
import 'swiper/css';

const testimonialsData = [
  {
    id: 1,
    review: "\"We reduced manual workload by 70% and increased bookings instantly.\"",
    name: "Rahman Ahmed",
    role: "Owner, Cargo Logistics"
  },
  {
    id: 2,
    review: "\"Our response time is now instant — and customers love it.\"",
    name: "Sadia Khan",
    role: "Manager, Urban Bites"
  },
  {
    id: 3,
    review: "\"Every chat now turns into a potential booking.\"",
    name: "Imran Hossain",
    role: "Founder, Home Service Pro"
  },
  {
    id: 4,
    review: "\"We reduced manual workload by 70% and increased bookings instantly.\"",
    name: "Rahman Ahmed",
    role: "Owner, Cargo Logistics"
  },
  {
    id: 5,
    review: "\"Our response time is now instant — and customers love it.\"",
    name: "Sadia Khan",
    role: "Manager, Urban Bites"
  },
  {
    id: 6,
    review: "\"Every chat now turns into a potential booking.\"",
    name: "Imran Hossain",
    role: "Founder, Home Service Pro"
  }
];

const Testimonial = () => {
  return (
    <section className="py-10 bg-[#050505] relative" id="testimonials">
      <Container>
        {/* Header Section */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: false }}
          transition={{ duration: 0.6 }}
          className="flex flex-col items-center text-center mb-24"
        >
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full border border-purple-500/20 bg-[#1A1A2E] mb-6">
            <FaStar className="text-[#AD46FF] text-sm" />
            <span className="text-sm text-purple-300 font-medium">Client Success Stories</span>
          </div>
          <Header
            className="text-center"
            titleText="Trusted by Businesses That Want More Bookings"
            subtitleText="See how businesses are turning conversations into revenue using our AI system."
          />
        </motion.div>

        {/* Cards Slider */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: false }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="mb-20 mt-10"
        >
          <Swiper
            modules={[Autoplay]}
            spaceBetween={30}
            slidesPerView={1}
            loop={true}
            autoplay={{
              delay: 3000,
              disableOnInteraction: false,
              pauseOnMouseEnter: true,
            }}
            breakpoints={{
              768: {
                slidesPerView: 2,
              },
              1024: {
                slidesPerView: 3,
              },
            }}
            className="pb-12 !pt-6"
          >
            {testimonialsData.map((testimonial) => (
              <SwiperSlide key={testimonial.id} className="h-auto">
                <div className="relative bg-gradient-to-br from-[#1A1A2E]/80 to-[#0F0F1A]/80 border border-[#AD46FF33] rounded-2xl p-8 pt-10 hover:border-[#AD46FF66] transition-colors duration-300 h-full mt-6">
                  {/* Quote Icon */}
                  <div className="absolute -top-6 left-8 w-12 h-12 rounded-full bg-gradient-to-br from-[#9810FA] to-[#AD46FF] flex items-center justify-center shadow-[0_0_30px_rgba(152,16,250,0.6)]">
                    <FaQuoteLeft className="text-white text-xl rotate-180" />
                  </div>

                  {/* Stars */}
                  <div className="flex gap-1.5 mb-6">
                    {[...Array(5)].map((_, i) => (
                      <FaStar key={i} className="text-[#C27AFF] text-xl" />
                    ))}
                  </div>

                  {/* Review */}
                  <p className="text-white text-lg leading-relaxed font-medium min-h-[100px]">
                    {testimonial.review}
                  </p>

                  {/* Divider */}
                  <div className="w-full h-[1px] bg-white/10 my-8"></div>

                  {/* Author Info */}
                  <div>
                    <h4 className="text-white font-bold text-lg mb-1">{testimonial.name}</h4>
                    <p className="text-[#C27AFF] text-sm">{testimonial.role}</p>
                  </div>
                </div>
              </SwiperSlide>
            ))}
          </Swiper>
        </motion.div>

        {/* Footer CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: false }}
          transition={{ duration: 0.6, delay: 0.4 }}
          className="flex flex-col items-center text-center"
        >
          <p className="text-[#9CA3AF] mb-6 text-lg">Ready to see similar results for your business?</p>
          <button className="bg-gradient-to-r from-[#9810FA] to-[#AD46FF] px-8 py-3.5 rounded-full text-white font-bold text-lg shadow-[0_0_30px_rgba(152,16,250,0.5)] hover:scale-105 transition-transform duration-300">
            Book Live Demo
          </button>
        </motion.div>
      </Container>
    </section>
  );
};

export default Testimonial;