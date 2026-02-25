import React from 'react';
import { motion } from 'framer-motion';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

interface ToggleProps {
  label: string;
  icon?: React.ReactNode;
  checked: boolean;
  onChange: (checked: boolean) => void;
  description?: string;
}

const Toggle: React.FC<ToggleProps> = ({ 
  label, 
  icon, 
  checked, 
  onChange,
  description 
}) => {
  return (
    <motion.div 
      whileHover={{ x: 3 }}
      className="flex items-center justify-between p-4 rounded-2xl bg-background-deep/30 border border-glass-border hover:border-primary-accent/20 transition-all cursor-pointer"
      onClick={() => onChange(!checked)}
      role="switch"
      aria-checked={checked}
      tabIndex={0}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          onChange(!checked);
        }
      }}
    >
      <div className="flex items-center gap-4">
        {icon && (
          <div className={cn(
            "p-2 rounded-lg bg-background-surface/50 transition-colors",
            checked ? "text-primary-accent" : "text-text-tertiary"
          )}>
            {icon}
          </div>
        )}
        <div className="flex flex-col">
          <span className="text-[11px] font-bold text-text-secondary tracking-tight uppercase">{label}</span>
          {description && (
            <span className="text-[9px] text-text-tertiary opacity-60 leading-tight">{description}</span>
          )}
        </div>
      </div>
      <div 
        className={cn(
          "w-12 h-6 rounded-full p-1 transition-all duration-500 flex items-center shadow-inner",
          checked ? "bg-primary-accent/40 border-primary-accent/50" : "bg-background-deep border border-glass-border"
        )}
      >
        <motion.div 
          animate={{ x: checked ? 24 : 0 }}
          transition={{ type: "spring", stiffness: 500, damping: 30 }}
          className={cn(
            "w-4 h-4 rounded-full shadow-md transition-colors",
            checked ? "bg-white" : "bg-text-tertiary"
          )}
        />
      </div>
    </motion.div>
  );
};

export default Toggle;
