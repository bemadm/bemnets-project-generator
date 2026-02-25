import { useEffect } from 'react';
import { useForgeStore } from '../store/useForgeStore.ts';
import { useProjectGeneration } from '../hooks/useProjectGeneration.ts';

export const useKeyboardShortcuts = () => {
  const { 
    setIsExplorerOpen, 
    setIsMoodBoardOpen, 
    resetConfig,
    isGenerating
  } = useForgeStore();
  
  const { generateProject } = useProjectGeneration();

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Cmd/Ctrl + Enter to Generate
      if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') {
        if (!isGenerating) {
          e.preventDefault();
          generateProject();
        }
      }

      // Esc to close modals / cancel
      if (e.key === 'Escape') {
        setIsExplorerOpen(false);
        setIsMoodBoardOpen(false);
      }

      // ? for help (Shift + /)
      if (e.key === '?' && e.shiftKey) {
        // Toggle help or similar
        console.log('Help requested');
      }

      // Cmd/Ctrl + R to Reset
      if ((e.metaKey || e.ctrlKey) && e.key === 'r' && e.shiftKey) {
        e.preventDefault();
        if (confirm('Reset project configuration?')) {
          resetConfig();
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isGenerating, generateProject, setIsExplorerOpen, setIsMoodBoardOpen, resetConfig]);
};
