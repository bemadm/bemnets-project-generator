<#
.SYNOPSIS
    Manages project templates
.DESCRIPTION
    Handles template creation, listing, and application
#>

# Template storage location
$script:templateRoot = Join-Path $env:USERPROFILE ".project-generator-templates"
$script:internalTemplatesDir = Join-Path $PSScriptRoot "..\" "Templates"

# Default templates will be loaded from the Templates directory
$script:defaultTemplates = @{}

function Load-InternalTemplates {
    if (Test-Path $script:internalTemplatesDir) {
        Get-ChildItem -Path $script:internalTemplatesDir -Filter "*.json" | ForEach-Object {
            try {
                $content = Get-Content $_.FullName | ConvertFrom-Json
                $script:defaultTemplates[$content.name] = $content
            } catch {
                Write-Log "Failed to load template from $($_.Name): $_" -Level "ERROR"
            }
        }
    }
}

# Initial load
Load-InternalTemplates

function Initialize-TemplateSystem {
    <#
    .SYNOPSIS
        Creates template directory structure
    #>
    
    if (-not (Test-Path $script:templateRoot)) {
        New-Item -ItemType Directory -Path $script:templateRoot -Force | Out-Null
        Write-Host "✅ Created template directory: $script:templateRoot" -ForegroundColor Green
    }
}

function Get-AvailableTemplates {
    <#
    .SYNOPSIS
        Returns list of available templates
    #>
    
    $templates = @()
    
    # Add default templates
    foreach ($key in $script:defaultTemplates.Keys) {
        $templates += [PSCustomObject]@{
            Name = $key
            Description = $script:defaultTemplates[$key].Description
            Type = "Built-in"
            Path = $null
        }
    }
    
    # Add custom templates from user directory
    if (Test-Path $script:templateRoot) {
        Get-ChildItem -Path $script:templateRoot -Directory | ForEach-Object {
            $configFile = Join-Path $_.FullName "template.json"
            if (Test-Path $configFile) {
                $config = Get-Content $configFile | ConvertFrom-Json
                $templates += [PSCustomObject]@{
                    Name = $_.Name
                    Description = $config.Description
                    Type = "Custom"
                    Path = $_.FullName
                }
            }
        }
    }
    
    return $templates
}

function Show-TemplateMenu {
    <#
    .SYNOPSIS
        Displays interactive template selection menu
    #>
    
    $templates = Get-AvailableTemplates
    
    if ($templates.Count -eq 0) {
        Write-Host "`n❌ No templates available!" -ForegroundColor Red
        Pause-Menu
        return $null
    }
    
    Clear-Host
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host "SELECT PROJECT TEMPLATE" -ForegroundColor White -BackgroundColor Blue
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host ""
    
    $index = 1
    $templateMap = @{}
    
    # Group templates by type
    $builtIn = $templates | Where-Object { $_.Type -eq "Built-in" }
    $custom = $templates | Where-Object { $_.Type -eq "Custom" }
    
    if ($builtIn.Count -gt 0) {
        Write-Host "📦 BUILT-IN TEMPLATES:" -ForegroundColor Green
        Write-Host ("-" * 40) -ForegroundColor Gray
        
        foreach ($template in $builtIn) {
            Write-Host "$index. $($template.Name)" -ForegroundColor White -NoNewline
            Write-Host " - $($template.Description)" -ForegroundColor Gray
            $templateMap[$index.ToString()] = $template
            $index++
        }
        Write-Host ""
    }
    
    if ($custom.Count -gt 0) {
        Write-Host "📁 CUSTOM TEMPLATES:" -ForegroundColor Yellow
        Write-Host ("-" * 40) -ForegroundColor Gray
        
        foreach ($template in $custom) {
            Write-Host "$index. $($template.Name)" -ForegroundColor White -NoNewline
            Write-Host " - $($template.Description)" -ForegroundColor Gray
            $templateMap[$index.ToString()] = $template
            $index++
        }
        Write-Host ""
    }
    
    Write-Host ("=" * 60) -ForegroundColor Cyan
    Write-Host "0. Cancel / Back to main menu" -ForegroundColor Yellow
    Write-Host ("=" * 60) -ForegroundColor Cyan
    
    $choice = Read-Host "`nSelect template number"
    
    if ($choice -eq "0") {
        return $null
    }
    
    if ($templateMap.ContainsKey($choice)) {
        $selected = $templateMap[$choice]
        Write-Host "`n✅ Selected: $($selected.Name)" -ForegroundColor Green
        Start-Sleep -Seconds 1
        return $selected
    }
    
    Write-Host "❌ Invalid selection" -ForegroundColor Red
    Start-Sleep -Seconds 2
    return $null
}

