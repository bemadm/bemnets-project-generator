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

# Import modules
$modules = @(
    "PathManager.ps1",
    "FileSystem.ps1",
    "GitHubManager.ps1",
    "UIManager.ps1",
    "ProjectConfig.ps1",
    "TemplateManager.ps1",
    "DependencyManager.ps1",
    "DashboardManager.ps1"
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
    
    switch ($config.CurrentChoice) {
        "1" { 
            $config = Update-ProjectConfig $config -AskForName
            $config = Initialize-ProjectCreation -Config $config -CreateRepo $false
        }
        
        "2" { 
            $config = Update-ProjectConfig $config -AskForName
            $config = Initialize-ProjectCreation -Config $config -CreateRepo $true -PrivateRepo $false
        }
        
        "3" { 
            $config = Update-ProjectConfig $config -AskForName
            $config = Initialize-ProjectCreation -Config $config -CreateRepo $true -PrivateRepo $true
        }
        
        "4" { 
            $config = Update-ProjectConfig $config -ForceNamePrompt
            Pause-Menu
        }
        
        "5" { 
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
            # Project Dashboard
            if ($config.RootPath -and (Test-Path $config.RootPath)) {
                # Load DashboardManager and show project dashboard
                if (Get-Command Show-ProjectDashboard -ErrorAction SilentlyContinue) {
                    Show-ProjectDashboard -ProjectPath $config.RootPath -Config $config
                } else {
                    Write-Host "`n❌ Project Dashboard function not available" -ForegroundColor Red
                    Write-Host "Make sure DashboardManager.ps1 is loaded correctly." -ForegroundColor Yellow
                    Pause-Menu
                }
            } else {
                Write-Host "`n❌ No project selected." -ForegroundColor Red
                Write-Host "Please select a project first using option 5." -ForegroundColor Yellow
                Pause-Menu
            }
        }
        
        "7" { 
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
            # Template Management
            Show-TemplateManagementMenu
        }
        
        "0" { 
            Write-Host "`n👋 Goodbye!" -ForegroundColor Cyan
            exit
        }
        
        default {
            Write-Host "`n❌ Invalid option. Please select 0-9." -ForegroundColor Red
            Pause-Menu
        }
    }
} while ($config.CurrentChoice -ne "0")