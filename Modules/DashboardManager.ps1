<#
.SYNOPSIS
    Dashboard functions for Project Generator
.DESCRIPTION
    Contains project and tool dashboard functions
#>

function Show-ProjectDashboard {
    <#
    .SYNOPSIS
        Shows comprehensive dashboard for a selected project
    .PARAMETER ProjectPath
        Path to the project
    .PARAMETER Config
        Configuration object
    #>
    param(
        [string]$ProjectPath,
        [PSObject]$Config
    )
    
    Clear-Host
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host "📊 PROJECT DASHBOARD" -ForegroundColor White -BackgroundColor Blue
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    if (-not $ProjectPath -or -not (Test-Path $ProjectPath)) {
        Write-Host "`n❌ No valid project selected" -ForegroundColor Red
        Pause-Menu
        return
    }
    
    # Project Header
    Write-Host "`n📁 PROJECT OVERVIEW" -ForegroundColor Yellow
    Write-Host ("-" * 40) -ForegroundColor Gray
    Write-Host "Name:         $($Config.RepoName)" -ForegroundColor White
    Write-Host "Path:         $ProjectPath" -ForegroundColor Cyan
    
    # Get folder and file counts
    $folders = Get-ChildItem -Path $ProjectPath -Directory -ErrorAction SilentlyContinue
    $files = Get-ChildItem -Path $ProjectPath -File -ErrorAction SilentlyContinue
    
    Write-Host "`n📂 PROJECT STRUCTURE" -ForegroundColor Yellow
    Write-Host ("-" * 40) -ForegroundColor Gray
    Write-Host "  Folders: $($folders.Count)" -ForegroundColor Cyan
    Write-Host "  Files:   $($files.Count)" -ForegroundColor White
    
    # Show recent files
    Write-Host "`n🕒 RECENT FILES" -ForegroundColor Yellow
    Write-Host ("-" * 40) -ForegroundColor Gray
    
    $recentFiles = Get-ChildItem -Path $ProjectPath -File | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 5
    
    if ($recentFiles.Count -gt 0) {
        foreach ($file in $recentFiles) {
            $size = if ($file.Length -gt 1KB) {
                "{0:N1} KB" -f ($file.Length / 1KB)
            } else {
                "{0} B" -f $file.Length
            }
            Write-Host "  📄 $($file.Name) - $($file.LastWriteTime.ToString('yyyy-MM-dd HH:mm')) ($size)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  No files found" -ForegroundColor Gray
    }
    
    # Show folders
    Write-Host "`n📁 PROJECT FOLDERS" -ForegroundColor Yellow
    Write-Host ("-" * 40) -ForegroundColor Gray
    
    if ($folders.Count -gt 0) {
        $folders | Select-Object -First 8 | ForEach-Object {
            Write-Host "  📁 $($_.Name)" -ForegroundColor Cyan
        }
        if ($folders.Count -gt 8) {
            Write-Host "  ... and $($folders.Count - 8) more" -ForegroundColor Gray
        }
    } else {
        Write-Host "  No folders found" -ForegroundColor Gray
    }
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "Press any key to return to menu..." -ForegroundColor Magenta
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Pause-Menu {
    <#
    .SYNOPSIS
        Pauses and waits for key press
    #>
    Write-Host "`nPress any key to continue..." -ForegroundColor Magenta
    $null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Export functions
Export-ModuleMember -Function Show-ProjectDashboard, Pause-Menu
