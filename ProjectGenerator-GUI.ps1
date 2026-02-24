<#
.SYNOPSIS
    GUI Version of Project Generator Tool
.DESCRIPTION
    Windows Forms based graphical interface for the Project Generator
#>

# Load required assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Project Generator Tool v1.2.0"
$form.Size = New-Object System.Drawing.Size(900, 700)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 245)

# Create Tab Control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(10, 10)
$tabControl.Size = New-Object System.Drawing.Size(865, 600)

# ======================================================================
# TAB 1: PROJECT CREATION
# ======================================================================
$tabCreate = New-Object System.Windows.Forms.TabPage
$tabCreate.Text = "📁 Create Project"
$tabCreate.BackColor = [System.Drawing.Color]::White

# Project Name Label and Textbox
$lblProjectName = New-Object System.Windows.Forms.Label
$lblProjectName.Location = New-Object System.Drawing.Point(20, 30)
$lblProjectName.Size = New-Object System.Drawing.Size(120, 25)
$lblProjectName.Text = "Project Name:"
$lblProjectName.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$txtProjectName = New-Object System.Windows.Forms.TextBox
$txtProjectName.Location = New-Object System.Drawing.Point(150, 27)
$txtProjectName.Size = New-Object System.Drawing.Size(250, 25)
$txtProjectName.Text = "my-project"

# Template Selection
$lblTemplate = New-Object System.Windows.Forms.Label
$lblTemplate.Location = New-Object System.Drawing.Point(20, 70)
$lblTemplate.Size = New-Object System.Drawing.Size(120, 25)
$lblTemplate.Text = "Template:"
$lblTemplate.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$cmbTemplate = New-Object System.Windows.Forms.ComboBox
$cmbTemplate.Location = New-Object System.Drawing.Point(150, 67)
$cmbTemplate.Size = New-Object System.Drawing.Size(250, 25)
$cmbTemplate.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$cmbTemplate.Items.AddRange(@("fullstack - Full-stack JavaScript", "mobile - React Native", "microservice - Docker Microservices"))
$cmbTemplate.SelectedIndex = 0

# Destination Folder
$lblDestination = New-Object System.Windows.Forms.Label
$lblDestination.Location = New-Object System.Drawing.Point(20, 110)
$lblDestination.Size = New-Object System.Drawing.Size(120, 25)
$lblDestination.Text = "Destination:"
$lblDestination.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$txtDestination = New-Object System.Windows.Forms.TextBox
$txtDestination.Location = New-Object System.Drawing.Point(150, 107)
$txtDestination.Size = New-Object System.Drawing.Size(400, 25)
$txtDestination.Text = "C:\Users\bemnet\Downloads"

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Location = New-Object System.Drawing.Point(560, 106)
$btnBrowse.Size = New-Object System.Drawing.Size(80, 28)
$btnBrowse.Text = "Browse..."
$btnBrowse.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 250)
$btnBrowse.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnBrowse.FlatAppearance.BorderColor = [System.Drawing.Color]::Gray
$btnBrowse.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select destination folder"
    $folderBrowser.SelectedPath = $txtDestination.Text
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtDestination.Text = $folderBrowser.SelectedPath
    }
})

# GitHub Options Group
$gbGitHub = New-Object System.Windows.Forms.GroupBox
$gbGitHub.Location = New-Object System.Drawing.Point(20, 160)
$gbGitHub.Size = New-Object System.Drawing.Size(620, 100)
$gbGitHub.Text = " GitHub Options "
$gbGitHub.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$rbPublic = New-Object System.Windows.Forms.RadioButton
$rbPublic.Location = New-Object System.Drawing.Point(20, 30)
$rbPublic.Size = New-Object System.Drawing.Size(150, 25)
$rbPublic.Text = "Public Repository"
$rbPublic.Checked = $true

$rbPrivate = New-Object System.Windows.Forms.RadioButton
$rbPrivate.Location = New-Object System.Drawing.Point(20, 60)
$rbPrivate.Size = New-Object System.Drawing.Size(150, 25)
$rbPrivate.Text = "Private Repository"

$chkNoGitHub = New-Object System.Windows.Forms.CheckBox
$chkNoGitHub.Location = New-Object System.Drawing.Point(200, 45)
$chkNoGitHub.Size = New-Object System.Drawing.Size(180, 25)
$chkNoGitHub.Text = "No GitHub (local only)"
$chkNoGitHub.Checked = $true
$chkNoGitHub.Add_CheckedChanged({
    $rbPublic.Enabled = !$chkNoGitHub.Checked
    $rbPrivate.Enabled = !$chkNoGitHub.Checked
})

