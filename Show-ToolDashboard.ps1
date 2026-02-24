<#
.SYNOPSIS
    Complete dashboard for the Project Generator tool itself
.DESCRIPTION
    Shows everything about the tool: modules, templates, dependencies, GitHub status
#>

function Show-ToolDashboard {
    Clear-Host
    
    # Fix: Get the correct path regardless of how script is called
    $scriptPath = if ($MyInvocation.MyCommand.Path) {
        Split-Path -Parent $MyInvocation.MyCommand.Path
    } else {
        # If called from another script, use the current location
        (Get-Location).Path
    }
    
    $toolPath = $scriptPath
    $modulesPath = Join-Path $toolPath "Modules"
    
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host "🚀 PROJECT GENERATOR TOOL - COMPLETE DASHBOARD v1.2.0" -ForegroundColor White -BackgroundColor Blue
    Write-Host ("=" * 80) -ForegroundColor Cyan
    
    # ======================================================================
    # SECTION 1: TOOL OVERVIEW
    # ======================================================================
    Write-Host "`n📊 TOOL OVERVIEW" -ForegroundColor Yellow
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    # Get tool info
    $mainScript = Join-Path $toolPath "Create-ProjectGenerator.ps1"
    $readmeFile = Join-Path $toolPath "README.md"
    $gitPath = Join-Path $toolPath ".git"
    
    Write-Host "📍 Location:        $toolPath" -ForegroundColor Cyan
    Write-Host "📦 Version:         1.2.0" -ForegroundColor Green
    Write-Host "📄 Main Script:      $(Split-Path $mainScript -Leaf)" -ForegroundColor White
    Write-Host "📖 Documentation:    $((Test-Path $readmeFile) ? '✅ README.md' : '❌ Missing')" -ForegroundColor $(if (Test-Path $readmeFile) { "Green" } else { "Red" })
    Write-Host "🔧 Git Repository:   $((Test-Path $gitPath) ? '✅ Initialized' : '❌ Not initialized')" -ForegroundColor $(if (Test-Path $gitPath) { "Green" } else { "Yellow" })
    
    # ======================================================================
    # SECTION 2: MODULES STATUS
    # ======================================================================
    Write-Host "`n📦 MODULES STATUS" -ForegroundColor Yellow
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    $modules = @(
        @{Name="PathManager.ps1"; Description="Path operations"},
        @{Name="FileSystem.ps1"; Description="File/directory creation"},
        @{Name="GitHubManager.ps1"; Description="GitHub integration"},
        @{Name="UIManager.ps1"; Description="User interface"},
        @{Name="ProjectConfig.ps1"; Description="Configuration management"},
        @{Name="TemplateManager.ps1"; Description="Template management"},
        @{Name="DependencyManager.ps1"; Description="Dependency installation"},
        @{Name="DashboardManager.ps1"; Description="Dashboard display"}
    )
    
    $moduleTable = @()
    $loadedCount = 0
    
    foreach ($module in $modules) {
        $modulePath = Join-Path $modulesPath $module.Name
        $exists = Test-Path $modulePath
        if ($exists) {
            $loadedCount++
            
            # Get file size and last modified
            $fileInfo = Get-Item $modulePath
            $size = "{0:N0} KB" -f ($fileInfo.Length / 1KB)
            $modified = $fileInfo.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
            
            $moduleTable += [PSCustomObject]@{
                Status = "✅"
                Name = $module.Name.PadRight(25)
                Description = $module.Description.PadRight(25)
                Size = $size.PadRight(10)
                Modified = $modified
            }
        } else {
            $moduleTable += [PSCustomObject]@{
                Status = "❌"
                Name = $module.Name.PadRight(25)
                Description = $module.Description.PadRight(25)
                Size = "N/A".PadRight(10)
                Modified = "N/A"
            }
        }
    }
    
    $moduleTable | Format-Table -Property Status, Name, Description, Size, Modified -AutoSize -Wrap
    
    Write-Host "`n  📊 Total: $loadedCount/$($modules.Count) modules loaded" -ForegroundColor $(if ($loadedCount -eq $modules.Count) { "Green" } else { "Yellow" })
    
    # ======================================================================
    # SECTION 3: TEMPLATES AVAILABLE
    # ======================================================================
    Write-Host "`n🎨 AVAILABLE TEMPLATES" -ForegroundColor Yellow
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    # Load template manager to get templates
    $templateManagerPath = Join-Path $modulesPath "TemplateManager.ps1"
    if (Test-Path $templateManagerPath) {
        . $templateManagerPath
        
        $templates = Get-AvailableTemplates
        
        if ($templates.Count -gt 0) {
            $templateTable = @()
            foreach ($t in $templates) {
                $templateTable += [PSCustomObject]@{
                    Type = if ($t.Type -eq "Built-in") { "📦" } else { "📁" }
                    Name = $t.Name.PadRight(20)
                    Description = $t.Description.PadRight(40)
                    Source = $t.Type
                }
            }
            $templateTable | Format-Table -Property Type, Name, Description, Source -AutoSize
        } else {
            Write-Host "  No templates available" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⚠ Template Manager module not found" -ForegroundColor Red
    }
    
    # ======================================================================
    # SECTION 4: DEPENDENCY STATUS
    # ======================================================================
    Write-Host "`n📦 DEPENDENCY STATUS" -ForegroundColor Yellow
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    # Check for package.json in tool directory
    $pkgFile = Join-Path $toolPath "package.json"
    if (Test-Path $pkgFile) {
        $content = Get-Content $pkgFile | ConvertFrom-Json
        $depCount = ($content.dependencies.PSObject.Properties).Count
        $devDepCount = ($content.devDependencies.PSObject.Properties).Count
        
        Write-Host "  📄 package.json found" -ForegroundColor Green
        Write-Host "  ├─ Dependencies: $depCount" -ForegroundColor White
        Write-Host "  └─ Dev Dependencies: $devDepCount" -ForegroundColor Gray
        
        # Check node_modules
        $nodeModules = Join-Path $toolPath "node_modules"
        if (Test-Path $nodeModules) {
            $moduleCount = (Get-ChildItem $nodeModules -Directory -ErrorAction SilentlyContinue).Count
            $moduleSize = (Get-ChildItem $nodeModules -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
            $sizeMB = [math]::Round($moduleSize / 1MB, 2)
            Write-Host "  📁 node_modules: $moduleCount packages, $sizeMB MB" -ForegroundColor Cyan
        } else {
            Write-Host "  ⚠ node_modules not installed (run 'npm install')" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⚠ No package.json found (tool may not have npm dependencies)" -ForegroundColor Yellow
    }
    
    # ======================================================================
    # SECTION 5: GITHUB STATUS
    # ======================================================================
    Write-Host "`n🌐 GITHUB STATUS" -ForegroundColor Yellow
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    # Check GitHub CLI
    $ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
    if ($ghInstalled) {
        $ghVersion = gh --version | Select-Object -First 1
        Write-Host "  ✅ GitHub CLI: $ghVersion" -ForegroundColor Green
        
        # Check auth status
        $authStatus = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ GitHub Authentication: Active" -ForegroundColor Green
            
            # Get username
            $username = gh api user --jq .login 2>$null
            if ($username) {
                Write-Host "  👤 User: $username" -ForegroundColor Cyan
            }
        } else {
            Write-Host "  ⚠ GitHub Authentication: Not logged in" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⚠ GitHub CLI not installed" -ForegroundColor Yellow
    }
    
    # Check git status
    if (Test-Path $gitPath) {
        Push-Location $toolPath
        $branch = git branch --show-current 2>$null
        $remote = git remote get-url origin 2>$null
        $changes = (git status --porcelain 2>$null | Measure-Object).Count
        Pop-Location
        
        Write-Host "  🔧 Git Branch: $branch" -ForegroundColor Cyan
        if ($remote) {
            Write-Host "  🔗 Remote: $remote" -ForegroundColor Blue
        } else {
            Write-Host "  ⚠ No remote configured" -ForegroundColor Yellow
        }
        if ($changes -gt 0) {
            Write-Host "  📝 Uncommitted changes: $changes file(s)" -ForegroundColor Yellow
        } else {
            Write-Host "  ✅ Working directory clean" -ForegroundColor Green
        }
    }
    
    # ======================================================================
    # SECTION 6: FILE COUNTS
    # ======================================================================
    Write-Host "`n📁 FILE STATISTICS" -ForegroundColor Yellow
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    $allFiles = Get-ChildItem -Path $toolPath -Recurse -File -ErrorAction SilentlyContinue
    $ps1Files = $allFiles | Where-Object { $_.Extension -eq ".ps1" }
    $jsonFiles = $allFiles | Where-Object { $_.Extension -eq ".json" }
    $mdFiles = $allFiles | Where-Object { $_.Extension -eq ".md" }
    
    $totalSize = ($allFiles | Measure-Object -Property Length -Sum).Sum
    $sizeDisplay = if ($totalSize -gt 1MB) {
        "{0:N2} MB" -f ($totalSize / 1MB)
    } else {
        "{0:N2} KB" -f ($totalSize / 1KB)
    }
    
    Write-Host "  Total Files: $($allFiles.Count)" -ForegroundColor White
    Write-Host "  ├─ PowerShell: $($ps1Files.Count)" -ForegroundColor Cyan
    Write-Host "  ├─ JSON: $($jsonFiles.Count)" -ForegroundColor Yellow
    Write-Host "  ├─ Markdown: $($mdFiles.Count)" -ForegroundColor Green
    Write-Host "  └─ Other: $($allFiles.Count - $ps1Files.Count - $jsonFiles.Count - $mdFiles.Count)" -ForegroundColor Gray
    Write-Host "  Total Size: $sizeDisplay" -ForegroundColor Magenta
    
    # ======================================================================
    # SECTION 7: RECENT ACTIVITY
    # ======================================================================
    Write-Host "`n🕒 RECENT ACTIVITY" -ForegroundColor Yellow
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    $recentFiles = Get-ChildItem -Path $toolPath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -match "\.(ps1|json|md)$" } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 5
    
    foreach ($file in $recentFiles) {
        $relativePath = $file.FullName.Replace($toolPath, "").TrimStart("\")
        Write-Host "  📄 $relativePath" -ForegroundColor Gray
        Write-Host "     Modified: $($file.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor DarkGray
    }
    
    # ======================================================================
    # SECTION 8: SYSTEM INFO
    # ======================================================================
    Write-Host "`n💻 SYSTEM INFORMATION" -ForegroundColor Yellow
    Write-Host ("-" * 80) -ForegroundColor Gray
    
    Write-Host "  PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
    Write-Host "  OS: $([Environment]::OSVersion)" -ForegroundColor White
    Write-Host "  Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host "  User: $env:USERNAME" -ForegroundColor Yellow
    
    # ======================================================================
    # SECTION 9: QUICK ACTIONS
    # ======================================================================
    Write-Host "`n" + ("=" * 80) -ForegroundColor Cyan
    Write-Host "⚡ QUICK ACTIONS" -ForegroundColor White -BackgroundColor Blue
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Run Tool" -ForegroundColor Green
    Write-Host "  [2] Test All Modules" -ForegroundColor Yellow
    Write-Host "  [3] Open Modules Folder" -ForegroundColor Cyan
    Write-Host "  [4] View README" -ForegroundColor Magenta
    Write-Host "  [5] Check for Updates" -ForegroundColor Blue
    Write-Host "  [6] Refresh Dashboard" -ForegroundColor Gray
    Write-Host "  [7] Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host ("=" * 80) -ForegroundColor Cyan
    
    $choice = Read-Host "`nSelect action"
    
    switch ($choice) {
        "1" { 
            & $mainScript
        }
        "2" { 
            $testScript = Join-Path $toolPath "Test-All.ps1"
            if (Test-Path $testScript) {
                & $testScript
            } else {
                Write-Host "`n❌ Test-All.ps1 not found" -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
            Show-ToolDashboard
        }
        "3" { 
            explorer $modulesPath
            Write-Host "`n📂 Opening Modules folder..." -ForegroundColor Yellow
            Start-Sleep -Seconds 2
            Show-ToolDashboard
        }
        "4" { 
            if (Test-Path $readmeFile) {
                notepad $readmeFile
            } else {
                Write-Host "`n❌ README.md not found" -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
            Show-ToolDashboard
        }
        "5" { 
            Write-Host "`n🔍 Checking for updates..." -ForegroundColor Yellow
            # Check GitHub for updates
            if ($ghInstalled) {
                $latest = gh release view --repo bemnets-project-generator 2>$null
                if ($latest) {
                    Write-Host "  Latest version: $latest" -ForegroundColor Green
                } else {
                    Write-Host "  You have the latest version" -ForegroundColor Green
                }
            }
            Start-Sleep -Seconds 3
            Show-ToolDashboard
        }
        "6" { 
            Show-ToolDashboard
        }
        "7" { 
            Write-Host "`n👋 Goodbye!" -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "`n❌ Invalid option" -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-ToolDashboard
        }
    }
}

# Run the dashboard if script is executed directly
if ($MyInvocation.InvocationName -ne '.') {
    Show-ToolDashboard
}