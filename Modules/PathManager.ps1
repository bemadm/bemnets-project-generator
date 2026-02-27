<#
.SYNOPSIS
    Manages path operations and folder selection
#>

function Get-LastPathFile {
    param([string]$ScriptDir)
    
    # Ensure ScriptDir is not empty
    if ([string]::IsNullOrEmpty($ScriptDir)) {
        $ScriptDir = (Get-Location).Path
        Write-Host "⚠ ScriptDir was empty, using current directory: $ScriptDir" -ForegroundColor Yellow
    }
    
    return Join-Path $ScriptDir ".lastpath.txt"
}
function Show-FolderBrowser {
    <#
    .SYNOPSIS
        Opens a folder browser dialog and returns selected path
    .PARAMETER Description
        Description text for the browser dialog
    .PARAMETER InitialPath
        Initial directory to open
    #>
    param(
        [string]$Description = "Select a folder",
        [string]$InitialPath = ""
    )
    
    # Check if running on Windows and if GUI is available
    if ($IsWindows -and (Get-Command "Add-Type" -ErrorAction SilentlyContinue)) {
        try {
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
            
            $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
            $folderBrowser.Description = $Description
            $folderBrowser.ShowNewFolderButton = $false
            $folderBrowser.RootFolder = [System.Environment+SpecialFolder]::MyComputer
            
            if ($InitialPath -and (Test-Path $InitialPath)) {
                $folderBrowser.SelectedPath = $InitialPath
            }
            
            if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                return $folderBrowser.SelectedPath
            }
        } catch {
            Write-Host "⚠ Folder browser error: $_" -ForegroundColor Yellow
        }
    }
    
    # Fallback for macOS/Linux or if Windows GUI fails
    Write-Host "`n📁 Cross-Platform Path Selection" -ForegroundColor Cyan
    Write-Host "Description: $Description" -ForegroundColor White
    if ($InitialPath) { Write-Host "Initial suggestion: $InitialPath" -ForegroundColor Gray }
    
    $path = Read-Host "Please enter the absolute path for your project"
    
    if (-not $path) {
        Write-Host "❌ No path provided." -ForegroundColor Red
        return $null
    }
    
    # Clean the path (remove quotes if user pasted it)
    $path = $path.Trim('"').Trim("'")
    
    if (Test-Path $path) {
        return (Get-Item $path).FullName
    } else {
        $create = Read-Host "Path does not exist. Create it? [Y/N]"
        if ($create -match "^[Yy]$") {
            try {
                New-Item -ItemType Directory -Path $path -Force | Out-Null
                return (Get-Item $path).FullName
            } catch {
                Write-Host "❌ Could not create path: $_" -ForegroundColor Red
            }
        }
    }
    
    return $null
}
function Save-LastPath {
    param(
        [string]$Path,
        [string]$ScriptDir
    )
    
    # Ensure ScriptDir is not empty
    if ([string]::IsNullOrEmpty($ScriptDir)) {
        $ScriptDir = (Get-Location).Path
    }
    
    $lastPathFile = Get-LastPathFile -ScriptDir $ScriptDir
    $Path | Out-File -FilePath $lastPathFile -Encoding UTF8 -Force
    Write-Host "✅ Path saved for next time: $Path" -ForegroundColor Green
}

function Get-LastPath {
    param([string]$ScriptDir)
    
    # Ensure ScriptDir is not empty
    if ([string]::IsNullOrEmpty($ScriptDir)) {
        $ScriptDir = (Get-Location).Path
    }
    
    $lastPathFile = Get-LastPathFile -ScriptDir $ScriptDir
    if (Test-Path $lastPathFile -ErrorAction SilentlyContinue) {
        return Get-Content $lastPathFile -ErrorAction SilentlyContinue
    }
    return $null
}

function Reset-LastPath {
    param([string]$ScriptDir)
    
    # Ensure ScriptDir is not empty
    if ([string]::IsNullOrEmpty($ScriptDir)) {
        $ScriptDir = (Get-Location).Path
    }
    
    $lastPathFile = Get-LastPathFile -ScriptDir $ScriptDir
    if (Test-Path $lastPathFile) {
        Remove-Item $lastPathFile -Force
        Write-Host "✅ Last saved folder path has been reset." -ForegroundColor Green
    } else {
        Write-Host "⚠ No saved folder path found to reset." -ForegroundColor Yellow
    }
}

function Select-DestinationFolder {
    param(
        [string]$InitialPath,
        [string]$ProjectName
    )
    
    Write-Host "Opening folder browser..." -ForegroundColor Yellow
    
    # Load Windows Forms if available
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    } catch {
        Write-Host "Error loading Windows Forms: $_" -ForegroundColor Red
        Write-Host "Using current directory: $(Get-Location)" -ForegroundColor Yellow
        return (Get-Location).Path
    }
    
    try {
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.Description = "Select the destination folder for $ProjectName"
        $folderBrowser.ShowNewFolderButton = $true
        $folderBrowser.RootFolder = [System.Environment+SpecialFolder]::MyComputer
        
        if ($InitialPath -and (Test-Path $InitialPath)) {
            $folderBrowser.SelectedPath = $InitialPath
        }

        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            Write-Host "✅ Selected folder: $($folderBrowser.SelectedPath)" -ForegroundColor Green
            return $folderBrowser.SelectedPath
        } else {
            Write-Host "No folder selected. Using current directory." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Folder browser failed: $_" -ForegroundColor Yellow
    }
    
    return (Get-Location).Path
}

function Resolve-DestinationPath {
    param(
        [string]$Destination,
        [string]$ScriptDir,
        [switch]$ResetPath,
        [string]$ProjectName
    )
    
    Write-Host "Debug: Resolve-DestinationPath called with ScriptDir='$ScriptDir'" -ForegroundColor Gray
    
    # Ensure ScriptDir is not empty
    if ([string]::IsNullOrEmpty($ScriptDir)) {
        $ScriptDir = (Get-Location).Path
        Write-Host "⚠ ScriptDir was empty, using current directory: $ScriptDir" -ForegroundColor Yellow
    }
    
    # Handle reset option
    if ($ResetPath) {
        Reset-LastPath -ScriptDir $ScriptDir
        $Destination = $null
    }
    
    # If no destination provided, check last path or open folder picker
    if (-not $Destination) {
        $lastPath = Get-LastPath -ScriptDir $ScriptDir
        if ($lastPath) {
            $useLast = Read-Host "Use last saved folder ($lastPath)? [Y/N]"
            if ($useLast -match "^[Yy]$") {
                $Destination = $lastPath
                Write-Host "✅ Using last saved path" -ForegroundColor Green
            }
        }
        
        if (-not $Destination) {
            $Destination = Select-DestinationFolder -ProjectName $ProjectName
        }
    }
    
    # Validate and create destination if needed
    try {
        if (-not (Test-Path $Destination)) {
            Write-Host "Destination path does not exist. Creating: $Destination" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $Destination -Force -ErrorAction Stop | Out-Null
        }
        
        # Save chosen destination for next run
        Save-LastPath -Path $Destination -ScriptDir $ScriptDir
    } catch {
        Write-Host "Error with destination path: $_" -ForegroundColor Red
        exit 1
    }
    
    return $Destination
}