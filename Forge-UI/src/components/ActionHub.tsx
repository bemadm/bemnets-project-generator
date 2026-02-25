import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Rocket, 
  Github, 
  Eye, 
  Terminal,
  Activity,
  Cpu,
  Layers,
  ShieldCheck,
  Settings,
  Share2,
  Download,
  Plus
} from 'lucide-react';
import { GenerateIcon } from './Icons.tsx';
import Button from './DesignSystem/Button.tsx';
import Toggle from './DesignSystem/Toggle.tsx';
import { useForgeStore } from '../store/useForgeStore.ts';
import { useProjectGeneration } from '../hooks/useProjectGeneration.ts';

const ActionHub: React.FC = () => {
  const { isDryRun, setDryRun, isGenerating, logs, clearLogs } = useForgeStore();
  const { generateProject } = useProjectGeneration();

  const orbitButtons = [
    { icon: Settings, label: 'Configs' },
    { icon: Share2, label: 'Share' },
    { icon: Download, label: 'Export' },
    { icon: Plus, label: 'New' },
  ];

  return (
    <div className="flex flex-col h-full p-6" role="complementary" aria-label="Action Control Center">
      <div className="mb-10 flex justify-between items-start">
        <div>
          <h2 className="text-xl font-bold mb-1 tracking-tight">Action Hub</h2>
          <p className="text-sm text-text-tertiary">Execute project generation</p>
        </div>
        <Button 
          variant="ghost" 
          size="sm" 
          onClick={clearLogs}
          className="text-[8px] tracking-widest px-2 py-1 h-auto"
        >
          CLEAR_LOGS
        </Button>
      </div>

      <div className="flex-1 space-y-8 overflow-y-auto pr-2 custom-scrollbar">
        {/* Dry Run Simulation */}
        <section aria-labelledby="dry-run-label">
          <Toggle 
            label="Dry Run Preview"
            icon={<Eye size={18} />}
            checked={isDryRun}
            onChange={setDryRun}
            description="Initialize a parallel simulation to preview structural changes without modifying the physical disk matrix."
          />
        </section>

        {/* Sync Protocol */}
        <section className="glass rounded-3xl p-6 border-l-4 border-primary-bright relative group overflow-hidden" aria-labelledby="sync-protocol-label">
          <div className="absolute inset-0 bg-gradient-to-br from-primary-bright/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity rounded-3xl" />
          
          <div className="relative z-10">
            <div className="flex items-center gap-3 mb-6">
              <div className="p-2.5 rounded-xl bg-primary-bright/10 text-primary-bright">
                <Github size={20} />
              </div>
              <span id="sync-protocol-label" className="font-black text-sm tracking-widest uppercase opacity-80">Sync Protocol</span>
            </div>

            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-bold text-text-tertiary uppercase">Security Mode</span>
                <div className="flex bg-background-deep/50 p-1 rounded-xl border border-glass-border" role="radiogroup" aria-label="Visibility settings">
                  <button className="px-3 py-1 text-[9px] font-black rounded-lg bg-primary-bright text-white shadow-lg" role="radio" aria-checked="true">PUBLIC</button>
                  <button className="px-3 py-1 text-[9px] font-black rounded-lg text-text-tertiary hover:text-white transition-colors" role="radio" aria-checked="false">PRIVATE</button>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <span className="text-[10px] font-bold text-text-tertiary uppercase">Auth State</span>
                <span className="flex items-center gap-2 text-[10px] font-black text-status-success uppercase tracking-wider" role="status">
                  <div className="w-1.5 h-1.5 rounded-full bg-status-success animate-pulse" aria-hidden="true" />
                  Verified
                </span>
              </div>
            </div>
          </div>
        </section>

        {/* System Telemetry */}
        <section className="space-y-4" aria-labelledby="telemetry-label">
          <label id="telemetry-label" className="text-[10px] uppercase tracking-widest text-text-tertiary font-bold mb-4 block">
            Core Telemetry
          </label>
          <div className="grid grid-cols-2 gap-3">
            {[
              { label: 'Neural Load', value: '12%', icon: Cpu },
              { label: 'Mem Matrix', value: '2.4 GB', icon: Layers },
              { label: 'Uptime', value: '4h 12m', icon: Activity },
              { label: 'Integrity', value: 'Stable', icon: ShieldCheck },
            ].map((stat) => (
              <div key={stat.label} className="glass p-4 rounded-2xl border border-glass-border/30 hover:border-primary-bright/30 transition-all group" role="status">
                <div className="flex items-center gap-2 mb-2">
                  <stat.icon size={12} className="text-text-tertiary group-hover:text-primary-accent transition-colors" aria-hidden="true" />
                  <span className="text-[9px] font-black text-text-tertiary uppercase tracking-tighter">{stat.label}</span>
                </div>
                <div className="text-sm font-black tracking-tight">{stat.value}</div>
              </div>
            ))}
          </div>
        </section>

        {/* Log Viewer */}
        <section className="mt-8" aria-labelledby="log-stream-label">
          <div className="flex justify-between items-center mb-3">
            <div className="flex items-center gap-2">
              <Terminal size={14} className="text-text-tertiary" />
              <span id="log-stream-label" className="text-[10px] font-black uppercase tracking-widest text-text-tertiary">Data Stream</span>
            </div>
            <span className="text-[9px] text-primary-accent font-black animate-pulse" aria-hidden="true">LIVE_SYNC</span>
          </div>
          <div 
            className="glass-elevated bg-background-deep/80 rounded-2xl p-5 font-mono text-[9px] h-32 overflow-y-auto space-y-2 border border-primary-bright/10 custom-scrollbar"
            role="log"
            aria-live="polite"
          >
            {logs.map((log, i) => (
              <div key={i} className={
                log.includes('Error') ? 'text-status-error font-bold' : 
                log.includes('SUCCESS') || log.includes('successfully') ? 'text-status-success font-bold' :
                log.includes('Initializing') ? 'text-primary-bright font-bold' :
                'text-text-tertiary opacity-80'
              }>
                {log}
              </div>
            ))}
          </div>
        </section>
      </div>

      {/* Main Action Hub */}
      <div className="mt-10 relative flex flex-col items-center">
        {/* Orbiting Buttons */}
        <div className="absolute -top-12 w-full flex justify-center gap-4" role="group" aria-label="Additional tools">
          {orbitButtons.map((btn, i) => (
            <motion.div
              key={btn.label}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.1 }}
              whileHover={{ y: -5, scale: 1.1 }}
              className="group relative"
            >
              <Button 
                variant="glass" 
                className="p-3 rounded-xl" 
                aria-label={btn.label}
              >
                <btn.icon size={16} />
              </Button>
              <span className="absolute -bottom-6 left-1/2 -translate-x-1/2 text-[8px] font-black uppercase opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
                {btn.label}
              </span>
            </motion.div>
          ))}
        </div>

        {/* Main Pulse Effect */}
        <AnimatePresence>
          {isGenerating && (
            <motion.div 
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1.6, opacity: 1 }}
              exit={{ scale: 2.2, opacity: 0 }}
              transition={{ duration: 1.2, repeat: Infinity, ease: "easeOut" }}
              className="absolute inset-0 bg-primary-bright/20 rounded-3xl blur-3xl z-0"
              aria-hidden="true"
            />
          )}
        </AnimatePresence>
        
        <Button
          onClick={generateProject}
          isLoading={isGenerating}
          className={isGenerating 
            ? 'w-full py-6 rounded-3xl bg-status-success shadow-[0_20px_60px_rgba(46,139,139,0.5)]' 
            : 'w-full py-6 rounded-3xl bg-gradient-to-r from-primary-deep via-primary-medium to-primary-bright shadow-[0_20px_50px_rgba(10,42,68,0.4)]'}
          aria-label={isDryRun ? "Simulate project generation" : "Forge project now"}
        >
          {isGenerating ? (
            <span className="font-black text-xl uppercase tracking-[0.2em] text-white">Forging...</span>
          ) : (
            <div className="flex items-center gap-4">
              <motion.div 
                animate={{ y: [0, -2, 0] }} 
                transition={{ duration: 2, repeat: Infinity }}
              >
                <GenerateIcon />
              </motion.div>
              <span className="font-black text-xl uppercase tracking-[0.2em] text-white">
                {isDryRun ? 'Simulate' : 'Forge Project'}
              </span>
              <Rocket size={20} className="text-primary-accent group-hover:translate-x-1 group-hover:-translate-y-1 transition-transform" />
            </div>
          )}
        </Button>
      </div>
    </div>
  );
};

export default ActionHub;
