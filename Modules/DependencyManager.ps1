<#
.SYNOPSIS
    Manages dependency installation for projects
.DESCRIPTION
    Detects package managers, parses dependency files, and installs dependencies
#>

# Supported package managers and their commands
$script:packageManagers = @{
    "npm" = @{
        Name = "npm"
        DetectionFiles = @("package.json")
        InstallCommand = "npm install"
        DevInstallCommand = "npm install --save-dev"
        GlobalInstallCommand = "npm install -g"
        VersionCommand = "npm --version"
        LockFiles = @("package-lock.json", "npm-shrinkwrap.json")
    }
    "yarn" = @{
        Name = "yarn"
        DetectionFiles = @("package.json")
        InstallCommand = "yarn install"
        AddCommand = "yarn add"
        DevAddCommand = "yarn add --dev"
        GlobalInstallCommand = "yarn global add"
        VersionCommand = "yarn --version"
        LockFiles = @("yarn.lock")
    }
    "pnpm" = @{
        Name = "pnpm"
        DetectionFiles = @("package.json")
        InstallCommand = "pnpm install"
        AddCommand = "pnpm add"
        DevAddCommand = "pnpm add --save-dev"
        GlobalInstallCommand = "pnpm add -g"
        VersionCommand = "pnpm --version"
        LockFiles = @("pnpm-lock.yaml")
    }
    "pip" = @{
        Name = "pip"
        DetectionFiles = @("requirements.txt", "setup.py")
        InstallCommand = "pip install -r requirements.txt"
        InstallAllCommand = "pip install ."
        VersionCommand = "pip --version"
        LockFiles = @("requirements.lock")
    }
    "pipenv" = @{
        Name = "pipenv"
        DetectionFiles = @("Pipfile")
        InstallCommand = "pipenv install"
        DevInstallCommand = "pipenv install --dev"
        VersionCommand = "pipenv --version"
        LockFiles = @("Pipfile.lock")
    }
    "poetry" = @{
        Name = "poetry"
        DetectionFiles = @("pyproject.toml")
        InstallCommand = "poetry install"
        AddCommand = "poetry add"
        DevAddCommand = "poetry add --dev"
        VersionCommand = "poetry --version"
        LockFiles = @("poetry.lock")
    }
    "maven" = @{
        Name = "maven"
        DetectionFiles = @("pom.xml")
        InstallCommand = "mvn install"
        CompileCommand = "mvn compile"
        VersionCommand = "mvn --version"
        LockFiles = @()
    }
    "gradle" = @{
        Name = "gradle"
        DetectionFiles = @("build.gradle", "build.gradle.kts", "settings.gradle")
        InstallCommand = "gradle build"
        VersionCommand = "gradle --version"
        LockFiles = @()
    }
    "composer" = @{
        Name = "composer"
        DetectionFiles = @("composer.json")
        InstallCommand = "composer install"
        RequireCommand = "composer require"
        VersionCommand = "composer --version"
        LockFiles = @("composer.lock")
    }
    "bundler" = @{
        Name = "bundler"
        DetectionFiles = @("Gemfile")
        InstallCommand = "bundle install"
        VersionCommand = "bundle --version"
        LockFiles = @("Gemfile.lock")
    }
    "cargo" = @{
        Name = "cargo"
        DetectionFiles = @("Cargo.toml")
        InstallCommand = "cargo build"
        VersionCommand = "cargo --version"
        LockFiles = @("Cargo.lock")
    }
    "go" = @{
        Name = "go"
        DetectionFiles = @("go.mod")
        InstallCommand = "go mod download"
        VersionCommand = "go version"
        LockFiles = @("go.sum")
    }
    "nuget" = @{
        Name = "nuget"
        DetectionFiles = @("packages.config", "*.csproj")
        InstallCommand = "nuget restore"
        VersionCommand = "nuget"
        LockFiles = @()
    }
}