function Save-AsTemplate {
    <#
    .SYNOPSIS
        Saves current project as a template
    #>
    param(
        [string]$ProjectPath,
        [string]$TemplateName,
        [string]$Description
    )
    
    Initialize-TemplateSystem
    
    $templatePath = Join-Path $script:templateRoot $TemplateName
    
    if (Test-Path $templatePath) {
        $overwrite = Read-Host "Template exists. Overwrite? [Y/N]"
        if ($overwrite -notmatch "^[Yy]$") {
            return $false
        }
        Remove-Item $templatePath -Recurse -Force
    }
    
    # Copy project structure
    Copy-Item -Path $ProjectPath -Destination $templatePath -Recurse
    
    # Create template config
    $config = @{
        Name = $TemplateName
        Description = $Description
        Created = Get-Date -Format "yyyy-MM-dd"
        OriginalPath = $ProjectPath
    }
    
    $config | ConvertTo-Json | Out-File (Join-Path $templatePath "template.json") -Encoding UTF8
    
    Write-Host "✅ Template saved: $TemplateName" -ForegroundColor Green
    return $true
}
function Apply-Template {
    <#
    .SYNOPSIS
        Applies a template to create a new project structure
    .DESCRIPTION
        Handles both built-in and custom templates, creates directories, files, and replaces variables
    .PARAMETER Template
        Template object containing Name, Type, Path, and Description
    .PARAMETER DestinationPath
        Where to create the project
    .PARAMETER ProjectName
        Name of the project (replaces {{projectName}} variables)
    .PARAMETER Variables
        Additional variables to replace in template files
    .EXAMPLE
        Apply-Template -Template $template -DestinationPath "C:\Projects\MyApp" -ProjectName "MyApp"
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSObject]$Template,
        
        [Parameter(Mandatory=$true)]
        [string]$DestinationPath,
        
        [Parameter(Mandatory=$true)]
        [string]$ProjectName,
        
        [Parameter(Mandatory=$false)]
        [hashtable]$Variables = @{}
    )
    
    Write-Host "`n📋 Applying template: $($Template.Name)" -ForegroundColor Cyan
    Write-Host ("=" * 50) -ForegroundColor Gray
    Write-Host "  Template Type: $($Template.Type)" -ForegroundColor Yellow
    Write-Host "  Destination: $DestinationPath" -ForegroundColor Yellow
    Write-Host "  Project Name: $ProjectName" -ForegroundColor Yellow
    
    # Add project name to variables
    $Variables["projectName"] = $ProjectName
    
    # Ensure destination path exists
    if (-not (Test-Path $DestinationPath)) {
        try {
            New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
            Write-Host "  ✅ Created destination directory" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ Failed to create destination directory: $_" -ForegroundColor Red
            return $false
        }
    }
    
    # Handle based on template type
    if ($Template.Type -eq "Built-in") {
        return Apply-BuiltInTemplateInternal -Template $Template -DestinationPath $DestinationPath -Variables $Variables
    }
    elseif ($Template.Type -eq "Custom") {
        return Apply-CustomTemplateInternal -Template $Template -DestinationPath $DestinationPath -Variables $Variables
    }
    else {
        Write-Host "  ❌ Unknown template type: $($Template.Type)" -ForegroundColor Red
        return $false
    }
}