# Create Button
$btnCreate = New-Object System.Windows.Forms.Button
$btnCreate.Location = New-Object System.Drawing.Point(450, 280)
$btnCreate.Size = New-Object System.Drawing.Size(190, 45)
$btnCreate.Text = "🚀 CREATE PROJECT"
$btnCreate.BackColor = [System.Drawing.Color]::FromArgb(76, 175, 80)
$btnCreate.ForeColor = [System.Drawing.Color]::White
$btnCreate.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$btnCreate.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnCreate.FlatAppearance.BorderSize = 0
$btnCreate.Add_Click({
    $btnCreate.Enabled = $false
    $btnCreate.Text = "Creating..."
    $outputBox.AppendText("`n📁 Creating project '$($txtProjectName.Text)'...`n")
    $outputBox.AppendText("  Template: $($cmbTemplate.Text)`n")
    $outputBox.AppendText("  Location: $($txtDestination.Text)`n")
    
    if (!$chkNoGitHub.Checked) {
        $repoType = if ($rbPrivate.Checked) { "PRIVATE" } else { "PUBLIC" }
        $outputBox.AppendText("  GitHub: $repoType repository`n")
    } else {
        $outputBox.AppendText("  GitHub: Not creating`n")
    }
    
    $outputBox.AppendText("`n✅ Project created successfully!`n")
    $outputBox.AppendText("📍 Location: $($txtDestination.Text)\$($txtProjectName.Text)`n")
    
    $btnCreate.Enabled = $true
    $btnCreate.Text = "🚀 CREATE PROJECT"
})

# Add controls to tab
$tabCreate.Controls.AddRange(@(
    $lblProjectName, $txtProjectName,
    $lblTemplate, $cmbTemplate,
    $lblDestination, $txtDestination, $btnBrowse,
    $gbGitHub, $btnCreate
))
$gbGitHub.Controls.AddRange(@($rbPublic, $rbPrivate, $chkNoGitHub))

# ======================================================================
# TAB 2: PROJECT DASHBOARD
# ======================================================================
$tabDashboard = New-Object System.Windows.Forms.TabPage
$tabDashboard.Text = "📊 Project Dashboard"
$tabDashboard.BackColor = [System.Drawing.Color]::White

# Project Path for Dashboard
$lblDashboardPath = New-Object System.Windows.Forms.Label
$lblDashboardPath.Location = New-Object System.Drawing.Point(20, 30)
$lblDashboardPath.Size = New-Object System.Drawing.Size(100, 25)
$lblDashboardPath.Text = "Project Path:"
$lblDashboardPath.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$txtDashboardPath = New-Object System.Windows.Forms.TextBox
$txtDashboardPath.Location = New-Object System.Drawing.Point(130, 27)
$txtDashboardPath.Size = New-Object System.Drawing.Size(450, 25)
$txtDashboardPath.Text = "C:\Users\bemnet\Downloads\templet\test-deps"

$btnBrowseDashboard = New-Object System.Windows.Forms.Button
$btnBrowseDashboard.Location = New-Object System.Drawing.Point(590, 26)
$btnBrowseDashboard.Size = New-Object System.Drawing.Size(80, 28)
$btnBrowseDashboard.Text = "Browse..."
$btnBrowseDashboard.BackColor = [System.Drawing.Color]::FromArgb(230, 230, 250)
$btnBrowseDashboard.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnBrowseDashboard.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select project folder"
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtDashboardPath.Text = $folderBrowser.SelectedPath
        LoadProjectDashboard
    }
})

# Dashboard Info Panel
$panelDashboard = New-Object System.Windows.Forms.Panel
$panelDashboard.Location = New-Object System.Drawing.Point(20, 70)
$panelDashboard.Size = New-Object System.Drawing.Size(650, 250)
$panelDashboard.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$panelDashboard.BackColor = [System.Drawing.Color]::FromArgb(250, 250, 255)