function Initialize-DependencyManager {
    <#
    .SYNOPSIS
        Initializes the dependency manager
    #>
    
    Write-Host "`n📦 Initializing Dependency Manager..." -ForegroundColor Cyan
    
    # Check which package managers are installed
    $available = @{}
    foreach ($pm in $script:packageManagers.Keys) {
        $cmd = $script:packageManagers[$pm].VersionCommand.Split(' ')[0]
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            $available[$pm] = $true
        }
    }
    
    Write-Host "  Found $($available.Count) available package managers" -ForegroundColor Green
    return $available
}

function Detect-PackageManagers {
    <#
    .SYNOPSIS
        Detects which package managers are used in a project (searches recursively)
    .PARAMETER ProjectPath
        Path to the project
    #>
    param(
        [string]$ProjectPath
    )
    
    Write-Host "`n🔍 Detecting package managers in: $ProjectPath" -ForegroundColor Cyan
    
    $detected = @{}
    $available = Initialize-DependencyManager
    
    foreach ($pm in $script:packageManagers.Keys) {
        $pmConfig = $script:packageManagers[$pm]
        $detectedFiles = @()
        
        foreach ($file in $pmConfig.DetectionFiles) {
            # Handle wildcards
            if ($file.Contains("*")) {
                $matchingFiles = Get-ChildItem -Path $ProjectPath -Filter $file -Recurse -ErrorAction SilentlyContinue
                if ($matchingFiles) {
                    $detectedFiles += $matchingFiles | ForEach-Object { $_.FullName }
                }
            } else {
                # Search recursively for the file
                $foundFiles = Get-ChildItem -Path $ProjectPath -Filter $file -Recurse -ErrorAction SilentlyContinue
                if ($foundFiles) {
                    $detectedFiles += $foundFiles | ForEach-Object { $_.FullName }
                }
            }
        }
        
        if ($detectedFiles.Count -gt 0) {
            $detected[$pm] = @{
                Config = $pmConfig
                Files = $detectedFiles
                Available = $available.ContainsKey($pm)
            }
            Write-Host "  ✅ Detected $pm ($($detectedFiles.Count) files)" -ForegroundColor Green
        }
    }
    
    if ($detected.Count -eq 0) {
        Write-Host "  ❌ No package managers detected" -ForegroundColor Yellow
    }
    
    return $detected
}

