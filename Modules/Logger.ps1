<#
.SYNOPSIS
    Advanced logging module for the Project Generator Tool
.DESCRIPTION
    Provides standardized logging to console and file (generator.log)
#>

$script:logFile = Join-Path $PSScriptRoot "..\" "generator.log"
$script:dryRun = $false

function Initialize-Logger {
    param(
        [string]$LogPath = $null,
        [bool]$DryRun = $false
    )
    
    if ($LogPath) {
        $script:logFile = $LogPath
    }
    
    $script:dryRun = $DryRun
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $header = "`n" + ("=" * 80) + "`n"
    $header += "Session Started: $timestamp`n"
    if ($script:dryRun) { $header += "DRY RUN MODE ENABLED`n" }
    $header += ("=" * 80) + "`n"
    
    $header | Out-File -FilePath $script:logFile -Append -Encoding UTF8
}

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DRYRUN")]
        [string]$Level = "INFO",
        
        [switch]$NoConsole
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Write to file
    $logEntry | Out-File -FilePath $script:logFile -Append -Encoding UTF8
    
    # Write to console if not suppressed
    if (-not $NoConsole) {
        $color = switch ($Level) {
            "INFO"    { "White" }
            "WARNING" { "Yellow" }
            "ERROR"   { "Red" }
            "SUCCESS" { "Green" }
            "DRYRUN"  { "Cyan" }
            Default   { "Gray" }
        }
        
        $prefix = switch ($Level) {
            "INFO"    { "ℹ" }
            "WARNING" { "⚠" }
            "ERROR"   { "❌" }
            "SUCCESS" { "✅" }
            "DRYRUN"  { "🌵" }
            Default   { "»" }
        }
        
        Write-Host "$prefix $Message" -ForegroundColor $color
    }
}

function Set-DryRunMode {
    param([bool]$Enabled)
    $script:dryRun = $Enabled
}

function Get-DryRunMode {
    return $script:dryRun
}

# Export functions
Export-ModuleMember -Function Initialize-Logger, Write-Log, Set-DryRunMode, Get-DryRunMode
