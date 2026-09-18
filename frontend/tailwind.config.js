/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f8f9ff',
          100: '#f0f3ff',
          200: '#e1e8ff',
          300: '#c8d5ff',
          400: '#a8b8ff',
          500: '#7c8cff',
          600: '#5563f5',
          700: '#3f46e5',
          800: '#2e3ab8',
          900: '#1f2680',
        },
      },
      fontFamily: {
        sans: ['system-ui', 'sans-serif'],
      },
      borderRadius: {
        lg: '0.5rem',
      },
    },
  },
  plugins: [],
};
