#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\src\Printer\Printer.psd1'
    Import-Module $ModulePath -Force

    # Import test helpers
    $TestHelpersPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\TestHelpers.psm1'
    Import-Module $TestHelpersPath -Force
}

Describe 'Connect-Printer' {
    AfterEach {
        InModuleScope Printer {
            $script:PrinterSession = $null
        }
    }

    Context 'Parameter Validation' {
        It 'IPAddress parameter is mandatory' {
            # Verify IPAddress parameter has Mandatory attribute
            $cmd = Get-Command Connect-Printer
            $param = $cmd.Parameters['IPAddress']
            $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory } | Should -Not -BeNullOrEmpty
        }

        It 'Validates Port range' {
            { Connect-Printer -IPAddress '192.168.0.100' -Port 0 } | Should -Throw
            { Connect-Printer -IPAddress '192.168.0.100' -Port 70000 } | Should -Throw
        }

        It 'Validates CharactersPerLine range' {
            { Connect-Printer -IPAddress '192.168.0.100' -CharactersPerLine 10 } | Should -Throw
            { Connect-Printer -IPAddress '192.168.0.100' -CharactersPerLine 100 } | Should -Throw
        }

        It 'Validates TimeoutSec range' {
            { Connect-Printer -IPAddress '192.168.0.100' -TimeoutSec 0 } | Should -Throw
            { Connect-Printer -IPAddress '192.168.0.100' -TimeoutSec 60 } | Should -Throw
        }

        It 'Accepts IP alias from pipeline' {
            InModuleScope Printer {
                Mock New-Object {
                    $mockClient = [PSCustomObject]@{}
                    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
                        $task = [PSCustomObject]@{}
                        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value { return $true }
                        return $task
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                    return $mockClient
                } -ParameterFilter { $TypeName -eq 'System.Net.Sockets.TcpClient' }

                $printerObj = [PSCustomObject]@{ IP = '192.168.0.100'; Port = 9100 }
                $result = $printerObj | Connect-Printer

                $result | Should -Be $true
            }
        }
    }

    Context 'Successful Connection' {
        It 'Returns true on successful connection' {
            InModuleScope Printer {
                Mock New-Object {
                    $mockClient = [PSCustomObject]@{}
                    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
                        $task = [PSCustomObject]@{}
                        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value { return $true }
                        return $task
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                    return $mockClient
                } -ParameterFilter { $TypeName -eq 'System.Net.Sockets.TcpClient' }

                $result = Connect-Printer -IPAddress '192.168.0.100'

                $result | Should -Be $true
            }
        }

        It 'Creates session with correct properties' {
            InModuleScope Printer {
                Mock New-Object {
                    $mockClient = [PSCustomObject]@{}
                    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
                        $task = [PSCustomObject]@{}
                        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value { return $true }
                        return $task
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                    return $mockClient
                } -ParameterFilter { $TypeName -eq 'System.Net.Sockets.TcpClient' }

                Connect-Printer -IPAddress '192.168.0.100' -Port 9100 -CharactersPerLine 42

                $script:PrinterSession | Should -Not -BeNullOrEmpty
                $script:PrinterSession.IPAddress | Should -Be '192.168.0.100'
                $script:PrinterSession.Port | Should -Be 9100
                $script:PrinterSession.Connected | Should -Be $true
                $script:PrinterSession.PrinterInfo.CharactersPerLine | Should -Be 42
            }
        }
    }

    Context 'Connection Failure' {
        It 'Returns false on connection timeout' {
            InModuleScope Printer {
                Mock New-Object {
                    $mockClient = [PSCustomObject]@{}
                    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
                        $task = [PSCustomObject]@{}
                        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value { return $false }
                        return $task
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                    return $mockClient
                } -ParameterFilter { $TypeName -eq 'System.Net.Sockets.TcpClient' }

                $result = Connect-Printer -IPAddress '192.168.0.100' -ErrorAction SilentlyContinue

                $result | Should -Be $false
            }
        }

        It 'Does not create session on failure' {
            InModuleScope Printer {
                Mock New-Object {
                    $mockClient = [PSCustomObject]@{}
                    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
                        $task = [PSCustomObject]@{}
                        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value { return $false }
                        return $task
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                    return $mockClient
                } -ParameterFilter { $TypeName -eq 'System.Net.Sockets.TcpClient' }

                Connect-Printer -IPAddress '192.168.0.100' -ErrorAction SilentlyContinue

                $script:PrinterSession | Should -BeNullOrEmpty
            }
        }
    }

    Context 'ShouldProcess' {
        It 'Supports -WhatIf' {
            InModuleScope Printer {
                Connect-Printer -IPAddress '192.168.0.100' -WhatIf

                $script:PrinterSession | Should -BeNullOrEmpty
            }
        }
    }
}