function Install-Dependencies {
    <#
    .SYNOPSIS
        Installs dependencies for a project
    .PARAMETER ProjectPath
        Path to the project
    .PARAMETER PackageManagers
        Specific package managers to use (if empty, auto-detect all)
    .PARAMETER DevDependencies
        Install development dependencies
    .PARAMETER Force
        Force reinstallation
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProjectPath,
        
        [string[]]$PackageManagers,
        
        [switch]$DevDependencies,
        
        [switch]$Force
    )
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "📦 INSTALLING DEPENDENCIES" -ForegroundColor White -BackgroundColor Blue
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    # Detect package managers by looking for package.json files
    Write-Host "`n🔍 Scanning for package.json files..." -ForegroundColor Yellow
    
    # Find all package.json files but exclude node_modules directories
    $pkgFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "package.json" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\node_modules\\" }
    
    if ($pkgFiles.Count -eq 0) {
        Write-Host "❌ No package.json files found (excluding node_modules)" -ForegroundColor Red
        return $false
    }
    
    Write-Host "  Found $($pkgFiles.Count) package.json files to process" -ForegroundColor Green
    
    $results = @{
        Success = @()
        Failed = @()
        Skipped = @()
    }
    
    # Process each package.json location
    foreach ($pkgFile in $pkgFiles) {
        $fileDir = Split-Path $pkgFile.FullName -Parent
        $relativeDir = $fileDir.Replace($ProjectPath, "").TrimStart("\")
        if ([string]::IsNullOrEmpty($relativeDir)) {
            $relativeDir = "project root"
        }
        
        Write-Host "`n📦 Processing: $relativeDir" -ForegroundColor Cyan
        Write-Host ("-" * 40) -ForegroundColor Gray
        
        # Detect which package manager to use based on lock files
        $pm = Detect-PackageManagerForDirectory -Directory $fileDir
        
        if (-not $pm) {
            # Default to npm if no lock file found
            $pm = "npm"
            Write-Host "  Using default package manager: npm" -ForegroundColor Yellow
        }
        
        # Check if package manager is available
        $pmAvailable = Test-PackageManagerAvailable -PackageManager $pm
        if (-not $pmAvailable) {
            Write-Host "  ⚠ $pm is not installed on this system" -ForegroundColor Yellow
            $results.Skipped += "$relativeDir ($pm)"
            continue
        }
        
        # Change to the directory
        Push-Location $fileDir
        
        try {
            # Determine install command
            $installCmd = Get-InstallCommand -PackageManager $pm -DevDependencies:$DevDependencies -Force:$Force
            
            Write-Host "  Running: $installCmd" -ForegroundColor Yellow
            
            # Run the install command
            $output = Invoke-Expression $installCmd 2>&1
            $exitCode = $LASTEXITCODE
            
            if ($exitCode -eq 0) {
                Write-Host "  ✅ Dependencies installed successfully" -ForegroundColor Green
                $results.Success += $relativeDir
            } else {
                Write-Host "  ❌ Installation failed (exit code: $exitCode)" -ForegroundColor Red
                
                # Show only the first few lines of error
                $errorLines = $output | Select-Object -First 3
                foreach ($line in $errorLines) {
                    if ($line -match "error|Error|ERROR") {
                        Write-Host "     $line" -ForegroundColor Red
                    }
                }
                $results.Failed += $relativeDir
            }
        } catch {
            Write-Host "  ❌ Error: $_" -ForegroundColor Red
            $results.Failed += $relativeDir
        } finally {
            Pop-Location
        }
    }
    
    # Show summary
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "📊 INSTALLATION SUMMARY" -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    if ($results.Success.Count -gt 0) {
        Write-Host "✅ Successful installations:" -ForegroundColor Green
        foreach ($item in $results.Success) {
            Write-Host "   - $item" -ForegroundColor White
        }
    }
    
    if ($results.Skipped.Count -gt 0) {
        Write-Host "`n⚠ Skipped (package manager not installed):" -ForegroundColor Yellow
        foreach ($item in $results.Skipped) {
            Write-Host "   - $item" -ForegroundColor Gray
        }
    }
    
    if ($results.Failed.Count -gt 0) {
        Write-Host "`n❌ Failed installations:" -ForegroundColor Red
        foreach ($item in $results.Failed) {
            Write-Host "   - $item" -ForegroundColor Yellow
        }
    }
    
    return $results
}

function Detect-PackageManagerForDirectory {
    <#
    .SYNOPSIS
        Detects which package manager to use based on lock files
    #>
    param([string]$Directory)
    
    Push-Location $Directory
    
    $pm = $null
    
    if (Test-Path "yarn.lock") {
        $pm = "yarn"
        Write-Host "  Detected yarn.lock - using yarn" -ForegroundColor Green
    }
    elseif (Test-Path "package-lock.json") {
        $pm = "npm"
        Write-Host "  Detected package-lock.json - using npm" -ForegroundColor Green
    }
    elseif (Test-Path "pnpm-lock.yaml") {
        $pm = "pnpm"
        Write-Host "  Detected pnpm-lock.yaml - using pnpm" -ForegroundColor Green
    }
    
    Pop-Location
    return $pm
}

function Test-PackageManagerAvailable {
    <#
    .SYNOPSIS
        Checks if a package manager is installed
    #>
    param([string]$PackageManager)
    
    $cmd = Get-Command $PackageManager -ErrorAction SilentlyContinue
    return ($null -ne $cmd)
}

