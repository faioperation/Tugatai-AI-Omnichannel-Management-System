import React from 'react'
import Home from '../(landing page)/Home'
import HowItWorks from '../(landing page)/HowItWorks'
import FAQ from '../(landing page)/FAQ'
import Call from '../(landing page)/Call'
import Features from '../(landing page)/Features'
import Pricing from '../(landing page)/Pricing'
import Testimonial from '../(landing page)/Testimonial'
import Stats from '../(landing page)/Stats'

const page = () => {
  return (
    <div>
      <Home />
      <HowItWorks />
      <Call />
      <Features />
      <Stats />
      <Pricing />
      <FAQ />
      <Testimonial />
    </div>
  )
}

export default page
