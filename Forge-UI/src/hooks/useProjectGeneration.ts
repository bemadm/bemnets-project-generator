import { useSynthesisStore } from '../store/useSynthesisStore.ts';

export const useProjectGeneration = () => {
  const { 
    projectName, 
    destinationPath, 
    selectedTemplate, 
    gitEnabled, 
    dockerEnabled, 
    ciEnabled, 
    isDryRun,
    setIsGenerating,
    addLog
  } = useSynthesisStore();

  const generateProject = async () => {
    // Validation
    if (!projectName.match(/^[a-zA-Z0-9-_]+$/)) {
      addLog('Error: Project name contains invalid characters.');
      return false;
    }

    setIsGenerating(true);
    addLog(`Starting ${isDryRun ? 'DRY RUN' : 'SYNTHESIS'} for ${projectName}...`);
    
    try {
      // Simulate API call to PowerShell backend
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      addLog(`Initializing ${selectedTemplate} template...`);
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      if (gitEnabled) addLog('Git repository initialized.');
      if (dockerEnabled) addLog('Docker configuration added.');
      if (ciEnabled) addLog('GitHub Actions workflow generated.');
      
      addLog(`${isDryRun ? 'DRY RUN' : 'SYNTHESIS'} completed successfully at ${destinationPath}`);
      return true;
    } catch (error) {
      addLog(`Critical Error: ${error instanceof Error ? error.message : String(error)}`);
      return false;
    } finally {
      setIsGenerating(false);
    }
  };

  return { generateProject };
};
