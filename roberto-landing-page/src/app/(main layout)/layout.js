import React from 'react';
import Navbar from '../component/layout/Navbar';
import Footer from '../component/layout/Footer';

export default function MainLayout({ children }) {
  return (
    <>
      <Navbar />
      {children}
      <Footer />
    </>
  );
}
