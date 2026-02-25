import React from 'react';
import { motion } from 'framer-motion';
import { X, Palette, Zap, Shield, Sparkles } from 'lucide-react';

interface MoodBoardProps {
  isOpen: boolean;
  onClose: () => void;
}

const concepts = [
  {
    id: 'nautical',
    name: 'Nautical Twilight',
    colors: ['#0A2A44', '#1E4A6F', '#2E8B8B', '#40E0D0'],
    desc: 'Professional, innovative, trustworthy. Stability meets turquoise spark.',
    icon: Shield
  },
  {
    id: 'solar',
    name: 'Solar Flare',
    colors: ['#2D1B00', '#8B4513', '#FF8C00', '#FFD700'],
    desc: 'High energy, warm, radiating. Code forged in the heart of a star.',
    icon: Zap
  },
  {
    id: 'cyber',
    name: 'Cyber Jungle',
    colors: ['#051A05', '#0F3D0F', '#32CD32', '#00FF00'],
    desc: 'Organic growth, neon vitality. Scalable architecture as a living system.',
    icon: Sparkles
  },
  {
    id: 'monochrome',
    name: 'Monochrome Void',
    colors: ['#000000', '#1A1A1A', '#FFFFFF', '#CCCCCC'],
    desc: 'Minimalist, stark, precise. Clarity in the absence of noise.',
    icon: Palette
  },
  {
    id: 'nebula',
    name: 'Nebula Mist',
    colors: ['#1A0B2E', '#4B0082', '#8B5CF6', '#D8B4FE'],
    desc: 'Ethereal, creative, dreamy. Building projects in the cosmic clouds.',
    icon: Sparkles
  }
];

const MoodBoard: React.FC<MoodBoardProps> = ({ isOpen, onClose }) => {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: isOpen ? 1 : 0 }}
      className={`fixed inset-0 z-[200] flex items-center justify-center p-12 bg-background-deep/95 backdrop-blur-2xl ${isOpen ? '' : 'pointer-events-none'}`}
    >
      <div className="relative w-full max-w-6xl glass-elevated rounded-[3rem] p-12 overflow-hidden flex flex-col bg-background-surface/50">
        <div className="flex justify-between items-center mb-12">
          <div className="flex items-center gap-4">
            <Palette className="text-primary-accent" size={32} />
            <div>
              <h2 className="text-4xl font-black tracking-tighter">CONCEPT_MOOD_BOARDS</h2>
              <p className="text-sm text-text-tertiary uppercase tracking-[0.3em]">Select a design direction for the Forge evolution</p>
            </div>
          </div>
          <button onClick={onClose} className="p-4 glass rounded-full hover:bg-white/10 transition-colors">
            <X size={24} />
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {concepts.map((concept, idx) => (
            <motion.div
              key={concept.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: idx * 0.1 }}
              className="glass p-8 rounded-[2rem] group hover:border-primary-accent transition-all cursor-pointer overflow-hidden relative"
            >
              <div className="flex items-center gap-4 mb-6 relative z-10">
                <div className="p-3 rounded-2xl bg-white/5 group-hover:bg-primary-accent/20 transition-colors">
                  <concept.icon className="group-hover:text-primary-accent" size={24} />
                </div>
                <h3 className="text-xl font-bold tracking-tight">{concept.name}</h3>
              </div>
              
              <div className="flex gap-2 mb-6 relative z-10">
                {concept.colors.map((color, cIdx) => (
                  <div 
                    key={cIdx} 
                    className="w-10 h-10 rounded-xl shadow-lg border border-white/10" 
                    style={{ backgroundColor: color }}
                  />
                ))}
              </div>

              <p className="text-xs text-text-tertiary leading-relaxed mb-8 relative z-10">
                {concept.desc}
              </p>

              <div className="h-32 w-full rounded-2xl overflow-hidden relative z-10">
                <div 
                  className="absolute inset-0 opacity-50"
                  style={{ background: `linear-gradient(135deg, ${concept.colors[0]} 0%, ${concept.colors[1]} 50%, ${concept.colors[2]} 100%)` }}
                />
                <div className="absolute inset-0 flex items-center justify-center">
                  <div className="w-12 h-12 rounded-full border-2 border-white/20 animate-pulse" />
                </div>
              </div>

              {/* Background Glow */}
              <div 
                className="absolute -bottom-12 -right-12 w-32 h-32 blur-3xl opacity-0 group-hover:opacity-20 transition-opacity"
                style={{ backgroundColor: concept.colors[2] }}
              />
            </motion.div>
          ))}
        </div>
      </div>
    </motion.div>
  );
};

export default MoodBoard;