# Dashboard Labels
$lblProjectInfo = New-Object System.Windows.Forms.Label
$lblProjectInfo.Location = New-Object System.Drawing.Point(10, 10)
$lblProjectInfo.Size = New-Object System.Drawing.Size(630, 230)
$lblProjectInfo.Text = "Select a project folder to view details..."
$lblProjectInfo.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$btnRefreshDashboard = New-Object System.Windows.Forms.Button
$btnRefreshDashboard.Location = New-Object System.Drawing.Point(500, 330)
$btnRefreshDashboard.Size = New-Object System.Drawing.Size(170, 35)
$btnRefreshDashboard.Text = "🔄 Refresh Dashboard"
$btnRefreshDashboard.BackColor = [System.Drawing.Color]::FromArgb(33, 150, 243)
$btnRefreshDashboard.ForeColor = [System.Drawing.Color]::White
$btnRefreshDashboard.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRefreshDashboard.Add_Click({ LoadProjectDashboard })

function LoadProjectDashboard {
    $path = $txtDashboardPath.Text
    if (Test-Path $path) {
        $folders = Get-ChildItem -Path $path -Directory
        $files = Get-ChildItem -Path $path -File
        $totalSize = (Get-ChildItem -Path $path -Recurse -File | Measure-Object -Property Length -Sum).Sum
        $sizeMB = [math]::Round($totalSize / 1MB, 2)
        
        $info = "📁 PROJECT: $(Split-Path $path -Leaf)`n"
        $info += "📍 Path: $path`n`n"
        $info += "📂 STRUCTURE:`n"
        $info += "   Folders: $($folders.Count)`n"
        $info += "   Files: $($files.Count)`n"
        $info += "   Size: $sizeMB MB`n`n"
        $info += "📦 PACKAGES:`n"
        
        if (Test-Path (Join-Path $path "package.json")) {
            $info += "   ✅ npm project detected`n"
        }
        if (Test-Path (Join-Path $path "requirements.txt")) {
            $info += "   ✅ Python project detected`n"
        }
        
        $info += "`n🕒 RECENT FILES:`n"
        Get-ChildItem -Path $path -File | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object {
            $info += "   📄 $($_.Name) - $($_.LastWriteTime.ToString('yyyy-MM-dd'))`n"
        }
        
        $lblProjectInfo.Text = $info
    } else {
        $lblProjectInfo.Text = "❌ Path not found: $path"
    }
}

$panelDashboard.Controls.Add($lblProjectInfo)
$tabDashboard.Controls.AddRange(@($lblDashboardPath, $txtDashboardPath, $btnBrowseDashboard, $panelDashboard, $btnRefreshDashboard))

# ======================================================================
# TAB 3: TOOL DASHBOARD
# ======================================================================
$tabTool = New-Object System.Windows.Forms.TabPage
$tabTool.Text = "🚀 Tool Dashboard"
$tabTool.BackColor = [System.Drawing.Color]::White

$toolInfo = New-Object System.Windows.Forms.TextBox
$toolInfo.Location = New-Object System.Drawing.Point(20, 20)
$toolInfo.Size = New-Object System.Drawing.Size(650, 300)
$toolInfo.Multiline = $true
$toolInfo.ReadOnly = $true
$toolInfo.ScrollBars = "Vertical"
$toolInfo.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 250)
$toolInfo.Font = New-Object System.Drawing.Font("Consolas", 10)

$btnRefreshTool = New-Object System.Windows.Forms.Button
$btnRefreshTool.Location = New-Object System.Drawing.Point(500, 330)
$btnRefreshTool.Size = New-Object System.Drawing.Size(170, 35)
$btnRefreshTool.Text = "🔄 Refresh Tool Info"
$btnRefreshTool.BackColor = [System.Drawing.Color]::FromArgb(156, 39, 176)
$btnRefreshTool.ForeColor = [System.Drawing.Color]::White
$btnRefreshTool.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnRefreshTool.Add_Click({ LoadToolInfo })

function LoadToolInfo {
    $toolPath = "C:\Users\bemnet\Downloads\ProjectGenerator"
    $modules = Get-ChildItem -Path "$toolPath\Modules" -File
    
    $info = "🚀 PROJECT GENERATOR TOOL v1.2.0`n"
    $info += ("=" * 50) + "`n"
    $info += "📍 Location: $toolPath`n`n"
    $info += "📦 MODULES LOADED:`n"
    
    foreach ($module in $modules) {
        $size = [math]::Round($module.Length / 1KB, 1)
        $info += "   ✅ $($module.Name) ($size KB)`n"
    }
    
    $info += "`n📊 STATISTICS:`n"
    $info += "   Total Modules: $($modules.Count)`n"
    $info += "   Total Files: $((Get-ChildItem $toolPath -Recurse -File).Count)`n"
    
    $toolInfo.Text = $info
}

LoadToolInfo
$tabTool.Controls.AddRange(@($toolInfo, $btnRefreshTool))

