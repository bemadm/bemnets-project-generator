import React from 'react';
import { motion, type HTMLMotionProps } from 'framer-motion';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface ButtonProps extends HTMLMotionProps<"button"> {
  variant?: 'primary' | 'secondary' | 'glass' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
}

const Button: React.FC<ButtonProps> = ({ 
  children, 
  className, 
  variant = 'primary', 
  size = 'md',
  isLoading,
  ...props 
}) => {
  const baseStyles = "relative flex items-center justify-center gap-2 rounded-xl font-bold transition-all active:scale-95 disabled:opacity-50 disabled:pointer-events-none overflow-hidden group";
  
  const variants = {
    primary: "bg-gradient-to-r from-primary-bright to-primary-accent text-white shadow-lg shadow-primary-bright/20 hover:shadow-primary-bright/40",
    secondary: "bg-background-elevated border border-glass-border text-text-secondary hover:text-white hover:border-primary-accent",
    glass: "glass text-text-tertiary hover:text-white hover:border-primary-bright/50",
    ghost: "text-text-tertiary hover:text-white hover:bg-white/5"
  };

  const sizes = {
    sm: "px-4 py-2 text-[10px] uppercase tracking-widest",
    md: "px-6 py-3 text-sm",
    lg: "px-8 py-4 text-lg"
  };

  return (
    <motion.button
      whileHover={{ y: -2 }}
      className={cn(baseStyles, variants[variant], sizes[size], className)}
      role="button"
      aria-busy={isLoading}
      {...props}
    >
      <div className="absolute inset-0 bg-white/10 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none" />
      {isLoading ? (
        <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
      ) : (children as React.ReactNode)}
    </motion.button>
  );
};

export default Button;
