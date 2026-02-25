# 🚀 Project Generator Tool

A powerful, modular PowerShell script that creates a complete project structure for a project generator tool and optionally sets up a GitHub repository automatically.

## ✨ Features

- 📁 **Automated Structure Creation** - Creates complex project structures with proper content
- 🎨 **Modular Architecture** - Clean separation of concerns with 9 specialized modules
- 🔧 **Customizable** - Change project name, destination, and settings
- 🌐 **GitHub Integration** - Create public or private repositories automatically
- 💾 **Path Memory** - Remembers your last used folder
- 🖥️ **Forge UI (New!)** - A revolutionary, modern web-based interface with glass-morphism and 3D visualization
- 🔄 **Backup Protection** - Automatically backs up existing folders with timestamps
- 📝 **Smart File Generation** - Creates package.json, README, .gitignore, LICENSE and more
- 🌵 **Dry Run Mode** - Preview changes before they are applied with the `-DryRun` switch
- 📊 **Detailed Logging** - All operations are logged to `generator.log` for troubleshooting
- 📦 **External Templates** - Easily add new templates by dropping JSON files into the `Templates/` folder
- 🧪 **Unit Testing** - Robust testing framework using Pester

## 🚀 Forge UI

The new **Forge UI** transforms the project generator into a creative studio.

### How to run Forge UI:
1. Navigate to the `Forge-UI` directory:
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

## 📋 Prerequisites

- **PowerShell 5.1+** (Windows) or PowerShell 7+ (Cross-platform)
- **Git** (for GitHub integration)
- **GitHub CLI** (gh) - [Download here](https://cli.github.com/)

## 🚀 Quick Start

1. **Clone or download this repository**
2. **Open PowerShell** in the project folder
3. **Run the script:**
   ```powershell
   .\Create-ProjectGenerator.ps1