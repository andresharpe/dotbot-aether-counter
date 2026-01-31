#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\Printer\Printer.psd1'
    Import-Module $ModulePath -Force

    # Use environment variable set by runner script (supports discovery)
    $script:TestDeviceIP = $env:PRINTER_TEST_IP

    if (-not $script:TestDeviceIP) {
        Write-Warning "Integration tests skipped: No device configured (set PRINTER_TEST_IP or use run-integration-tests.ps1)"
    }
}

Describe 'Basic Connectivity Integration Tests' -Tag 'Integration' {
    BeforeAll {
        if ($env:PRINTER_TEST_IP) {
            # Disconnect any existing session
            Disconnect-Printer -ErrorAction SilentlyContinue
        }
    }

    AfterAll {
        if ($env:PRINTER_TEST_IP) {
            # Clean up
            Disconnect-Printer -ErrorAction SilentlyContinue
        }
    }

    Context 'Find-Printer Discovery' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Discovers devices via ARP cache' {
            $devices = Find-Printer

            # Note: This may or may not find devices depending on ARP cache state
            # We just verify it runs without error
            { Find-Printer } | Should -Not -Throw
        }

        It 'Returns device objects with required properties when devices are found' {
            $devices = Find-Printer

            if ($devices.Count -gt 0) {
                $devices[0].PSObject.Properties.Name | Should -Contain 'IP'
                $devices[0].PSObject.Properties.Name | Should -Contain 'Name'
                $devices[0].PSObject.Properties.Name | Should -Contain 'Port'
            }
        }

        It 'Supports -FullScan parameter' {
            # Just verify it doesn't throw - full scan takes time
            { Find-Printer -FullScan -TimeoutSec 1 } | Should -Not -Throw
        }
    }

    Context 'Connection Management' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Connects to device successfully' {
            $result = Connect-Printer -IPAddress $env:PRINTER_TEST_IP

            $result | Should -Be $true
        }

        It 'Test-PrinterConnection returns true when connected' {
            Connect-Printer -IPAddress $env:PRINTER_TEST_IP

            $result = Test-PrinterConnection

            $result | Should -Be $true
        }

        It 'Get-PrinterConfiguration returns configuration' {
            Connect-Printer -IPAddress $env:PRINTER_TEST_IP

            $config = Get-PrinterConfiguration

            $config | Should -Not -BeNullOrEmpty
            $config.IPAddress | Should -Be $env:PRINTER_TEST_IP
            $config.Connected | Should -Be $true
            $config.CharactersPerLine | Should -Be 40
        }

        It 'Disconnects successfully' {
            Connect-Printer -IPAddress $env:PRINTER_TEST_IP

            { Disconnect-Printer } | Should -Not -Throw

            $result = Test-PrinterConnection -ErrorAction SilentlyContinue

            $result | Should -Be $false
        }

        It 'Can reconnect after disconnect' {
            Connect-Printer -IPAddress $env:PRINTER_TEST_IP
            Disconnect-Printer

            $result = Connect-Printer -IPAddress $env:PRINTER_TEST_IP

            $result | Should -Be $true
        }
    }

    Context 'Connection with Custom Parameters' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Accepts custom CharactersPerLine' {
            $result = Connect-Printer -IPAddress $env:PRINTER_TEST_IP -CharactersPerLine 42

            $result | Should -Be $true

            $config = Get-PrinterConfiguration
            $config.CharactersPerLine | Should -Be 42

            Disconnect-Printer
        }

        It 'Accepts custom Port' {
            # Default port 9100 should work
            $result = Connect-Printer -IPAddress $env:PRINTER_TEST_IP -Port 9100

            $result | Should -Be $true
            Disconnect-Printer
        }
    }

    Context 'Error Handling' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Returns false for invalid IP' {
            $result = Connect-Printer -IPAddress '192.168.255.254' -TimeoutSec 2 -ErrorAction SilentlyContinue

            $result | Should -Be $false
        }

        It 'Handles disconnect when not connected' {
            Disconnect-Printer -ErrorAction SilentlyContinue

            # Should warn but not throw
            { Disconnect-Printer } | Should -Not -Throw
        }
    }
}
