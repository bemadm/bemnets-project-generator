<#
.SYNOPSIS
    Creates the folder structure for a project generator tool and automatically creates a GitHub repository.
.DESCRIPTION
    This script generates the directory tree and automatically creates a new GitHub repository.
.EXAMPLE
    .\Create-ProjectGenerator.ps1
#>

param(
    [string]$Destination,
    [string]$RepoName = "project-generator",
    [switch]$ResetPath,
    [switch]$PrivateRepo,
    [switch]$Force,
    [switch]$DryRun
)

# Get script directory
$scriptDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}
if ([string]::IsNullOrEmpty($scriptDir)) {
    $scriptDir = (Get-Location).Path
}

# Import Logger first
$loggerPath = Join-Path $scriptDir "Modules" "Logger.ps1"
if (Test-Path $loggerPath) {
    . $loggerPath
    Initialize-Logger -DryRun:$DryRun
}

Write-Host "📂 Script Directory: $scriptDir" -ForegroundColor Cyan
Write-Host "Loading modules..." -ForegroundColor Cyan

# Import modules - order matters!
$modules = @(
    "PathManager.ps1",
    "FileSystem.ps1",
    "GitHubManager.ps1",
    "UIManager.ps1",
    "ProjectConfig.ps1",
    "TemplateManager.ps1",
    "DependencyManager.ps1",
    "DashboardManager.ps1"  # Last but included
)

foreach ($module in $modules) {
    $modulePath = Join-Path $scriptDir "Modules" $module
    if (Test-Path $modulePath) {
        . $modulePath
        Write-Host "  ✅ Loaded: $module" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Not found: $module" -ForegroundColor Yellow
    }
}

Write-Host ""

# Initialize configuration
$config = Initialize-ProjectConfig -RepoName $RepoName -Destination $Destination -Force:$Force

