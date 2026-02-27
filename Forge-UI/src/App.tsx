import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Terminal,
  History,
  Layers,
  Palette
} from 'lucide-react';

// Custom Components
import Sidebar from './components/Sidebar.tsx';
import PreviewCanvas from './components/PreviewCanvas.tsx';
import ActionHub from './components/ActionHub.tsx';
import Navbar from './components/Navbar.tsx';
import TemplateExplorer from './components/TemplateExplorer.tsx';
import MoodBoard from './components/MoodBoards/MoodBoard.tsx';
import Button from './components/DesignSystem/Button.tsx';
import { useSynthesisStore } from './store/useSynthesisStore.ts';
import { useKeyboardShortcuts } from './hooks/useKeyboardShortcuts.ts';

const App: React.FC = () => {
  const { 
    selectedTemplate, 
    isExplorerOpen,
    setIsExplorerOpen,
    isMoodBoardOpen,
    setIsMoodBoardOpen
  } = useSynthesisStore();
  
  // Register shortcuts
  useKeyboardShortcuts();

  return (
    <div className="h-screen w-screen flex flex-col bg-background-deep text-text-primary overflow-hidden">
      {/* Background Effects */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary-bright/10 rounded-full blur-[120px] will-change-opacity" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] bg-primary-accent/10 rounded-full blur-[120px] will-change-opacity" />
      </div>

      {/* Main UI */}
      <Navbar />

      <main className="flex-1 flex flex-col md:flex-row gap-4 p-4 overflow-hidden relative z-10">
        {/* Left Panel: Project Configuration */}
        <motion.section 
          initial={{ x: -100, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ type: "spring", damping: 25, stiffness: 200 }}
          className="w-full md:w-1/4 glass-elevated rounded-[2.5rem] overflow-hidden flex flex-col will-change-transform h-[40vh] md:h-full bg-background-surface/30 backdrop-blur-xl border border-glass-border shadow-2xl"
        >
          <Sidebar />
        </motion.section>

        {/* Center Panel: Live Preview Canvas */}
        <motion.section 
          layout
          initial={{ scale: 0.9, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ type: "spring", damping: 20, stiffness: 150 }}
          className="flex-1 glass rounded-[2.5rem] overflow-hidden relative will-change-transform hidden md:block"
        >
          <PreviewCanvas selectedTemplate={selectedTemplate} />
          
          {/* Floating Toggles */}
          <div className="absolute top-8 right-8 z-20 flex gap-4">
            <Button
              variant="glass"
              size="sm"
              onClick={() => setIsMoodBoardOpen(true)}
              className="rounded-full border-accent-gold/30 hover:border-accent-gold"
              aria-label="Open Mood Boards"
            >
              <Palette size={16} className="text-accent-gold group-hover:rotate-12 transition-transform" />
              Mood_Boards
            </Button>

            <Button
              variant="glass"
              size="sm"
              onClick={() => setIsExplorerOpen(true)}
              className="rounded-full border-primary-bright/30 hover:border-primary-accent"
              aria-label="Launch Template Gallery"
            >
              <Layers size={16} className="text-primary-accent group-hover:rotate-12 transition-transform" />
              Launch_Gallery
            </Button>
          </div>
        </motion.section>

        {/* Right Panel: Action Hub */}
        <motion.section 
          initial={{ x: 100, opacity: 0 }}
          animate={{ x: 0, opacity: 1 }}
          transition={{ type: "spring", damping: 25, stiffness: 200 }}
          className="w-full md:w-1/4 glass-elevated rounded-[2.5rem] overflow-hidden flex flex-col will-change-transform flex-1 md:flex-none h-full bg-background-surface/30 backdrop-blur-xl border border-glass-border shadow-2xl"
        >
          <ActionHub />
        </motion.section>
      </main>

      {/* Footer / Status Bar */}
      <footer className="h-10 px-8 border-t border-glass-border bg-background-surface/80 flex items-center justify-between text-[10px] font-bold text-text-tertiary uppercase tracking-widest overflow-hidden">
        <div className="flex gap-8">
          <span className="flex items-center gap-2">
            <div className="w-1.5 h-1.5 rounded-full bg-status-success animate-pulse" aria-hidden="true" />
            Kernel_Status: Operational
          </span>
          <span className="flex items-center gap-2 hidden sm:flex">
            <Terminal size={12} className="text-primary-accent" />
            Buffer_Link: Established
          </span>
        </div>
        <div className="flex gap-8 items-center">
          <span className="flex items-center gap-2 opacity-50 hidden lg:flex">
            <History size={12} /> 
            Sync_Stamp: 2026.02.24.23.42
          </span>
          <span className="text-primary-bright font-black">SYNTHESIS_CORE_v2.0.0</span>
        </div>
      </footer>

      {/* Overlays with AnimatePresence */}
      <AnimatePresence>
        {isExplorerOpen && (
          <TemplateExplorer isOpen={isExplorerOpen} onClose={() => setIsExplorerOpen(false)} />
        )}
      </AnimatePresence>
      
      <AnimatePresence>
        {isMoodBoardOpen && (
          <MoodBoard isOpen={isMoodBoardOpen} onClose={() => setIsMoodBoardOpen(false)} />
        )}
      </AnimatePresence>
    </div>
  );
};

export default App;
