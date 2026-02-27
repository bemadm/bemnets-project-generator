import { motion, type Transition } from 'framer-motion';

// Common transitions
const pulseTransition: Transition = { duration: 3, repeat: Infinity, ease: "easeInOut" };
const rotateTransition: Transition = { duration: 20, repeat: Infinity, ease: "linear" };

// 1. Primary App Icon: DNA helix + Building + Cosmic portal
export const PrimaryAppIcon = () => (
  <div className="relative w-12 h-12 flex items-center justify-center">
    <motion.div 
      animate={{ rotate: [0, 360] }}
      transition={rotateTransition}
      className="absolute inset-0 border-2 border-primary-bright/30 rounded-lg blur-[1px]"
    />
    <motion.div 
      animate={{ rotate: [-360, 0] }}
      transition={{ duration: 15, repeat: Infinity, ease: "linear" }}
      className="absolute inset-1 border-2 border-primary-accent/40 rounded-full blur-[2px]"
    />
    <motion.img 
      src="/logo.png" 
      alt="Enum Synthesis Engine Logo"
      className="w-8 h-8 relative z-10 drop-shadow-[0_0_8px_rgba(64,224,208,0.5)] object-contain"
      animate={{ 
        scale: [1, 1.05, 1],
        filter: ["brightness(1) contrast(1)", "brightness(1.2) contrast(1.1)", "brightness(1) contrast(1)"] 
      }}
      transition={pulseTransition}
    />
  </div>
);

// 2. Template Icons
export const FullstackIcon = () => (
  <svg viewBox="0 0 64 64" className="w-8 h-8">
    <motion.circle 
      cx="32" cy="32" r="28" 
      fill="none" stroke="currentColor" strokeWidth="2" strokeDasharray="10,5" 
      animate={{ rotate: 360 }}
      transition={rotateTransition}
    />
    <rect x="20" y="20" width="10" height="10" fill="currentColor" opacity="0.5" />
    <rect x="34" y="34" width="10" height="10" fill="currentColor" />
    <motion.path 
      d="M25,30 L39,34" stroke="currentColor" strokeWidth="2" 
      animate={{ opacity: [0.8, 1, 0.8], scale: [1, 1.05, 1] }}
      transition={pulseTransition}
    />
  </svg>
);

export const MobileIcon = () => (
  <svg viewBox="0 0 64 64" className="w-8 h-8">
    <rect x="22" y="12" width="20" height="40" rx="4" fill="none" stroke="currentColor" strokeWidth="2" />
    <motion.path 
      d="M24,20 Q32,25 40,20 M24,30 Q32,35 40,30 M24,40 Q32,45 40,40" 
      stroke="currentColor" 
      strokeWidth="2" 
      fill="none"
      animate={{ opacity: [0.2, 1, 0.2] }}
      transition={{ duration: 2, repeat: Infinity }}
    />
  </svg>
);

export const MicroserviceIcon = () => (
  <svg viewBox="0 0 64 64" className="w-8 h-8">
    {[
      {x: 32, y: 15}, {x: 15, y: 40}, {x: 49, y: 40}
    ].map((pos, i) => (
      <motion.polygon 
        key={i}
        points={`${pos.x},${pos.y-8} ${pos.x+7},${pos.y-4} ${pos.x+7},${pos.y+4} ${pos.x},${pos.y+8} ${pos.x-7},${pos.y+4} ${pos.x-7},${pos.y-4}`}
        fill="currentColor"
        animate={{ scale: [1, 1.1, 1], opacity: [0.6, 1, 0.6] }}
        transition={{ delay: i * 0.2, duration: 2, repeat: Infinity }}
      />
    ))}
    <path d="M32,23 L20,35 M32,23 L44,35 M22,40 L42,40" stroke="currentColor" strokeWidth="1" strokeDasharray="2,2" />
  </svg>
);

// 3. Action Icons
export const GenerateIcon = () => (
  <svg viewBox="0 0 32 32" className="w-6 h-6">
    <motion.path 
      d="M10,8 L24,16 L10,24 Z" 
      fill="currentColor"
      animate={{ 
        d: [
          "M10,8 L24,16 L10,24 Z", // Play
          "M10,10 L22,10 L22,22 L10,22 Z", // Building
          "M10,8 L24,16 L10,24 Z"
        ]
      }}
      transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
    />
  </svg>
);

export const DryRunIcon = () => (
  <svg viewBox="0 0 32 32" className="w-6 h-6" opacity="0.5">
    <path d="M10,8 L24,16 L10,24 Z" fill="none" stroke="currentColor" strokeWidth="2" strokeDasharray="2,2" />
    <motion.circle 
      cx="17" cy="16" r="10" fill="currentColor" opacity="0.1" 
      animate={{ scale: [1, 1.1, 1], opacity: [0.1, 0.3, 0.1] }}
      transition={pulseTransition}
    />
  </svg>
);

// 4. Status Indicators
export const SuccessIcon = () => (
  <div className="relative w-6 h-6">
    <motion.div 
      animate={{ scale: [0, 1.5, 1], opacity: [1, 0.5, 0] }}
      transition={{ duration: 1, repeat: Infinity }}
      className="absolute inset-0 bg-status-success/50 rounded-full"
    />
    <svg viewBox="0 0 24 24" className="w-6 h-6 text-status-success relative z-10">
      <path d="M20,6 L9,17 L4,12" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
    </svg>
  </div>
);

export const WarningIcon = () => (
  <motion.div animate={{ scale: [1, 1.1, 1] }} transition={{ repeat: Infinity }}>
    <svg viewBox="0 0 24 24" className="w-6 h-6 text-status-warning">
      <path d="M12,2 L22,22 L2,22 Z" fill="none" stroke="currentColor" strokeWidth="2" />
      <motion.circle 
        cx="12" cy="15" r="2" fill="currentColor" 
        animate={{ opacity: [0.8, 1, 0.8] }}
        transition={pulseTransition}
      />
    </svg>
  </motion.div>
);

export const ErrorIcon = () => (
  <motion.div animate={{ rotate: [0, 10, -10, 0] }} transition={{ repeat: Infinity, duration: 0.5 }}>
    <svg viewBox="0 0 24 24" className="w-6 h-6 text-status-error">
      <path d="M4,4 L20,20 M20,4 L4,20" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
    </svg>
  </motion.div>
);