function Get-InstallCommand {
    <#
    .SYNOPSIS
        Gets the appropriate install command for a package manager
    #>
    param(
        [string]$PackageManager,
        [switch]$DevDependencies,
        [switch]$Force
    )
    
    switch ($PackageManager) {
        "npm" {
            $cmd = "npm install"
            if ($Force) { $cmd += " --force" }
        }
        "yarn" {
            $cmd = "yarn install"
            if ($Force) { $cmd += " --force" }
        }
        "pnpm" {
            $cmd = "pnpm install"
            if ($Force) { $cmd += " --force" }
        }
        default {
            $cmd = "npm install"
        }
    }
    
    return $cmd
}
function Get-DependencyInfo {
    <#
    .SYNOPSIS
        Gets information about dependencies in a project
    .PARAMETER ProjectPath
        Path to the project
    #>
    param(
        [string]$ProjectPath
    )
    
    $info = @{
        PackageManagers = @{}
        Dependencies = @{}
        DevDependencies = @{}
        TotalCount = 0
        Files = @{}
    }
    
    # Check for package.json files recursively (npm/yarn/pnpm)
    $pkgFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "package.json" -ErrorAction SilentlyContinue
    foreach ($pkgFile in $pkgFiles) {
        try {
            $content = Get-Content $pkgFile.FullName -Raw | ConvertFrom-Json
            $relativePath = Resolve-Path -Path $pkgFile.FullName -Relative
            $info.PackageManagers["npm"] = $true
            $info.Files["npm"] = @($pkgFile.FullName)
            
            if ($content.dependencies) {
                if (-not $info.Dependencies.ContainsKey("npm")) {
                    $info.Dependencies["npm"] = @()
                }
                $deps = $content.dependencies.PSObject.Properties.Name
                $info.Dependencies["npm"] += $deps
                $info.TotalCount += $deps.Count
            }
            if ($content.devDependencies) {
                if (-not $info.DevDependencies.ContainsKey("npm")) {
                    $info.DevDependencies["npm"] = @()
                }
                $devDeps = $content.devDependencies.PSObject.Properties.Name
                $info.DevDependencies["npm"] += $devDeps
                $info.TotalCount += $devDeps.Count
            }
        } catch {
            Write-Host "  ⚠ Error parsing $($pkgFile.FullName): $_" -ForegroundColor Yellow
        }
    }
    
    # Check for requirements.txt files recursively (pip)
    $reqFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "requirements.txt" -ErrorAction SilentlyContinue
    foreach ($reqFile in $reqFiles) {
        $info.PackageManagers["pip"] = $true
        $info.Files["pip"] = @($reqFile.FullName)
        $deps = Get-Content $reqFile.FullName | Where-Object { $_ -and $_ -notmatch '^#' }
        $info.Dependencies["pip"] = $deps
        $info.TotalCount += $deps.Count
    }
    
    # Check for Pipfile recursively (pipenv)
    $pipfileFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "Pipfile" -ErrorAction SilentlyContinue
    if ($pipfileFiles) {
        $info.PackageManagers["pipenv"] = $true
        $info.Files["pipenv"] = $pipfileFiles.FullName
    }
    
    # Check for pyproject.toml recursively (poetry)
    $pyprojectFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "pyproject.toml" -ErrorAction SilentlyContinue
    if ($pyprojectFiles) {
        $info.PackageManagers["poetry"] = $true
        $info.Files["poetry"] = $pyprojectFiles.FullName
    }
    
    # Check for pom.xml recursively (maven)
    $pomFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "pom.xml" -ErrorAction SilentlyContinue
    if ($pomFiles) {
        $info.PackageManagers["maven"] = $true
        $info.Files["maven"] = $pomFiles.FullName
    }
    
    # Check for build.gradle recursively (gradle)
    $gradleFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "build.gradle" -ErrorAction SilentlyContinue
    if ($gradleFiles) {
        $info.PackageManagers["gradle"] = $true
        $info.Files["gradle"] = $gradleFiles.FullName
    }
    
    # Check for composer.json recursively
    $composerFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "composer.json" -ErrorAction SilentlyContinue
    if ($composerFiles) {
        $info.PackageManagers["composer"] = $true
        $info.Files["composer"] = $composerFiles.FullName
    }
    
    # Check for Gemfile recursively
    $gemfileFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "Gemfile" -ErrorAction SilentlyContinue
    if ($gemfileFiles) {
        $info.PackageManagers["bundler"] = $true
        $info.Files["bundler"] = $gemfileFiles.FullName
    }
    
    # Check for Cargo.toml recursively
    $cargoFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "Cargo.toml" -ErrorAction SilentlyContinue
    if ($cargoFiles) {
        $info.PackageManagers["cargo"] = $true
        $info.Files["cargo"] = $cargoFiles.FullName
    }
    
    # Check for go.mod recursively
    $goModFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "go.mod" -ErrorAction SilentlyContinue
    if ($goModFiles) {
        $info.PackageManagers["go"] = $true
        $info.Files["go"] = $goModFiles.FullName
    }
    
    return $info
}
function Show-DependencyMenu {
    <#
    .SYNOPSIS
        Shows interactive dependency management menu
    .PARAMETER ProjectPath
        Path to the project
    #>
    param(
        [string]$ProjectPath
    )
    
    do {
        Clear-Host
        Write-Host ("=" * 60) -ForegroundColor Cyan
        Write-Host "DEPENDENCY MANAGEMENT" -ForegroundColor White -BackgroundColor Blue
        Write-Host ("=" * 60) -ForegroundColor Cyan
        Write-Host "Project: $ProjectPath" -ForegroundColor Green
        
        # Show current dependencies
        $info = Get-DependencyInfo -ProjectPath $ProjectPath
        
        Write-Host "`n📊 Current Status:" -ForegroundColor Yellow
        if ($info.PackageManagers.Count -gt 0) {
            Write-Host "  Package Managers: $($info.PackageManagers.Keys -join ', ')" -ForegroundColor Cyan
            Write-Host "  Total Dependencies: $($info.TotalCount)" -ForegroundColor White
            
            foreach ($pm in $info.Dependencies.Keys) {
                Write-Host "  $pm dependencies: $($info.Dependencies[$pm].Count)" -ForegroundColor Gray
            }
        } else {
            Write-Host "  No dependencies detected" -ForegroundColor Yellow
        }
        
        Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
        Write-Host "1. Install all dependencies" -ForegroundColor Yellow
        Write-Host "2. Install production dependencies only" -ForegroundColor Yellow
        Write-Host "3. Install development dependencies" -ForegroundColor Yellow
        Write-Host "4. Force reinstall dependencies" -ForegroundColor Yellow
        Write-Host "5. Show dependency details" -ForegroundColor Yellow
        Write-Host "6. Check for updates" -ForegroundColor Cyan
        Write-Host "7. Update all packages" -ForegroundColor Magenta
        Write-Host "8. Back to main menu" -ForegroundColor Red
        Write-Host ("=" * 60) -ForegroundColor Cyan
        
        $choice = Read-Host "Select option"
        
        switch ($choice) {
            "1" {
                Install-Dependencies -ProjectPath $ProjectPath
                Pause-Menu
            }
            "2" {
                Install-Dependencies -ProjectPath $ProjectPath -DevDependencies:$false
                Pause-Menu
            }
            "3" {
                Install-Dependencies -ProjectPath $ProjectPath -DevDependencies
                Pause-Menu
            }
            "4" {
                Install-Dependencies -ProjectPath $ProjectPath -Force
                Pause-Menu
            }
            "5" {
                Show-DependencyDetails -ProjectPath $ProjectPath
                Pause-Menu
            }
            "6" {
                Check-ForUpdates -ProjectPath $ProjectPath
                Pause-Menu
            }
            "7" {
                Update-OutdatedPackages -ProjectPath $ProjectPath
                Pause-Menu
            }
        }
    } while ($choice -ne "8")
}
function Show-DependencyDetails {
    <#
    .SYNOPSIS
        Shows detailed dependency information
    #>
    param(
        [string]$ProjectPath
    )
    
    $info = Get-DependencyInfo -ProjectPath $ProjectPath
    
    Write-Host "`n📋 Dependency Details:" -ForegroundColor Cyan
    Write-Host ("-" * 50) -ForegroundColor Gray
    
    if ($info.Dependencies.Count -eq 0 -and $info.DevDependencies.Count -eq 0) {
        Write-Host "No dependencies found" -ForegroundColor Yellow
        return
    }
    
    foreach ($pm in $info.Dependencies.Keys) {
        Write-Host "`n$pm Production Dependencies:" -ForegroundColor Green
        $info.Dependencies[$pm] | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor White
        }
    }
    
    foreach ($pm in $info.DevDependencies.Keys) {
        Write-Host "`n$pm Development Dependencies:" -ForegroundColor Yellow
        $info.DevDependencies[$pm] | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor Gray
        }
    }
}