function Apply-BuiltInTemplateInternal {
    param(
        [PSObject]$Template,
        [string]$DestinationPath,
        [hashtable]$Variables
    )
    
    Write-Log "Using built-in template: $($Template.Name)" -Level "INFO"
    
    # Check if template exists in defaultTemplates
    if (-not $script:defaultTemplates.ContainsKey($Template.Name)) {
        Write-Log "Template '$($Template.Name)' not found in defaultTemplates!" -Level "ERROR"
        return $false
    }
    
    $templateData = $script:defaultTemplates[$Template.Name]
    $fileCount = 0
    $dirCount = 0
    
    # Create all directories from structure if available
    if ($templateData.Structure) {
        Write-Log "Creating directory structure..." -Level "INFO"
        
        if (Get-DryRunMode) {
            Write-Log "DRY RUN: Would create directory structure from template definition" -Level "DRYRUN"
        } else {
            $dirCount = Create-StructureFromDefinition -Structure $templateData.Structure -BasePath $DestinationPath
            Write-Log "Created $dirCount directories" -Level "SUCCESS"
        }
    }
    
    # Create all files
    Write-Log "Creating files..." -Level "INFO"
    foreach ($file in $templateData.Files.Keys) {
        $filePath = Join-Path $DestinationPath $file
        $fileDir = Split-Path $filePath -Parent
        
        if (Get-DryRunMode) {
            Write-Log "DRY RUN: Would create file: $file" -Level "DRYRUN"
            $fileCount++
            continue
        }
        
        # Create directory for file if it doesn't exist
        if (-not (Test-Path $fileDir) -and $fileDir -ne $DestinationPath) {
            try {
                New-Item -ItemType Directory -Path $fileDir -Force | Out-Null
            } catch {
                Write-Log "Failed to create directory for $file : $_" -Level "ERROR"
                continue
            }
        }
        
        # Get file content and replace variables
        try {
            $content = $templateData.Files.$file
            
            # Replace all variables in content
            foreach ($var in $Variables.Keys) {
                $content = $content -replace "{{$var}}", $Variables[$var]
            }
            
            # Write file
            $content | Out-File -FilePath $filePath -Encoding UTF8 -Force
            Write-Log "Created: $file" -Level "SUCCESS"
            $fileCount++
        } catch {
            Write-Log "Failed to create $file : $_" -Level "ERROR"
        }
    }
    
    if (Get-DryRunMode) {
        Write-Log "DRY RUN Summary: Would create $fileCount files" -Level "DRYRUN"
    } else {
        Write-Log "Summary: $fileCount files, $dirCount directories created" -Level "INFO"
    }
    
    Write-Log "Template applied successfully!" -Level "SUCCESS"
    return $true
}

function Apply-CustomTemplateInternal {
    param(
        [PSObject]$Template,
        [string]$DestinationPath,
        [hashtable]$Variables
    )
    
    Write-Host "  📁 Using custom template from: $($Template.Path)" -ForegroundColor Yellow
    
    # Check if template path exists
    if (-not (Test-Path $Template.Path)) {
        Write-Host "  ❌ Custom template path not found: $($Template.Path)" -ForegroundColor Red
        return $false
    }
    
    try {
        # Copy all files from template
        Write-Host "  Copying template files..." -ForegroundColor Yellow
        Copy-Item -Path "$($Template.Path)\*" -Destination $DestinationPath -Recurse -Force -ErrorAction Stop
        Write-Host "  ✅ Template files copied" -ForegroundColor Green
        
        # Process variable replacement in all files
        Write-Host "`n  Replacing variables in files..." -ForegroundColor Cyan
        $fileCount = 0
        $totalFiles = 0
        
        Get-ChildItem -Path $DestinationPath -Recurse -File | ForEach-Object {
            $totalFiles++
            try {
                $content = Get-Content $_.FullName -Raw -ErrorAction Stop
                $originalContent = $content
                
                # Replace all variables
                foreach ($var in $Variables.Keys) {
                    $content = $content -replace "{{$var}}", $Variables[$var]
                }
                
                # Only write if content changed
                if ($content -ne $originalContent) {
                    $content | Out-File $_.FullName -Encoding UTF8 -Force -ErrorAction Stop
                    Write-Host "    ✅ Updated: $($_.FullName)" -ForegroundColor Green
                    $fileCount++
                }
            } catch {
                Write-Host "    ⚠ Could not process: $($_.Name) - $_" -ForegroundColor Yellow
            }
        }
        
        Write-Host "`n  📊 Summary: Processed $totalFiles files, updated $fileCount with variables" -ForegroundColor Cyan
        Write-Host "  ✅ Custom template applied successfully!" -ForegroundColor Green
        return $true
        
    } catch {
        Write-Host "  ❌ Failed to apply custom template: $_" -ForegroundColor Red
        return $false
    }
}

function Create-StructureFromDefinition {
    <#
    .SYNOPSIS
        Creates directory structure from a nested hashtable definition
    #>
    param(
        [Parameter(Mandatory=$true)]
        $Structure,
        
        [Parameter(Mandatory=$true)]
        [string]$BasePath,
        
        [string]$CurrentPath = ""
    )
    
    $dirCount = 0
    
    foreach ($item in $Structure.Keys) {
        $itemPath = if ($CurrentPath) {
            Join-Path $BasePath $CurrentPath $item
        } else {
            Join-Path $BasePath $item
        }
        
        if ($Structure[$item] -is [hashtable]) {
            # It's a directory
            if (-not (Test-Path $itemPath)) {
                try {
                    New-Item -ItemType Directory -Path $itemPath -Force | Out-Null
                    Write-Host "    📁 Created: $item" -ForegroundColor Gray
                    $dirCount++
                } catch {
                    Write-Host "    ❌ Failed to create directory $item : $_" -ForegroundColor Red
                }
            }
            
            # Recursively process subitems
            $newPath = if ($CurrentPath) {
                "$CurrentPath\$item"
            } else {
                $item
            }
            
            $dirCount += Create-StructureFromDefinition -Structure $Structure[$item] -BasePath $BasePath -CurrentPath $newPath
        }
    }
    
    return $dirCount
}

