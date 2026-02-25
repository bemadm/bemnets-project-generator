BeforeDiscovery {
    # Load the module to test
    . "$PSScriptRoot\..\Modules\Logger.ps1"
}

Describe "Logger Module" {
    Context "Initialization" {
        It "Should initialize correctly with dry run mode" {
            Initialize-Logger -DryRun $true
            Get-DryRunMode | Should -Be $true
        }

        It "Should initialize correctly with normal mode" {
            Initialize-Logger -DryRun $false
            Get-DryRunMode | Should -Be $false
        }
    }

    Context "Dry Run Mode" {
        It "Should toggle dry run mode" {
            Set-DryRunMode -Enabled $true
            Get-DryRunMode | Should -Be $true
            
            Set-DryRunMode -Enabled $false
            Get-DryRunMode | Should -Be $false
        }
    }
}
