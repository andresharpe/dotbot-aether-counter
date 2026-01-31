#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\src\Printer\Printer.psd1'
    Import-Module $ModulePath -Force

    # Import test helpers
    $TestHelpersPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\TestHelpers.psm1'
    Import-Module $TestHelpersPath -Force
}

Describe 'Send-PrinterText' {
    BeforeEach {
        # Setup mock session
        InModuleScope Printer {
            $script:PrinterSession = @{
                IPAddress = '192.168.0.100'
                Port = 9100
                Connected = $true
                LastContact = [DateTime]::Now
                PrinterInfo = @{
                    Name = 'Mock TM-U220IIB'
                    CharactersPerLine = 40
                }
            }
        }
    }

    AfterEach {
        InModuleScope Printer {
            $script:PrinterSession = $null
        }
    }

    Context 'Session Validation' {
        It 'Throws when not connected' {
            InModuleScope Printer {
                $script:PrinterSession = $null

                { Send-PrinterText -Text "Test" } |
                    Should -Throw -ExpectedMessage '*Not connected*'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Text parameter is mandatory' {
            # Verify Text parameter has Mandatory attribute
            $cmd = Get-Command Send-PrinterText
            $param = $cmd.Parameters['Text']
            $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory } | Should -Not -BeNullOrEmpty
        }

        It 'Validates Align parameter' {
            InModuleScope Printer {
                Mock Invoke-PrinterCommand { return $true }

                { Send-PrinterText -Text "Test" -Align Invalid } | Should -Throw
            }
        }

        It 'Validates Width range' {
            InModuleScope Printer {
                { Send-PrinterText -Text "Test" -Width 0 } | Should -Throw
                { Send-PrinterText -Text "Test" -Width 3 } | Should -Throw
            }
        }

        It 'Validates Height range' {
            InModuleScope Printer {
                { Send-PrinterText -Text "Test" -Height 0 } | Should -Throw
                { Send-PrinterText -Text "Test" -Height 3 } | Should -Throw
            }
        }
    }

    Context 'Command Generation' {
        It 'Sends correct alignment command for Center' {
            InModuleScope Printer {
                $capturedData = $null

                Mock Invoke-PrinterCommand {
                    $script:capturedData = $Data
                    return $true
                }

                Send-PrinterText -Text "Test" -Align Center

                # Check for ESC a 1 (center alignment)
                $script:capturedData | Should -Contain 0x1B
                $script:capturedData | Should -Contain 0x61
                $script:capturedData | Should -Contain 0x01
            }
        }

        It 'Sends bold command when -Bold is specified' {
            InModuleScope Printer {
                $capturedData = $null

                Mock Invoke-PrinterCommand {
                    $script:capturedData = $Data
                    return $true
                }

                Send-PrinterText -Text "Test" -Bold

                # Check for ESC E 1 (bold on)
                $script:capturedData | Should -Contain 0x1B
                $script:capturedData | Should -Contain 0x45
                $script:capturedData | Should -Contain 0x01
            }
        }

        It 'Includes text bytes in output' {
            InModuleScope Printer {
                $capturedData = $null

                Mock Invoke-PrinterCommand {
                    $script:capturedData = $Data
                    return $true
                }

                Send-PrinterText -Text "Hi"

                # 'H' = 0x48, 'i' = 0x69
                $script:capturedData | Should -Contain 0x48
                $script:capturedData | Should -Contain 0x69
            }
        }

        It 'Includes line feed by default' {
            InModuleScope Printer {
                $capturedData = $null

                Mock Invoke-PrinterCommand {
                    $script:capturedData = $Data
                    return $true
                }

                Send-PrinterText -Text "Test"

                # Last byte should be LF (0x0A)
                $script:capturedData[-1] | Should -Be 0x0A
            }
        }

        It 'Omits line feed when NewLine is false' {
            InModuleScope Printer {
                $capturedData = $null

                Mock Invoke-PrinterCommand {
                    $script:capturedData = $Data
                    return $true
                }

                Send-PrinterText -Text "Test" -NewLine $false

                # Last byte should NOT be LF
                $script:capturedData[-1] | Should -Not -Be 0x0A
            }
        }
    }

    Context 'Pipeline Support' {
        It 'Accepts pipeline input' {
            InModuleScope Printer {
                Mock Invoke-PrinterCommand { return $true }

                { "Test" | Send-PrinterText } | Should -Not -Throw
            }
        }

        It 'Processes multiple pipeline items' {
            InModuleScope Printer {
                $callCount = 0

                Mock Invoke-PrinterCommand {
                    $script:callCount++
                    return $true
                }

                @("Line1", "Line2", "Line3") | Send-PrinterText

                $script:callCount | Should -Be 3
            }
        }
    }
}
