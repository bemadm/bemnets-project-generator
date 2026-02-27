import React from 'react';
import { motion } from 'framer-motion';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
  icon?: React.ReactNode;
}

const Input: React.FC<InputProps> = ({ 
  label, 
  error, 
  icon, 
  className, 
  ...props 
}) => {
  return (
    <div className="w-full space-y-2 group">
      <div className="relative">
        <motion.label 
          initial={false}
          className={cn(
            "absolute -top-2.5 left-3 bg-background-elevated px-2 text-[10px] font-black z-10 tracking-widest transition-all",
            error ? "text-status-error" : "text-text-tertiary group-focus-within:text-primary-accent"
          )}
        >
          {label.toUpperCase()}
        </motion.label>
        <div className="relative flex items-center">
          {icon && (
            <div className="absolute left-4 text-text-tertiary group-focus-within:text-primary-accent transition-colors">
              {icon}
            </div>
          )}
          <input
            className={cn(
              "w-full bg-background-deep/50 border border-glass-border rounded-xl px-4 py-4 text-xs font-mono tracking-widest text-white placeholder:text-text-tertiary/30 focus:outline-none focus:border-primary-accent/50 transition-all",
              icon && "pl-12",
              error && "border-status-error/50 focus:border-status-error",
              className
            )}
            {...props}
          />
        </div>
      </div>
      {error && (
        <motion.p 
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-[10px] font-bold text-status-error pl-2 uppercase tracking-tight"
        >
          {error}
        </motion.p>
      )}
    </div>
  );
};

export default Input;