# Also add a helper function to validate template before applying
function Test-Template {
    <#
    .SYNOPSIS
        Validates if a template can be applied
    #>
    param(
        [PSObject]$Template
    )
    
    Write-Host "`n🔍 Validating template: $($Template.Name)" -ForegroundColor Cyan
    
    $issues = @()
    
    if ($Template.Type -eq "Built-in") {
        if (-not $script:defaultTemplates.ContainsKey($Template.Name)) {
            $issues += "Built-in template '$($Template.Name)' not found in defaultTemplates"
        } else {
            $data = $script:defaultTemplates[$Template.Name]
            if (-not $data.Files -or $data.Files.Count -eq 0) {
                $issues += "Template has no files defined"
            }
        }
    }
    elseif ($Template.Type -eq "Custom") {
        if (-not $Template.Path) {
            $issues += "Custom template has no path specified"
        }
        elseif (-not (Test-Path $Template.Path)) {
            $issues += "Custom template path does not exist: $($Template.Path)"
        }
        else {
            # Check for template.json
            $configFile = Join-Path $Template.Path "template.json"
            if (-not (Test-Path $configFile)) {
                $issues += "Custom template missing template.json configuration"
            }
        }
    }
    else {
        $issues += "Unknown template type: $($Template.Type)"
    }
    
    if ($issues.Count -eq 0) {
        Write-Host "  ✅ Template is valid" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ❌ Template has issues:" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "     - $issue" -ForegroundColor Yellow
        }
        return $false
    }
}

function Show-TemplateManagementMenu {
    <#
    .SYNOPSIS
        Shows template management submenu
    #>
    
    do {
        Clear-Host
        Write-Host ("=" * 60) -ForegroundColor Cyan
        Write-Host "TEMPLATE MANAGEMENT" -ForegroundColor White -BackgroundColor Blue
        Write-Host ("=" * 60) -ForegroundColor Cyan
        Write-Host "1. List available templates" -ForegroundColor Yellow
        Write-Host "2. Save current project as template" -ForegroundColor Yellow
        Write-Host "3. Delete custom template" -ForegroundColor Yellow
        Write-Host "4. Export template" -ForegroundColor Yellow
        Write-Host "5. Import template" -ForegroundColor Yellow
        Write-Host "6. Back to main menu" -ForegroundColor Red
        Write-Host ("=" * 60) -ForegroundColor Cyan
        
        $choice = Read-Host "Select option"
        
        switch ($choice) {
            "1" {
                $templates = Get-AvailableTemplates
                Write-Host "`nAvailable Templates:" -ForegroundColor Cyan
                foreach ($t in $templates) {
                    Write-Host "  - $($t.Name): $($t.Description) [$($t.Type)]" -ForegroundColor White
                }
                Pause-Menu
            }
            "2" {
                $projectPath = Read-Host "Enter project path to save as template"
                if (Test-Path $projectPath) {
                    $name = Read-Host "Enter template name"
                    $desc = Read-Host "Enter template description"
                    Save-AsTemplate -ProjectPath $projectPath -TemplateName $name -Description $desc
                } else {
                    Write-Host "❌ Path not found" -ForegroundColor Red
                }
                Pause-Menu
            }
            "3" {
                $templates = Get-AvailableTemplates | Where-Object { $_.Type -eq "Custom" }
                if ($templates.Count -eq 0) {
                    Write-Host "No custom templates found" -ForegroundColor Yellow
                } else {
                    Write-Host "`nCustom Templates:" -ForegroundColor Cyan
                    $index = 1
                    $templateMap = @{}
                    foreach ($t in $templates) {
                        Write-Host "$index. $($t.Name)" -ForegroundColor White
                        $templateMap[$index.ToString()] = $t
                        $index++
                    }
                    
                    $delChoice = Read-Host "Select template to delete"
                    if ($templateMap.ContainsKey($delChoice)) {
                        Remove-Item $templateMap[$delChoice].Path -Recurse -Force
                        Write-Host "✅ Template deleted" -ForegroundColor Green
                    }
                }
                Pause-Menu
            }
            "4" {
                $templates = Get-AvailableTemplates | Where-Object { $_.Type -eq "Custom" }
                if ($templates.Count -eq 0) {
                    Write-Host "No custom templates found" -ForegroundColor Yellow
                } else {
                    $exportPath = Read-Host "Enter export path (zip file)"
                    # Simple export - copy to temp and zip
                    Write-Host "Export feature coming soon!" -ForegroundColor Yellow
                }
                Pause-Menu
            }
            "5" {
                $importPath = Read-Host "Enter template file to import"
                Write-Host "Import feature coming soon!" -ForegroundColor Yellow
                Pause-Menu
            }
        }
    } while ($choice -ne "6")
	function Export-Template {
    <#
    .SYNOPSIS
        Exports template to zip file
    #>
    param(
        [string]$TemplateName,
        [string]$ExportPath
    )
    
    $templatePath = Join-Path $script:templateRoot $TemplateName
    
    if (-not (Test-Path $templatePath)) {
        Write-Host "❌ Template not found: $TemplateName" -ForegroundColor Red
        return $false
    }
    
    # Ensure export path has .zip extension
    if (-not $ExportPath.EndsWith(".zip")) {
        $ExportPath += ".zip"
    }
    
    # Create temp directory for export
    $tempDir = Join-Path $env:TEMP "template_export_$(Get-Date -Format 'yyyyMMddHHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # Copy template files
    Copy-Item -Path "$templatePath\*" -Destination $tempDir -Recurse
    
    # Create manifest
    $manifest = @{
        Name = $TemplateName
        ExportDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Version = "1.0.0"
        Files = (Get-ChildItem -Path $tempDir -Recurse -File).Count
    }
    $manifest | ConvertTo-Json | Out-File (Join-Path $tempDir "export-manifest.json") -Encoding UTF8
    
    # Create zip
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $ExportPath)
    
    # Cleanup
    Remove-Item $tempDir -Recurse -Force
    
    Write-Host "✅ Template exported to: $ExportPath" -ForegroundColor Green
    return $true
}

