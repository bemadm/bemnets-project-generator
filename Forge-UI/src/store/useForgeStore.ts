import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface User {
  login: string;
  avatar_url: string;
  html_url: string;
}

interface ForgeState {
  // Project Config
  projectName: string;
  destinationPath: string;
  selectedTemplate: string;
  gitEnabled: boolean;
  dockerEnabled: boolean;
  ciEnabled: boolean;
  isDryRun: boolean;
  
  // Auth
  githubToken: string | null;
  user: User | null;
  
  // UI State
  isGenerating: boolean;
  isExplorerOpen: boolean;
  isMoodBoardOpen: boolean;
  logs: string[];
  
  // Actions
  setProjectName: (name: string) => void;
  setDestinationPath: (path: string) => void;
  setSelectedTemplate: (id: string) => void;
  setGitEnabled: (enabled: boolean) => void;
  setDockerEnabled: (enabled: boolean) => void;
  setCiEnabled: (enabled: boolean) => void;
  setDryRun: (enabled: boolean) => void;
  
  setGithubToken: (token: string | null) => void;
  setUser: (user: User | null) => void;
  logout: () => void;
  
  setIsGenerating: (is: boolean) => void;
  setIsExplorerOpen: (is: boolean) => void;
  setIsMoodBoardOpen: (is: boolean) => void;
  addLog: (message: string) => void;
  clearLogs: () => void;
  resetConfig: () => void;
}

export const useForgeStore = create<ForgeState>()(
  persist(
    (set) => ({
      projectName: 'GENESIS-ALPHA',
      destinationPath: '/root/projects/forge',
      selectedTemplate: 'fullstack',
      gitEnabled: true,
      dockerEnabled: false,
      ciEnabled: false,
      isDryRun: false,
      
      githubToken: null,
      user: null,
      
      isGenerating: false,
      isExplorerOpen: false,
      isMoodBoardOpen: false,
      logs: [`[${new Date().toLocaleTimeString()}] System Ready. Waiting for forge command...`],
      
      setProjectName: (projectName) => set({ projectName }),
      setDestinationPath: (destinationPath) => set({ destinationPath }),
      setSelectedTemplate: (selectedTemplate) => set({ selectedTemplate }),
      setGitEnabled: (gitEnabled) => set({ gitEnabled }),
      setDockerEnabled: (dockerEnabled) => set({ dockerEnabled }),
      setCiEnabled: (ciEnabled) => set({ ciEnabled }),
      setDryRun: (isDryRun) => set({ isDryRun }),
      
      setGithubToken: (githubToken) => set({ githubToken }),
      setUser: (user) => set({ user }),
      logout: () => set({ githubToken: null, user: null }),
      
      setIsGenerating: (isGenerating) => set({ isGenerating }),
      setIsExplorerOpen: (isExplorerOpen) => set({ isExplorerOpen }),
      setIsMoodBoardOpen: (isMoodBoardOpen) => set({ isMoodBoardOpen }),
      addLog: (message) => set((state) => ({ 
        logs: [...state.logs, `[${new Date().toLocaleTimeString()}] ${message}`].slice(-100) 
      })),
      clearLogs: () => set({ logs: [] }),
      
      resetConfig: () => set({
        projectName: 'GENESIS-ALPHA',
        destinationPath: '/root/projects/forge',
        selectedTemplate: 'fullstack',
        gitEnabled: true,
        dockerEnabled: false,
        ciEnabled: false,
      })
    }),
    {
      name: 'forge-storage',
      partialize: (state) => ({ 
        githubToken: state.githubToken, 
        user: state.user,
        projectName: state.projectName,
        destinationPath: state.destinationPath,
        selectedTemplate: state.selectedTemplate
      }),
    }
  )
);
