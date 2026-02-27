#  Enum PROJECT SYNTHESIS ENGINE

A powerful, high-fidelity project generation platform that synthesizes complete project structures and automates cloud/repository orchestration.

## ✨ Features

-  **Automated Structure Synthesis** - Creates complex project structures with proper content
- **Modular Architecture** - Clean separation of concerns with specialized modules
-  **Advanced Customization** - Full control over project parameters and settings
- **GitHub Integration** - Create public or private repositories automatically
- **Path Memory** - Remembers your last used synthesis matrix
- **Synthesis UI** - A revolutionary, modern web-based interface with glass-morphism and 3D visualization
- **Backup Protection** - Automatically backs up existing folders with timestamps
- **Smart File Generation** - Creates package.json, README, .gitignore, LICENSE and more
-  **Dry Run Mode** - Preview changes before they are applied with the `-DryRun` switch
- **Detailed Logging** - All operations are logged to `generator.log` for troubleshooting
- **External Templates** - Easily add new templates by dropping JSON files into the `Templates/` folder
- 🧪 **Unit Testing** - Robust testing framework using Pester

##  Synthesis UI

The **Enum PROJECT SYNTHESIS ENGINE** transforms project generation into a high-fidelity creative studio.

### How to run the UI:
1. Navigate to the `Forge-UI` directory (rebranded as Synthesis UI):
   ```bash
   cd Forge-UI
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the development server:
   ```bash
   npm run dev
   ```
4. Open your browser to the provided local URL (usually `http://localhost:5173`).

## Prerequisites

- **PowerShell 5.1+** (Windows) or PowerShell 7+ (Cross-platform)
- **Git** (for GitHub integration)
- **GitHub CLI** (gh) - [Download here](https://cli.github.com/)

## Quick Start

1. **Clone or download this repository**
2. **Open PowerShell** in the project folder
3. **Run the synthesis script:**
   ```powershell
   .\Create-ProjectGenerator.ps1
   ```

##  Project Structure

- `Create-ProjectGenerator.ps1` - Main entry point
- `Modules/` - Core logic for file creation, git, and UI
- `Templates/` - JSON definitions for project types
- `Forge-UI/` - High-fidelity React-based Synthesis Engine Interface
- `Tests/` - Pester unit tests

## License

This project is licensed under the MIT License - see the LICENSE file for details.