function Check-ForUpdates {
    <#
    .SYNOPSIS
        Checks for outdated dependencies in the project
    .PARAMETER ProjectPath
        Path to the project
    #>
    param(
        [string]$ProjectPath
    )
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "🔍 CHECKING FOR UPDATES" -ForegroundColor White -BackgroundColor Blue
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    if (-not (Test-Path $ProjectPath)) {
        Write-Host "❌ Project path not found: $ProjectPath" -ForegroundColor Red
        return
    }
    
    Push-Location $ProjectPath
    
    try {
        $updatesFound = $false
        
        # Check for npm updates in all package.json files
        $pkgFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "package.json" -ErrorAction SilentlyContinue
        
        foreach ($pkgFile in $pkgFiles) {
            $fileDir = Split-Path $pkgFile.FullName -Parent
            $relativeDir = $fileDir.Replace($ProjectPath, "").TrimStart("\")
            if ([string]::IsNullOrEmpty($relativeDir)) {
                $relativeDir = "root"
            }
            
            Write-Host "`n📦 Checking npm packages in: $relativeDir" -ForegroundColor Yellow
            Write-Host ("-" * 40) -ForegroundColor Gray
            
            # Change to the directory
            Push-Location $fileDir
            
            try {
                # Run npm outdated
                $outdated = npm outdated --json 2>$null
                
                if ($outdated) {
                    try {
                        $outdatedObj = $outdated | ConvertFrom-Json
                        
                        if ($outdatedObj.PSObject.Properties.Count -gt 0) {
                            $updatesFound = $true
                            Write-Host "  Outdated packages found:" -ForegroundColor Cyan
                            
                            # Create a table for display
                            $outdatedObj.PSObject.Properties | ForEach-Object {
                                $pkg = $_.Name
                                $current = $_.Value.current
                                $wanted = $_.Value.wanted
                                $latest = $_.Value.latest
                                
                                # Determine color based on update type
                                $color = if ($wanted -eq $latest) { "Green" } else { "Yellow" }
                                
                                Write-Host "  📦 $pkg" -ForegroundColor White
                                Write-Host "     Current: $current" -ForegroundColor Gray
                                Write-Host "     Wanted:  $wanted" -ForegroundColor $color
                                Write-Host "     Latest:  $latest" -ForegroundColor Magenta
                                Write-Host ""
                            }
                        } else {
                            Write-Host "  ✅ All packages are up to date!" -ForegroundColor Green
                        }
                    } catch {
                        # If JSON parsing fails, show raw output
                        Write-Host "  Outdated packages:" -ForegroundColor Yellow
                        $outdated
                    }
                } else {
                    Write-Host "  ✅ All packages are up to date!" -ForegroundColor Green
                }
            } catch {
                Write-Host "  ⚠ Error checking updates: $_" -ForegroundColor Yellow
            } finally {
                Pop-Location
            }
        }
        
        # Check for pip updates if requirements.txt exists
        $reqFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "requirements.txt" -ErrorAction SilentlyContinue
        
        foreach ($reqFile in $reqFiles) {
            $fileDir = Split-Path $reqFile.FullName -Parent
            $relativeDir = $fileDir.Replace($ProjectPath, "").TrimStart("\")
            
            Write-Host "`n🐍 Checking Python packages in: $relativeDir" -ForegroundColor Yellow
            Write-Host ("-" * 40) -ForegroundColor Gray
            
            Push-Location $fileDir
            
            try {
                # Check if pip is available
                $pipVersion = pip --version 2>$null
                if ($pipVersion) {
                    # Run pip list --outdated
                    $outdated = pip list --outdated --format=json 2>$null
                    
                    if ($outdated -and $outdated -ne "[]") {
                        $updatesFound = $true
                        $outdatedObj = $outdated | ConvertFrom-Json
                        
                        Write-Host "  Outdated packages found:" -ForegroundColor Cyan
                        $outdatedObj | ForEach-Object {
                            Write-Host "  📦 $($_.name)" -ForegroundColor White
                            Write-Host "     Current: $($_.version)" -ForegroundColor Gray
                            Write-Host "     Latest:  $($_.latest_version)" -ForegroundColor Magenta
                            Write-Host ""
                        }
                    } else {
                        Write-Host "  ✅ All packages are up to date!" -ForegroundColor Green
                    }
                } else {
                    Write-Host "  ⚠ pip not available" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "  ⚠ Error checking pip updates: $_" -ForegroundColor Yellow
            } finally {
                Pop-Location
            }
        }
        
        if (-not $updatesFound) {
            Write-Host "`n✅ All dependencies are up to date across the entire project!" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "❌ Error checking for updates: $_" -ForegroundColor Red
    } finally {
        Pop-Location
    }
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
}
function Update-OutdatedPackages {
    <#
    .SYNOPSIS
        Updates outdated packages in the project
    .PARAMETER ProjectPath
        Path to the project
    .PARAMETER PackageManagers
        Which package managers to update
    #>
    param(
        [string]$ProjectPath,
        [string[]]$PackageManagers = @("npm")
    )
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
    Write-Host "🔄 UPDATING PACKAGES" -ForegroundColor White -BackgroundColor Blue
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    Push-Location $ProjectPath
    
    try {
        $pkgFiles = Get-ChildItem -Path $ProjectPath -Recurse -Filter "package.json" -ErrorAction SilentlyContinue
        
        foreach ($pkgFile in $pkgFiles) {
            $fileDir = Split-Path $pkgFile.FullName -Parent
            $relativeDir = $fileDir.Replace($ProjectPath, "").TrimStart("\")
            
            Write-Host "`n📦 Updating packages in: $relativeDir" -ForegroundColor Yellow
            Write-Host ("-" * 40) -ForegroundColor Gray
            
            Push-Location $fileDir
            
            try {
                # Run npm update
                Write-Host "  Running: npm update" -ForegroundColor Cyan
                $output = npm update 2>&1
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✅ Packages updated successfully!" -ForegroundColor Green
                    
                    # Show what was updated
                    $outdated = npm outdated --json 2>$null
                    if (-not $outdated) {
                        Write-Host "  All packages are now at latest versions" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "  ❌ Update failed" -ForegroundColor Red
                    $output | Select-Object -First 3 | ForEach-Object { Write-Host "     $_" -ForegroundColor Red }
                }
            } catch {
                Write-Host "  ⚠ Error updating: $_" -ForegroundColor Yellow
            } finally {
                Pop-Location
            }
        }
    } finally {
        Pop-Location
    }
    
    Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
}