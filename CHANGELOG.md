# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0-Forge] - 2026-02-24

### Revolutionary UI Redesign (Forge UI)
- **Modern Architecture**: Shifted from a pure PowerShell CLI to a modern React + Vite + Tailwind + Three.js application.
- **Glass-morphism Design**: Implemented a stunning, three-panel glass-morphism interface inspired by spatial computing.
- **3D Visualization**: Added a "Forge Crystal" 3D core using React Three Fiber, representing the generator's heart.
- **Interactive Structure**: Live node graph visualization of the project structure as it's configured.
- **Action Hub**: A centralized command center with pulsing "Generate" energy, cosmic switches for dry runs, and a holographic log viewer.
- **Custom Iconography**: Designed a cohesive, generator-themed icon set using Lucide and custom SVG styling.
- **Telemetry System**: Real-time display of system status and generation progress.

## [1.2.0] - 2026-02-24

### Added
- **Logger Module**: A new module `Logger.ps1` for standardized logging to both the console and `generator.log`.
- **Dry Run Mode**: Added a `-DryRun` switch to the main script. Users can now preview all directory creations, file writes, and GitHub actions before they are executed.
- **Externalized Templates**: Moved hardcoded templates from `TemplateManager.ps1` into the `Templates/` directory as JSON files. This makes it easier to add and manage project templates.
- **Unit Testing Framework**: Set up a `Tests/` directory with a basic Pester unit test for the Logger module.
- **Cross-Platform Compatibility**: Enhanced `Show-FolderBrowser` in `PathManager.ps1` to support macOS and Linux via a manual input fallback when Windows GUI components are unavailable.

### Improved
- **Modular Architecture**: Expanded to 9 specialized modules.
- **Documentation**: Updated `README.md` to reflect new features and architectural improvements.
- **UI Feedback**: Standardized all console output using the new Logger module, providing better visual cues (Success, Error, Warning, DryRun).
