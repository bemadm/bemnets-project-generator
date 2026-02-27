import type { Config } from 'tailwindcss'

export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'primary-deep': '#0A2A44',
        'primary-medium': '#1E4A6F',
        'primary-bright': '#2E8B8B',
        'primary-accent': '#40E0D0',
        'background-deep': '#0B1A2A',
        'background-surface': '#122B3F',
        'background-elevated': '#1C3F54',
        'accent-warm': '#FF7F50',
        'accent-gold': '#DAA520',
        'accent-sand': '#F4A460',
        'status-success': '#2E8B8B',
        'status-warning': '#FF8C42',
        'status-error': '#D64C4C',
        'status-info': '#4A90E2',
        'text-primary': '#FFFFFF',
        'text-secondary': '#B0E0E6',
        'text-tertiary': '#7A9EB3',
        'text-on-dark': '#E6F3FF',
        'text-on-light': '#0A2A44',
        'glass-border': 'rgba(64, 224, 208, 0.15)',
        'glass-highlight': 'rgba(64, 224, 208, 0.05)',
        'glass-background': 'rgba(18, 43, 63, 0.7)',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
    },
  },
  plugins: [],
} satisfies Config