function Import-Template {
    <#
    .SYNOPSIS
        Imports template from zip file
    #>
    param(
        [string]$ImportPath
    )
    
    if (-not (Test-Path $ImportPath)) {
        Write-Host "❌ File not found: $ImportPath" -ForegroundColor Red
        return $false
    }
    
    # Extract to temp directory
    $tempDir = Join-Path $env:TEMP "template_import_$(Get-Date -Format 'yyyyMMddHHmmss')"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ImportPath, $tempDir)
    
    # Check for template.json
    $templateConfig = Get-ChildItem -Path $tempDir -Recurse -Filter "template.json" | Select-Object -First 1
    
    if ($templateConfig) {
        $config = Get-Content $templateConfig.FullName | ConvertFrom-Json
        $templateName = $config.Name
        
        # Create template directory
        $templatePath = Join-Path $script:templateRoot $templateName
        
        if (Test-Path $templatePath) {
            $overwrite = Read-Host "Template '$templateName' exists. Overwrite? [Y/N]"
            if ($overwrite -match "^[Yy]$") {
                Remove-Item $templatePath -Recurse -Force
            } else {
                Remove-Item $tempDir -Recurse -Force
                return $false
            }
        }
        
        # Copy template files
        Copy-Item -Path "$tempDir\*" -Destination $templatePath -Recurse
        Write-Host "✅ Template imported: $templateName" -ForegroundColor Green
    } else {
        Write-Host "❌ Invalid template package: no template.json found" -ForegroundColor Red
    }
    
    # Cleanup
    Remove-Item $tempDir -Recurse -Force
    
    return $true
}
function Get-TemplateStats {
    <#
    .SYNOPSIS
        Shows template usage statistics
    #>
    
    $stats = @{
        TotalTemplates = 0
        BuiltInTemplates = 0
        CustomTemplates = 0
        MostUsed = @{}
        TemplateSizes = @{}
    }
    
    $templates = Get-AvailableTemplates
    $stats.TotalTemplates = $templates.Count
    $stats.BuiltInTemplates = ($templates | Where-Object { $_.Type -eq "Built-in" }).Count
    $stats.CustomTemplates = ($templates | Where-Object { $_.Type -eq "Custom" }).Count
    
    # Get template sizes for custom templates
    foreach ($template in $templates | Where-Object { $_.Type -eq "Custom" }) {
        $size = (Get-ChildItem $template.Path -Recurse | Measure-Object -Property Length -Sum).Sum
        $stats.TemplateSizes[$template.Name] = [math]::Round($size / 1MB, 2)
    }
    
    return $stats
}