# Main menu loop
do {
    $config = Show-MainMenu -Config $config
    
    # DEBUG: Show what was selected
    Write-Host "`n🔍 DEBUG: You selected option: '$($config.CurrentChoice)'" -ForegroundColor Magenta
    Start-Sleep -Seconds 1
    
    switch ($config.CurrentChoice) {
        "1" { 
            Write-Host "✅ Matched option 1" -ForegroundColor Green
            $config = Update-ProjectConfig $config -AskForName
            $config = Initialize-ProjectCreation -Config $config -CreateRepo $false
        }
        
        "2" { 
            Write-Host "✅ Matched option 2" -ForegroundColor Green
            $config = Update-ProjectConfig $config -AskForName
            $config = Initialize-ProjectCreation -Config $config -CreateRepo $true -PrivateRepo $false
        }
        
        "3" { 
            Write-Host "✅ Matched option 3" -ForegroundColor Green
            $config = Update-ProjectConfig $config -AskForName
            $config = Initialize-ProjectCreation -Config $config -CreateRepo $true -PrivateRepo $true
        }
        
        "4" { 
            Write-Host "✅ Matched option 4" -ForegroundColor Green
            $config = Update-ProjectConfig $config -ForceNamePrompt
            Pause-Menu
        }
        
        "5" { 
            Write-Host "✅ Matched option 5" -ForegroundColor Green
            # Select existing project with folder browser
            Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
            Write-Host "📁 SELECT EXISTING PROJECT" -ForegroundColor White -BackgroundColor Blue
            Write-Host ("=" * 60) -ForegroundColor Cyan
            
            Write-Host "`nOptions:" -ForegroundColor Yellow
            Write-Host "  [B] Browse for folder" -ForegroundColor Green
            Write-Host "  [M] Enter path manually" -ForegroundColor White
            Write-Host "  [C] Cancel" -ForegroundColor Gray
            
            $choice = Read-Host "`nYour choice"
            
            $manualPath = ""
            
            switch ($choice.ToUpper()) {
                "B" {
                    Write-Host "`nOpening folder browser..." -ForegroundColor Yellow
                    $manualPath = Show-FolderBrowser -Description "Select your existing project folder" -InitialPath $config.RootPath
                    if (-not $manualPath) {
                        Write-Host "`n⚠ Folder selection cancelled." -ForegroundColor Yellow
                        $manualPath = Read-Host "`nEnter path manually (or press Enter to cancel)"
                    }
                }
                "M" {
                    $manualPath = Read-Host "`nEnter project path"
                }
                default {
                    Write-Host "`n⚠ Operation cancelled." -ForegroundColor Yellow
                    Pause-Menu
                    continue
                }
            }
            
            if ($manualPath) {
                # Clean and validate path
                $manualPath = $manualPath.Trim('"', "'", ' ')
                
                if (-not [System.IO.Path]::IsPathRooted($manualPath)) {
                    $manualPath = Join-Path (Get-Location) $manualPath
                }
                
                if (Test-Path $manualPath) {
                    $config.RootPath = $manualPath
                    $config.RepoName = Split-Path $manualPath -Leaf
                    Write-Host "`n✅ Project selected: $($config.RepoName)" -ForegroundColor Green
                    Write-Host "   Path: $($config.RootPath)" -ForegroundColor Cyan
                    
                    # Show project info
                    $info = Get-DependencyInfo -ProjectPath $config.RootPath -ErrorAction SilentlyContinue
                    if ($info.PackageManagers.Count -gt 0) {
                        Write-Host "`n📊 Detected: $($info.PackageManagers.Keys -join ', ')" -ForegroundColor Yellow
                    }
                } else {
                    Write-Host "`n❌ Path not found: $manualPath" -ForegroundColor Red
                }
            }
            Pause-Menu
        }
        
       "6" { 
    Write-Host "`n🔍 Loading Project Dashboard..." -ForegroundColor Cyan
    
    # First, check if the project is selected
    if (-not $config.RootPath -or -not (Test-Path $config.RootPath)) {
        Write-Host "`n❌ No project selected." -ForegroundColor Red
        Write-Host "Please select a project first using option 5." -ForegroundColor Yellow
        Pause-Menu
        continue
    }
    
    Write-Host "✅ Project found: $($config.RootPath)" -ForegroundColor Green
    
    # Explicitly load the DashboardManager module
    $dashboardPath = Join-Path $scriptDir "Modules\DashboardManager.ps1"
    Write-Host "🔍 Looking for module at: $dashboardPath" -ForegroundColor Yellow
    
    if (Test-Path $dashboardPath) {
        Write-Host "✅ Module file found" -ForegroundColor Green
        
        # Get file size to ensure it's not empty
        $fileInfo = Get-Item $dashboardPath
        if ($fileInfo.Length -eq 0) {
            Write-Host "❌ Module file is empty (0 bytes)" -ForegroundColor Red
            Write-Host "Please recreate DashboardManager.ps1 with proper content." -ForegroundColor Yellow
            Pause-Menu
            continue
        }
        
        # Load the module
        . $dashboardPath
        Write-Host "✅ Module loaded" -ForegroundColor Green
        
        # Check if function exists
        if (Get-Command Show-ProjectDashboard -ErrorAction SilentlyContinue) {
            Write-Host "✅ Show-ProjectDashboard function is available" -ForegroundColor Green
            Show-ProjectDashboard -ProjectPath $config.RootPath -Config $config
        } else {
            Write-Host "❌ Show-ProjectDashboard function NOT found after loading" -ForegroundColor Red
            
            # List all functions in the module
            Write-Host "`nFunctions available in current session:" -ForegroundColor Yellow
            Get-Command -CommandType Function | Where-Object { $_.Name -like "*Project*" -or $_.Name -like "*Dashboard*" } | 
                ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
            
            # Show content of the module file for debugging
            Write-Host "`nFirst 10 lines of DashboardManager.ps1:" -ForegroundColor Yellow
            Get-Content $dashboardPath -TotalCount 10
        }
    } else {
        Write-Host "❌ DashboardManager.ps1 not found at: $dashboardPath" -ForegroundColor Red
        
        # List all files in Modules folder
        Write-Host "`nFiles in Modules folder:" -ForegroundColor Yellow
        Get-ChildItem $scriptDir\Modules | ForEach-Object { 
            $size = if ($_.Length -eq 0) { " (EMPTY)" } else { "" }
            Write-Host "  - $($_.Name)$size" -ForegroundColor Gray 
        }
    }
    
    Pause-Menu
}
        
        "7" { 
            Write-Host "✅ Matched option 7" -ForegroundColor Green
            # Tool Dashboard
            $dashboardPath = Join-Path $scriptDir "Show-ToolDashboard.ps1"
            if (Test-Path $dashboardPath) {
                & $dashboardPath
                # After returning from dashboard, refresh menu
            } else {
                Write-Host "`n❌ Tool Dashboard script not found at:" -ForegroundColor Red
                Write-Host "   $dashboardPath" -ForegroundColor Yellow
                Write-Host "`nPlease create Show-ToolDashboard.ps1 in the root folder." -ForegroundColor Yellow
                Pause-Menu
            }
        }
        
        "8" { 
            Write-Host "✅ Matched option 8" -ForegroundColor Green
            # Install dependencies (quick)
            Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
            Write-Host "📦 QUICK INSTALL" -ForegroundColor White -BackgroundColor Blue
            Write-Host ("=" * 60) -ForegroundColor Cyan
            
            if ($config.RootPath -and (Test-Path $config.RootPath)) {
                Write-Host "Project: $($config.RootPath)" -ForegroundColor Cyan
                $results = Install-Dependencies -ProjectPath $config.RootPath
                
                if ($results.Success.Count -gt 0) {
                    Write-Host "`n✅ Quick install completed successfully!" -ForegroundColor Green
                }
            } else {
                Write-Host "`n❌ No project selected." -ForegroundColor Red
                Write-Host "Please select a project first using option 5." -ForegroundColor Yellow
            }
            Pause-Menu
        }
        
        "9" { 
            Write-Host "✅ Matched option 9" -ForegroundColor Green
            # Template Management
            Show-TemplateManagementMenu
        }
        
        "0" { 
            Write-Host "✅ Matched option 0" -ForegroundColor Green
            Write-Host "`n👋 Goodbye!" -ForegroundColor Cyan
            exit
        }
        
        default {
            Write-Host "`n❌ Invalid option. Please select 0-9." -ForegroundColor Red
            Write-Host "Received value: '$($config.CurrentChoice)'" -ForegroundColor Yellow
            Pause-Menu
        }
    }
} while ($config.CurrentChoice -ne "0")