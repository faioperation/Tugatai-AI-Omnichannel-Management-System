import React from 'react'

const layout = ({children}) => {
  return (
    <div className='min-h-screen bg-gradient-to-b from-[#000000]/80 to-[#3C0366]/80'>
        {children}
        </div>
  )
}

export default layout