<#
.SYNOPSIS
    Comprehensive test script for Enum PROJECT SYNTHESIS ENGINE
.DESCRIPTION
    Tests all modules, checks system requirements, and displays status
#>

$version = "2.1.0"

# Clear screen for better readability
Clear-Host

Write-Host ("=" * 60) -ForegroundColor Cyan
Write-Host "ENUM PROJECT SYNTHESIS ENGINE TEST SUITE v$version" -ForegroundColor White -BackgroundColor Blue
Write-Host ("=" * 60) -ForegroundColor Cyan

Write-Host "`n📋 System Information:" -ForegroundColor Yellow
Write-Host "  PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor White
Write-Host "  OS: $([Environment]::OSVersion)" -ForegroundColor White
Write-Host "  Location: $(Get-Location)" -ForegroundColor White
Write-Host "  Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White

Write-Host "`n📦 Testing Modules:" -ForegroundColor Yellow
Write-Host ("-" * 40) -ForegroundColor Gray

$modules = @(
    @{Name="PathManager.ps1"; Description="Path operations"},
    @{Name="FileSystem.ps1"; Description="File/directory creation"}, 
    @{Name="GitHubManager.ps1"; Description="GitHub integration"},
    @{Name="UIManager.ps1"; Description="User interface"},
    @{Name="ProjectConfig.ps1"; Description="Configuration management"},
    @{Name="TemplateManager.ps1"; Description="Template management"},
    @{Name="DependencyManager.ps1"; Description="Dependency management"},
	
)	

$success = 0
$failed = 0
$failedModules = @()

foreach ($module in $modules) {
    $path = Join-Path "Modules" $module.Name
    
    # Check if file exists first
    if (-not (Test-Path $path)) {
        Write-Host "  ❌ $($module.Name.PadRight(20)) - File not found" -ForegroundColor Red
        $failed++
        $failedModules += $module.Name
        continue
    }
    
    # Try to load the module
    try {
        . $path
        Write-Host "  ✅ $($module.Name.PadRight(20)) - $($module.Description)" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "  ❌ $($module.Name.PadRight(20)) - Error: $_" -ForegroundColor Red
        $failed++
        $failedModules += $module.Name
    }
}

Write-Host ("-" * 40) -ForegroundColor Gray
Write-Host "Results: $success loaded, $failed failed" -ForegroundColor Cyan

