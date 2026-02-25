<#
.SYNOPSIS
    Handles file and directory creation operations
#>

# Directory structure definition
$script:directories = @(
    "bin",
    "src",
    "src\config",
    "src\core",
    "src\core\utils",
    "src\ui",
    "src\templates",
    "src\templates\fullstack",
    "src\templates\mobile",
    "test",
    "docs"
)

# File list definition
$script:files = @(
    "bin\generate.js",
    "src\index.js",
    "src\config\index.js",
    "src\config\templates.json",
    "src\core\templateManager.js",
    "src\core\dependencyManager.js",
    "src\core\gitManager.js",
    "src\core\devServer.js",
    "src\core\utils\fileUtils.js",
    "src\core\utils\processUtils.js",
    "src\core\utils\errorHandler.js",
    "src\ui\spinner.js",
    "src\ui\logger.js",
    "src\ui\prompts.js",
    ".generatorrc.json",
    "package.json",
    "README.md",
    ".gitignore",
    "LICENSE"
)

function Get-ProjectRootPath {
    param(
        [string]$Destination,
        [string]$ProjectName
    )
    return Join-Path -Path $Destination -ChildPath $ProjectName
}

function Backup-ExistingFolder {
    param([string]$FolderPath)
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $folderName = Split-Path $FolderPath -Leaf
    $backupPath = Join-Path (Split-Path $FolderPath -Parent) "${folderName}_backup_$timestamp"
    
    Write-Log "The folder '$FolderPath' already exists. Creating backup: $backupPath" -Level "WARNING"
    
    if (Get-DryRunMode) {
        Write-Log "DRY RUN: Would backup $FolderPath to $backupPath" -Level "DRYRUN"
        return $true
    }
    
    try {
        Rename-Item -Path $FolderPath -NewName "${folderName}_backup_$timestamp" -ErrorAction Stop
        Write-Log "Backup created: $backupPath" -Level "SUCCESS"
        return $true
    } catch {
        Write-Log "Failed to create backup: $_" -Level "ERROR"
        $response = Read-Host "Do you want to overwrite existing folder? [Y/N]"
        if ($response -match "^[Yy]$") {
            # Remove existing folder
            Remove-Item -Path $FolderPath -Recurse -Force
            return $true
        }
        return $false
    }
}

function New-DirectoryStructure {
    param(
        [string]$RootPath,
        [array]$Directories
    )
    
    Write-Log "Creating directories..." -Level "INFO"
    $results = @{ Success = 0; Fail = 0; Items = @() }
    
    foreach ($dir in $Directories) {
        $fullPath = Join-Path -Path $RootPath -ChildPath $dir
        
        if (Get-DryRunMode) {
            Write-Log "DRY RUN: Would create directory: $dir" -Level "DRYRUN"
            $results.Success++
            $results.Items += $dir
            continue
        }
        
        try {
            New-Item -ItemType Directory -Path $fullPath -Force -ErrorAction Stop | Out-Null
            Write-Log "Created: $dir" -Level "SUCCESS"
            $results.Success++
            $results.Items += $dir
        } catch {
            Write-Log "Failed: $dir - $_" -Level "ERROR"
            $results.Fail++
        }
    }
    
    return $results
}

function Get-FileContent {
    param(
        [string]$FileName,
        [string]$ProjectName
    )
    
    $currentYear = Get-Date -Format yyyy
    
    $contentMap = @{
        "package.json" = @"
{
  "name": "$ProjectName",
  "version": "1.0.0",
  "description": "A flexible project generator tool",
  "main": "src/index.js",
  "bin": {
    "generate": "./bin/generate.js"
  },
  "scripts": {
    "start": "node src/index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": ["generator", "scaffolding", "cli"],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "chalk": "^4.1.2",
    "commander": "^9.0.0",
    "inquirer": "^8.2.0",
    "ora": "^5.4.1"
  }
}
"@
        ".gitignore" = @"
# Dependencies
node_modules/
package-lock.json
yarn.lock
pnpm-lock.yaml

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Build outputs
dist/
build/
coverage/
*.tsbuildinfo

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Testing
coverage/
.nyc_output/

# Temporary files
tmp/
temp/
"@
        "README.md" = @"
# $ProjectName

A flexible tool for generating project structures.

## Installation

\`\`\`bash
npm install -g $ProjectName
\`\`\`

## Usage

\`\`\`bash
generate create my-project
\`\`\`

## Features

- Multiple project templates
- Dependency management
- Git integration
- Development server
- Cross-platform support

## License

MIT
"@
        "LICENSE" = @"
MIT License

Copyright (c) $currentYear

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@
        ".generatorrc.json" = @"
{
  "templates": {
    "fullstack": {
      "description": "Full-stack JavaScript application",
      "dependencies": ["express", "react"]
    },
    "mobile": {
      "description": "React Native mobile application",
      "dependencies": ["react-native", "@react-navigation/native"]
    }
  },
  "defaultTemplate": "fullstack",
  "git": {
    "initialBranch": "main",
    "autoCommit": true
  }
}
"@
    }
    
    if ($contentMap.ContainsKey($FileName)) {
        return $contentMap[$FileName]
    }
    return $null
}

function New-PlaceholderFiles {
    param(
        [string]$RootPath,
        [array]$Files,
        [string]$ProjectName
    )
    
    Write-Host "`nCreating placeholder files:" -ForegroundColor Cyan
    $results = @{ Success = 0; Fail = 0; Items = @() }
    
    foreach ($file in $Files) {
        $fullPath = Join-Path -Path $RootPath -ChildPath $file
        try {
            # Create directory if needed
            $fileDir = Split-Path $fullPath -Parent
            if (-not (Test-Path $fileDir)) {
                New-Item -ItemType Directory -Path $fileDir -Force -ErrorAction Stop | Out-Null
            }
            
            # Create file
            $null = New-Item -ItemType File -Path $fullPath -Force -ErrorAction Stop
            
            # Add content if available
            $content = Get-FileContent -FileName $file -ProjectName $ProjectName
            if ($content) {
                $content | Out-File -FilePath $fullPath -Encoding UTF8 -Force
            }
            
            Write-Host "  ✅ Created: $file" -ForegroundColor Green
            $results.Success++
            $results.Items += $file
        } catch {
            Write-Host "  ❌ Failed: $file - $_" -ForegroundColor Red
            $results.Fail++
        }
    }
    
    return $results
}

function Show-CreationSummary {
    param(
        [hashtable]$DirectoryResults,
        [hashtable]$FileResults
    )
    
    Write-Host "`n📊 Summary:" -ForegroundColor Cyan
    Write-Host "  ✅ Successfully created: $($DirectoryResults.Success + $FileResults.Success) items" -ForegroundColor Green
    if ($DirectoryResults.Fail -gt 0 -or $FileResults.Fail -gt 0) {
        Write-Host "  ❌ Failed to create: $($DirectoryResults.Fail + $FileResults.Fail) items" -ForegroundColor Red
    }
}