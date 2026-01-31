#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\src\Printer\Printer.psd1'
    Import-Module $ModulePath -Force

    $script:TestDeviceIP = $env:PRINTER_TEST_IP

    if (-not $script:TestDeviceIP) {
        Write-Warning "Integration tests skipped: No device configured (set PRINTER_TEST_IP or use run-integration-tests.ps1)"
    }
}

Describe 'Printer Mutation Functions Integration Tests' -Tag 'Integration' {
    BeforeAll {
        if ($env:PRINTER_TEST_IP) {
            $null = Connect-Printer -IPAddress $env:PRINTER_TEST_IP
        }
    }

    AfterAll {
        if ($env:PRINTER_TEST_IP) {
            # Reset to reasonable state
            Set-PrinterColor -Color Black -ErrorAction SilentlyContinue
            Set-PrinterFont -Font A -ErrorAction SilentlyContinue
            Disconnect-Printer -ErrorAction SilentlyContinue
        }
    }

    Context 'Basic Text Printing' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Send-PrinterText prints text' {
            { Send-PrinterText -Text "Integration Test" } | Should -Not -Throw
        }

        It 'Send-PrinterText with center alignment' {
            { Send-PrinterText -Text "Centered" -Align Center } | Should -Not -Throw
        }

        It 'Send-PrinterText with bold' {
            { Send-PrinterText -Text "Bold Text" -Bold } | Should -Not -Throw
        }

        It 'Send-PrinterText with size options' {
            { Send-PrinterText -Text "Large" -Width 2 -Height 2 } | Should -Not -Throw
        }

        It 'Send-PrinterLine prints single line' {
            { Send-PrinterLine "Quick line test" } | Should -Not -Throw
        }

        It 'Send-PrinterText accepts pipeline input' {
            { "Pipeline Test" | Send-PrinterText } | Should -Not -Throw
        }
    }

    Context 'Formatting Functions' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Set-PrinterAlignment sets left' {
            { Set-PrinterAlignment -Align Left } | Should -Not -Throw
        }

        It 'Set-PrinterAlignment sets center' {
            { Set-PrinterAlignment -Align Center } | Should -Not -Throw
        }

        It 'Set-PrinterAlignment sets right' {
            { Set-PrinterAlignment -Align Right } | Should -Not -Throw
            Set-PrinterAlignment -Align Left  # Reset
        }

        It 'Set-PrinterEmphasis enables bold' {
            { Set-PrinterEmphasis -Enable $true } | Should -Not -Throw
        }

        It 'Set-PrinterEmphasis disables bold' {
            { Set-PrinterEmphasis -Enable $false } | Should -Not -Throw
        }

        It 'Set-PrinterTextSize sets normal size' {
            { Set-PrinterTextSize -Width 1 -Height 1 } | Should -Not -Throw
        }

        It 'Set-PrinterTextSize sets double size' {
            { Set-PrinterTextSize -Width 2 -Height 2 } | Should -Not -Throw
            Set-PrinterTextSize -Width 1 -Height 1  # Reset
        }

        It 'Send-PrinterRule prints horizontal rule' {
            { Send-PrinterRule } | Should -Not -Throw
        }

        It 'Send-PrinterRule with custom character' {
            { Send-PrinterRule -Character "=" } | Should -Not -Throw
        }
    }

    Context 'TM-U220IIB Specific Functions' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Set-PrinterColor sets black' {
            { Set-PrinterColor -Color Black } | Should -Not -Throw
        }

        It 'Set-PrinterColor sets red' {
            { Set-PrinterColor -Color Red } | Should -Not -Throw
            # Print something in red
            Send-PrinterText -Text "RED TEXT" -Bold
            Set-PrinterColor -Color Black  # Reset
        }

        It 'Set-PrinterFont sets Font A' {
            { Set-PrinterFont -Font A } | Should -Not -Throw
        }

        It 'Set-PrinterFont sets Font B' {
            { Set-PrinterFont -Font B } | Should -Not -Throw
            Send-PrinterText -Text "Font B (smaller)"
            Set-PrinterFont -Font A  # Reset
        }

        It 'Invoke-PrinterFeed feeds paper forward' {
            { Invoke-PrinterFeed -Lines 2 } | Should -Not -Throw
        }

        It 'Initialize-Printer initializes printer' {
            { Initialize-Printer } | Should -Not -Throw
        }
    }

    Context 'Buzzer and Beep' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Invoke-PrinterBeep beeps' {
            { Invoke-PrinterBeep -Times 1 } | Should -Not -Throw
        }

        It 'Invoke-PrinterBuzzer buzzes with short duration' {
            { Invoke-PrinterBuzzer -Times 1 -Duration Short } | Should -Not -Throw
        }

        It 'Invoke-PrinterBuzzer buzzes with long duration' {
            { Invoke-PrinterBuzzer -Times 1 -Duration Long } | Should -Not -Throw
        }

        It 'Invoke-PrinterBuzzer buzzes multiple times' {
            { Invoke-PrinterBuzzer -Times 2 -Duration Short } | Should -Not -Throw
        }
    }

    Context 'Paper Control' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Clear-Printer feeds blank lines' {
            { Clear-Printer -Lines 3 } | Should -Not -Throw
        }

        It 'Invoke-PrinterCut cuts paper (partial)' {
            # Print something first
            Send-PrinterText -Text "Before partial cut"
            Clear-Printer -Lines 2
            { Invoke-PrinterCut -CutType Partial } | Should -Not -Throw
        }

        It 'Invoke-PrinterCut cuts paper (full)' {
            Send-PrinterText -Text "Before full cut"
            Clear-Printer -Lines 2
            { Invoke-PrinterCut -CutType Full } | Should -Not -Throw
        }
    }

    Context 'Receipt Printing' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Send-PrinterReceipt prints formatted receipt' {
            {
                Send-PrinterReceipt `
                    -Header "TEST RECEIPT" `
                    -Body @(
                        "Line 1",
                        "Line 2",
                        "Line 3"
                    ) `
                    -Footer "Thank you!"
            } | Should -Not -Throw
        }

        It 'Send-PrinterReceipt with Cut disabled' {
            {
                Send-PrinterReceipt `
                    -Header "NO CUT" `
                    -Body "Body text" `
                    -Cut $false
            } | Should -Not -Throw

            # Manual cut
            Invoke-PrinterCut
        }
    }

    Context 'Combined Operations' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Prints colorful receipt with buzzer' {
            # This is a comprehensive test of TM-U220IIB features
            Initialize-Printer

            Set-PrinterColor -Color Red
            Send-PrinterText -Text "=== INTEGRATION TEST ===" -Align Center -Bold -Width 2 -Height 2

            Set-PrinterColor -Color Black
            Send-PrinterRule -Character "="

            Send-PrinterText -Text "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            Send-PrinterText -Text "Test: Combined Operations"
            Send-PrinterText -Text ""

            Set-PrinterFont -Font B
            Send-PrinterText -Text "This is Font B (smaller)"
            Set-PrinterFont -Font A
            Send-PrinterText -Text "This is Font A (normal)"

            Send-PrinterRule

            Set-PrinterColor -Color Red
            Send-PrinterText -Text "SUCCESS!" -Align Center -Bold
            Set-PrinterColor -Color Black

            Clear-Printer -Lines 3
            Invoke-PrinterCut

            # Celebrate!
            Invoke-PrinterBuzzer -Times 2 -Duration Short

            # If we got here without errors, the test passed
            $true | Should -Be $true
        }
    }

    Context 'Error Handling' -Skip:(-not $env:PRINTER_TEST_IP) {
        It 'Functions throw when not connected' {
            Disconnect-Printer
            { Send-PrinterText -Text "Test" } | Should -Throw
            # Reconnect for any remaining tests
            $null = Connect-Printer -IPAddress $env:PRINTER_TEST_IP
        }
    }
}