if ($failed -eq 0) {
    Write-Host "`n✅ SYNTHESIS ENGINE READY! Run: .\Create-ProjectGenerator.ps1" -ForegroundColor Green
    
    # Check for required tools
    Write-Host "`n🔧 Optional Tools Check:" -ForegroundColor Yellow
    
    # Check Git
    $gitVersion = $null
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $gitVersion = git --version
        Write-Host "  ✅ Git: $gitVersion" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Git: Not installed (needed for GitHub)" -ForegroundColor Yellow
    }
    
    # Check GitHub CLI
    $ghVersion = $null
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        $ghVersion = gh --version | Select-Object -First 1
        Write-Host "  ✅ GitHub CLI: $ghVersion" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ GitHub CLI: Not installed (needed for automation)" -ForegroundColor Yellow
        Write-Host "     Install from: https://cli.github.com/" -ForegroundColor Gray
    }
    
    # Test Template System
    Write-Host "`n📋 Testing Template System:" -ForegroundColor Yellow
    
    # Check if TemplateManager loaded and functions exist
    if (Get-Command Initialize-TemplateSystem -ErrorAction SilentlyContinue) {
        Initialize-TemplateSystem
        Write-Host "  ✅ Template system initialized" -ForegroundColor Green
        
        # Get available templates
        if (Get-Command Get-AvailableTemplates -ErrorAction SilentlyContinue) {
            $templates = Get-AvailableTemplates
            Write-Host "  📁 Available Templates: $($templates.Count)" -ForegroundColor Cyan
            
            foreach ($t in $templates) {
                $typeColor = if ($t.Type -eq "Built-in") { "Green" } else { "Yellow" }
                Write-Host "     - $($t.Name): " -NoNewline
                Write-Host "$($t.Description) " -NoNewline -ForegroundColor Gray
                Write-Host "[$($t.Type)]" -ForegroundColor $typeColor
            }
        }
    } else {
        Write-Host "  ⚠ Template functions not available" -ForegroundColor Yellow
    }
    
    # Test FileSystem functions
    Write-Host "`n📁 Testing Core Functions:" -ForegroundColor Yellow
    $coreTests = @(
        @{Name="Get-ProjectRootPath"; Test={Get-Command Get-ProjectRootPath -ErrorAction SilentlyContinue}},
        @{Name="New-DirectoryStructure"; Test={Get-Command New-DirectoryStructure -ErrorAction SilentlyContinue}},
        @{Name="New-PlaceholderFiles"; Test={Get-Command New-PlaceholderFiles -ErrorAction SilentlyContinue}}
    )
    
    foreach ($test in $coreTests) {
        if (& $test.Test) {
            Write-Host "  ✅ $($test.Name) available" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $($test.Name) not found" -ForegroundColor Yellow
        }
    }
    
    # Test Path functions
    Write-Host "`n📍 Testing Path Functions:" -ForegroundColor Yellow
    $pathTests = @(
        @{Name="Resolve-DestinationPath"; Test={Get-Command Resolve-DestinationPath -ErrorAction SilentlyContinue}},
        @{Name="Get-LastPath"; Test={Get-Command Get-LastPath -ErrorAction SilentlyContinue}},
        @{Name="Save-LastPath"; Test={Get-Command Save-LastPath -ErrorAction SilentlyContinue}}
    )
    
    foreach ($test in $pathTests) {
        if (& $test.Test) {
            Write-Host "  ✅ $($test.Name) available" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $($test.Name) not found" -ForegroundColor Yellow
        }
    }
    
    # Test GitHub functions
    Write-Host "`n🐙 Testing GitHub Functions:" -ForegroundColor Yellow
    $gitTests = @(
        @{Name="Test-GitInstalled"; Test={Get-Command Test-GitInstalled -ErrorAction SilentlyContinue}},
        @{Name="Test-GitHubCLIInstalled"; Test={Get-Command Test-GitHubCLIInstalled -ErrorAction SilentlyContinue}},
        @{Name="New-GitHubRepo"; Test={Get-Command New-GitHubRepo -ErrorAction SilentlyContinue}}
    )
    
    foreach ($test in $gitTests) {
        if (& $test.Test) {
            Write-Host "  ✅ $($test.Name) available" -ForegroundColor Green
        } else {
            Write-Host "  ⚠ $($test.Name) not found" -ForegroundColor Yellow
        }
    }
    
    # Quick performance test
    Write-Host "`n⚡ Quick Performance Test:" -ForegroundColor Yellow
    $startTime = Get-Date
    
    # Test template retrieval speed
    $templateCount = (Get-AvailableTemplates).Count
    $endTime = Get-Date
    $duration = ($endTime - $startTime).TotalMilliseconds
    
    Write-Host "  Retrieved $templateCount templates in $([math]::Round($duration, 2))ms" -ForegroundColor White
    
    # Check for .lastpath.txt
    $lastPathFile = Join-Path (Get-Location) ".lastpath.txt"
    if (Test-Path $lastPathFile) {
        $lastPath = Get-Content $lastPathFile
        Write-Host "`n💾 Last saved path: $lastPath" -ForegroundColor Cyan
    }
    
} else {
    Write-Host "`n❌ Some modules failed to load:" -ForegroundColor Red
    foreach ($module in $failedModules) {
        Write-Host "   - $module" -ForegroundColor Yellow
    }
    Write-Host "`nPlease check the errors above and fix the modules." -ForegroundColor Yellow
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "Test complete at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan

# Offer to run main script
if ($failed -eq 0) {
    Write-Host "`n🚀 Ready to launch!" -ForegroundColor Green
    $runNow = Read-Host "Run main script now? [Y/N]"
    if ($runNow -match "^[Yy]$") {
        & .\Create-ProjectGenerator.ps1
    }
}