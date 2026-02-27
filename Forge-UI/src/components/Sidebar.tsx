import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  FolderOpen,
  Database,
  Layout,
  Server,
  Zap,
  Box,
  Globe
} from 'lucide-react';
import { FullstackIcon, MobileIcon, MicroserviceIcon } from './Icons.tsx';
import Input from './DesignSystem/Input.tsx';
import Toggle from './DesignSystem/Toggle.tsx';
import Button from './DesignSystem/Button.tsx';
import { useSynthesisStore } from '../store/useSynthesisStore.ts';

const templates = [
  { id: 'fullstack', name: 'Fullstack App', icon: FullstackIcon, color: 'text-primary-bright', desc: 'React + Node.js + MongoDB' },
  { id: 'mobile', name: 'Mobile Native', icon: MobileIcon, color: 'text-primary-accent', desc: 'React Native + Expo' },
  { id: 'microservice', name: 'Microservice', icon: MicroserviceIcon, color: 'text-status-info', desc: 'Kubernetes + Docker' },
  { id: 'api', name: 'API Service', icon: Server, color: 'text-status-success', desc: 'REST / GraphQL' },
  { id: 'frontend', name: 'Frontend Kit', icon: Layout, color: 'text-accent-gold', desc: 'Vite + Tailwind' },
  { id: 'backend', name: 'Backend Core', icon: Database, color: 'text-accent-warm', desc: 'Rust / Go' },
];

const Sidebar: React.FC = () => {
  const { 
    selectedTemplate, 
    setSelectedTemplate,
    projectName,
    setProjectName,
    destinationPath,
    setDestinationPath,
    gitEnabled,
    setGitEnabled,
    dockerEnabled,
    setDockerEnabled,
    ciEnabled,
    setCiEnabled
  } = useSynthesisStore();

  return (
    <div className="flex flex-col h-full p-6" role="complementary" aria-label="Project Configuration">
      <div className="mb-8">
        <h2 className="text-xl font-bold mb-1">Synthesize Project</h2>
        <p className="text-sm text-text-tertiary">Configure your creation workspace</p>
      </div>

      <div className="flex-1 overflow-y-auto space-y-6 pr-2 custom-scrollbar">
        {/* Project Type Selector */}
        <section aria-labelledby="template-selector-label">
          <label id="template-selector-label" className="text-[10px] uppercase tracking-widest text-text-tertiary font-bold mb-4 block">
            Select Template
          </label>
          <div className="relative flex flex-col gap-4" role="listbox" aria-labelledby="template-selector-label">
            {templates.map((tpl, idx) => {
              const Icon = tpl.icon;
              const isActive = selectedTemplate === tpl.id;
              
              return (
                <motion.div
                  key={tpl.id}
                  role="option"
                  aria-selected={isActive}
                  tabIndex={0}
                  onKeyDown={(e) => {
                    if (e.key === 'Enter' || e.key === ' ') {
                      e.preventDefault();
                      setSelectedTemplate(tpl.id);
                    }
                  }}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: idx * 0.05 }}
                  whileHover={{ scale: 1.02, x: 5 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => setSelectedTemplate(tpl.id)}
                  className={`
                    relative group cursor-pointer p-5 rounded-2xl border transition-all duration-500
                    overflow-hidden outline-none focus-visible:ring-2 focus-visible:ring-primary-accent
                    ${isActive 
                      ? 'bg-primary-bright/10 border-primary-bright/50 shadow-[0_20px_40px_rgba(46,139,139,0.15)]' 
                      : 'bg-background-deep/30 border-glass-border hover:border-primary-bright/20 hover:bg-background-elevated/30'}
                  `}
                  style={{
                    perspective: '1000px',
                    transformStyle: 'preserve-3d'
                  }}
                >
                  {/* Particle Effect */}
                  <AnimatePresence>
                    {isActive && (
                      <motion.div 
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="absolute inset-0 z-0 pointer-events-none"
                      >
                        {[...Array(6)].map((_, i) => (
                          <motion.div
                            key={i}
                            className="absolute w-1 h-1 bg-primary-accent rounded-full"
                            animate={{
                              x: [Math.random() * 200, Math.random() * 200],
                              y: [Math.random() * 100, Math.random() * 100],
                              opacity: [0, 0.5, 0],
                              scale: [0, 1, 0]
                            }}
                            transition={{
                              duration: 2 + Math.random() * 2,
                              repeat: Infinity,
                              ease: "linear"
                            }}
                          />
                        ))}
                      </motion.div>
                    )}
                  </AnimatePresence>

                  <div className="flex items-center gap-5 relative z-10" style={{ transform: 'translateZ(20px)' }}>
                    <div className={`
                      p-3 rounded-xl transition-all duration-500
                      ${isActive ? 'bg-primary-bright/20 shadow-lg shadow-primary-bright/20' : 'bg-background-surface/50'}
                      group-hover:scale-110 group-hover:rotate-3
                    `}>
                      <Icon />
                    </div>
                    <div className="flex-1">
                      <div className={`font-black text-sm tracking-tight ${isActive ? 'text-white' : 'text-text-secondary'}`}>
                        {tpl.name}
                      </div>
                      <div className="text-[10px] text-text-tertiary font-medium uppercase tracking-tighter opacity-70">
                        {tpl.desc}
                      </div>
                    </div>
                    {isActive && (
                      <motion.div layoutId="active-indicator" className="text-primary-accent">
                        <Zap size={16} fill="currentColor" />
                      </motion.div>
                    )}
                  </div>
                </motion.div>
              );
            })}
          </div>
        </section>

        {/* Configuration Inputs */}
        <section className="space-y-4 pt-4 border-t border-glass-border" aria-labelledby="project-matrix-label">
          <label id="project-matrix-label" className="text-[10px] uppercase tracking-widest text-text-tertiary font-bold mb-4 block">
            Project Matrix
          </label>
          
          <div className="space-y-5">
            <Input 
              label="PROJECT_ID"
              placeholder="GENESIS-ALPHA"
              value={projectName}
              onChange={(e) => setProjectName(e.target.value)}
              aria-required="true"
            />

            <div className="flex items-end gap-2">
              <Input 
                label="TARGET_PATH"
                placeholder="/root/projects/forge"
                value={destinationPath}
                onChange={(e) => setDestinationPath(e.target.value)}
                aria-required="true"
              />
              <Button 
                variant="glass" 
                className="p-4" 
                aria-label="Browse for folder"
              >
                <FolderOpen size={18} />
              </Button>
            </div>
          </div>
        </section>

        {/* Options Toggles */}
        <section className="space-y-3 pt-4" aria-labelledby="core-modules-label">
          <label id="core-modules-label" className="text-[10px] uppercase tracking-widest text-text-tertiary font-bold mb-4 block">
            Core Modules
          </label>
          
          <div className="space-y-3">
            <Toggle 
              label="Git Protocol"
              icon={<Zap size={16} />}
              checked={gitEnabled}
              onChange={setGitEnabled}
              description="Initialize local repository"
            />
            <Toggle 
              label="Container Engine"
              icon={<Box size={16} />}
              checked={dockerEnabled}
              onChange={setDockerEnabled}
              description="Docker & Compose orchestration"
            />
            <Toggle 
              label="Workflow Automator"
              icon={<Globe size={16} />}
              checked={ciEnabled}
              onChange={setCiEnabled}
              description="GitHub Actions pipelines"
            />
          </div>
        </section>
      </div>
    </div>
  );
};

export default Sidebar;
