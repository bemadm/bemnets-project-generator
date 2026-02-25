import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Bell, 
  Cpu,
  LogOut,
  Github
} from 'lucide-react';
import { PrimaryAppIcon } from './Icons.tsx';
import { useForgeStore } from '../store/useForgeStore.ts';
import Button from './DesignSystem/Button.tsx';

const Navbar: React.FC = () => {
  const { user, logout, addLog } = useForgeStore();

  const handleLogin = async () => {
    addLog('Initiating GitHub OAuth PKCE flow...');
    // This would normally redirect to GitHub
    // For demo, we'll simulate a successful login
    setTimeout(() => {
      useForgeStore.getState().setUser({
        login: 'BEMNET_ADMIN',
        avatar_url: 'https://github.com/identicons/bemnet.png',
        html_url: 'https://github.com/bemnet'
      });
      useForgeStore.getState().setGithubToken('ghp_mock_token_12345');
      addLog('GitHub Authentication Successful.');
    }, 1500);
  };

  return (
    <nav className="h-16 px-6 flex items-center justify-between glass border-b border-glass-border relative z-50">
      <div className="flex items-center gap-6">
        {/* Animated Logo: The Creator's Forge */}
        <motion.div 
          whileHover={{ scale: 1.02 }}
          className="flex items-center gap-4 cursor-pointer group"
        >
          <PrimaryAppIcon />
          
          <div className="flex flex-col">
            <span className="font-black text-xl tracking-[0.2em] bg-gradient-to-r from-primary-bright via-primary-accent to-primary-bright bg-[length:200%_auto] animate-[shimmer_3s_linear_infinite] bg-clip-text text-transparent leading-none">
              THE_CREATOR'S_FORGE
            </span>
            <div className="flex items-center gap-2">
              <span className="text-[9px] text-text-tertiary uppercase tracking-[0.3em] font-bold">Project Synthesis Engine</span>
              <motion.div 
                initial={{ width: 0 }}
                whileHover={{ width: 'auto' }}
                className="overflow-hidden flex items-center gap-1 text-[8px] text-primary-accent font-black"
              >
                <div className="w-1 h-1 rounded-full bg-primary-accent" />
                <span>v2.0_STABLE</span>
              </motion.div>
            </div>
          </div>
        </motion.div>
      </div>

      <div className="flex items-center gap-8">
        {/* System Status Node */}
        <div className="hidden md:flex items-center gap-4 bg-background-deep/40 px-4 py-2 rounded-2xl border border-glass-border/50">
          <div className="flex flex-col items-end">
            <span className="text-[8px] font-black text-text-tertiary uppercase tracking-widest">Network_Node</span>
            <span className="text-[10px] font-bold text-primary-accent uppercase tracking-wider">US-EAST-FORGE-1</span>
          </div>
          <div className="relative">
            <motion.div 
              animate={{ scale: [1, 1.5, 1], opacity: [0.5, 0, 0.5] }}
              transition={{ duration: 2, repeat: Infinity }}
              className="absolute inset-0 bg-status-success rounded-full blur-[2px]"
            />
            <div className="w-2.5 h-2.5 rounded-full bg-status-success relative z-10 border border-white/20" />
          </div>
        </div>
        
        <div className="flex items-center gap-5 border-l border-glass-border pl-8">
          <motion.button 
            whileHover={{ scale: 1.1, color: 'var(--color-primary-accent)' }} 
            className="text-text-tertiary transition-colors relative"
          >
            <Bell size={18} />
            <div className="absolute top-0 right-0 w-1.5 h-1.5 bg-accent-warm rounded-full" />
          </motion.button>
          
          <motion.button 
            whileHover={{ scale: 1.1, color: 'var(--color-primary-accent)' }} 
            className="text-text-tertiary transition-colors"
          >
            <Cpu size={18} />
          </motion.button>

          <AnimatePresence mode="wait">
            {user ? (
              <motion.div 
                key="user-profile"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                className="flex items-center gap-3 bg-background-elevated/50 p-1.5 rounded-2xl border border-glass-border cursor-pointer group"
              >
                <div className="w-8 h-8 rounded-xl overflow-hidden shadow-lg shadow-primary-bright/20 group-hover:rotate-6 transition-transform">
                  <img src={user.avatar_url} alt={user.login} className="w-full h-full object-cover" />
                </div>
                <div className="flex flex-col pr-2">
                  <span className="text-[10px] font-black text-white uppercase tracking-wider">{user.login}</span>
                  <span className="text-[8px] font-bold text-text-tertiary uppercase">Senior_Architect</span>
                </div>
                <Button 
                  variant="ghost" 
                  size="sm" 
                  onClick={(e) => { e.stopPropagation(); logout(); }}
                  className="p-1 min-w-0"
                >
                  <LogOut size={12} className="text-status-error" />
                </Button>
              </motion.div>
            ) : (
              <Button 
                key="login-btn"
                variant="secondary" 
                size="sm" 
                onClick={handleLogin}
                className="rounded-xl border-primary-bright/30 text-[10px]"
              >
                <Github size={14} className="mr-1" /> CONNECT_GITHUB
              </Button>
            )}
          </AnimatePresence>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