function Show-TemplateStats {
    $stats = Get-TemplateStats
    
    Write-Host "`n📊 Template Statistics:" -ForegroundColor Cyan
    Write-Host "  Total Templates: $($stats.TotalTemplates)" -ForegroundColor White
    Write-Host "  Built-in: $($stats.BuiltInTemplates)" -ForegroundColor Green
    Write-Host "  Custom: $($stats.CustomTemplates)" -ForegroundColor Yellow
    
    if ($stats.TemplateSizes.Count -gt 0) {
        Write-Host "`n  Template Sizes:" -ForegroundColor Cyan
        foreach ($name in $stats.TemplateSizes.Keys) {
            Write-Host "    $name : $($stats.TemplateSizes[$name]) MB" -ForegroundColor Gray
        }
    }
}

function Apply-BuiltInTemplate {
    <#
    .SYNOPSIS
        Applies a built-in template to the destination
    #>
    param(
        [string]$TemplateName,
        [string]$DestinationPath,
        [string]$ProjectName
    )
    
    $templateData = $script:defaultTemplates[$TemplateName]
    
    if (-not $templateData) {
        Write-Host "❌ Template not found: $TemplateName" -ForegroundColor Red
        return $false
    }
    
    Write-Host "`nCreating $TemplateName structure..." -ForegroundColor Cyan
    
    # Create directories and files from template
    $fileCount = 0
    
    # Process each file in the template
    foreach ($file in $templateData.Files.Keys) {
        $filePath = Join-Path $DestinationPath $file
        $fileDir = Split-Path $filePath -Parent
        
        # Create directory if needed
        if (-not (Test-Path $fileDir)) {
            New-Item -ItemType Directory -Path $fileDir -Force | Out-Null
        }
        
        # Get file content and replace variables
        $content = $templateData.Files[$file]
        $content = $content -replace "{{projectName}}", $ProjectName
        
        # Write file
        $content | Out-File -FilePath $filePath -Encoding UTF8 -Force
        Write-Host "  ✅ Created: $file" -ForegroundColor Green
        $fileCount++
    }
    
    # Create additional directories from structure
    if ($templateData.Structure) {
        Create-StructureFromDefinition -Structure $templateData.Structure -BasePath $DestinationPath
    }
    
    Write-Host "`n✅ Template applied: $fileCount files created" -ForegroundColor Green
    return $true
}

function Apply-CustomTemplate {
    <#
    .SYNOPSIS
        Applies a custom template from saved location
    #>
    param(
        [string]$TemplatePath,
        [string]$DestinationPath,
        [string]$ProjectName
    )
    
    if (-not (Test-Path $TemplatePath)) {
        Write-Host "❌ Template path not found: $TemplatePath" -ForegroundColor Red
        return $false
    }
    
    Write-Host "`nCopying custom template files..." -ForegroundColor Cyan
    
    # Copy all files from template
    Copy-Item -Path "$TemplatePath\*" -Destination $DestinationPath -Recurse -Force
    
    # Process variable replacement in files
    $fileCount = 0
    Get-ChildItem -Path $DestinationPath -Recurse -File | ForEach-Object {
        $content = Get-Content $_.FullName -Raw
        if ($content -match "{{projectName}}") {
            $content = $content -replace "{{projectName}}", $ProjectName
            $content | Out-File $_.FullName -Encoding UTF8 -Force
            $fileCount++
        }
    }
    
    Write-Host "✅ Template applied: $fileCount files updated with project name" -ForegroundColor Green
    return $true
}

function Create-StructureFromDefinition {
    <#
    .SYNOPSIS
        Creates directory structure from a nested hashtable definition
    #>
    param(
        [hashtable]$Structure,
        [string]$BasePath
    )
    
    foreach ($item in $Structure.Keys) {
        $itemPath = Join-Path $BasePath $item
        
        if ($Structure[$item] -is [hashtable]) {
            # It's a directory
            if (-not (Test-Path $itemPath)) {
                New-Item -ItemType Directory -Path $itemPath -Force | Out-Null
            }
            # Recursively process subitems
            Create-StructureFromDefinition -Structure $Structure[$item] -BasePath $itemPath
        }
    }
}
}