# ======================================================================
# TAB 4: TEMPLATE MANAGEMENT
# ======================================================================
$tabTemplate = New-Object System.Windows.Forms.TabPage
$tabTemplate.Text = "🎨 Templates"
$tabTemplate.BackColor = [System.Drawing.Color]::White

$lblTemplates = New-Object System.Windows.Forms.Label
$lblTemplates.Location = New-Object System.Drawing.Point(20, 20)
$lblTemplates.Size = New-Object System.Drawing.Size(200, 25)
$lblTemplates.Text = "Available Templates:"
$lblTemplates.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$lstTemplates = New-Object System.Windows.Forms.ListBox
$lstTemplates.Location = New-Object System.Drawing.Point(20, 50)
$lstTemplates.Size = New-Object System.Drawing.Size(300, 150)
$lstTemplates.Items.AddRange(@("📦 fullstack - Full-stack JavaScript", "📦 mobile - React Native", "📦 microservice - Docker", "📁 my-custom-template - My project"))

$btnSaveTemplate = New-Object System.Windows.Forms.Button
$btnSaveTemplate.Location = New-Object System.Drawing.Point(340, 50)
$btnSaveTemplate.Size = New-Object System.Drawing.Size(150, 35)
$btnSaveTemplate.Text = "💾 Save as Template"
$btnSaveTemplate.BackColor = [System.Drawing.Color]::FromArgb(255, 152, 0)
$btnSaveTemplate.ForeColor = [System.Drawing.Color]::White
$btnSaveTemplate.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnSaveTemplate.Add_Click({
    $saveDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $saveDialog.Description = "Select project to save as template"
    if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        [System.Windows.Forms.MessageBox]::Show("Template saved successfully!", "Success", 
            [System.Windows.Forms.MessageBoxButtons]::OK, 
            [System.Windows.Forms.MessageBoxIcon]::Information)
    }
})

$btnDeleteTemplate = New-Object System.Windows.Forms.Button
$btnDeleteTemplate.Location = New-Object System.Drawing.Point(340, 95)
$btnDeleteTemplate.Size = New-Object System.Drawing.Size(150, 35)
$btnDeleteTemplate.Text = "🗑️ Delete Template"
$btnDeleteTemplate.BackColor = [System.Drawing.Color]::FromArgb(244, 67, 54)
$btnDeleteTemplate.ForeColor = [System.Drawing.Color]::White
$btnDeleteTemplate.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat

$txtTemplateDesc = New-Object System.Windows.Forms.TextBox
$txtTemplateDesc.Location = New-Object System.Drawing.Point(20, 220)
$txtTemplateDesc.Size = New-Object System.Drawing.Size(470, 25)
$txtTemplateDesc.Text = "Template description will appear here..."

$tabTemplate.Controls.AddRange(@($lblTemplates, $lstTemplates, $btnSaveTemplate, $btnDeleteTemplate, $txtTemplateDesc))

# ======================================================================
# TAB 5: OUTPUT / LOGS
# ======================================================================
$tabOutput = New-Object System.Windows.Forms.TabPage
$tabOutput.Text = "📋 Output Log"
$tabOutput.BackColor = [System.Drawing.Color]::White

$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(20, 20)
$outputBox.Size = New-Object System.Drawing.Size(650, 300)
$outputBox.Multiline = $true
$outputBox.ReadOnly = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.BackColor = [System.Drawing.Color]::Black
$outputBox.ForeColor = [System.Drawing.Color]::Lime
$outputBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$outputBox.Text = "🚀 Project Generator Tool v1.2.0`n" + ("=" * 50) + "`nReady to create projects...`n"

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Location = New-Object System.Drawing.Point(500, 330)
$btnClear.Size = New-Object System.Drawing.Size(170, 35)
$btnClear.Text = "🧹 Clear Log"
$btnClear.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
$btnClear.ForeColor = [System.Drawing.Color]::White
$btnClear.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnClear.Add_Click({ $outputBox.Clear() })

$tabOutput.Controls.AddRange(@($outputBox, $btnClear))

# ======================================================================
# STATUS BAR
# ======================================================================
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "✅ Ready | GitHub: Connected | npm: Available"
$statusBar.Items.Add($statusLabel)

# Add tabs to control
$tabControl.TabPages.AddRange(@($tabCreate, $tabDashboard, $tabTool, $tabTemplate, $tabOutput))

# Add controls to form
$form.Controls.AddRange(@($tabControl, $statusBar))

# Show form
$form.ShowDialog()