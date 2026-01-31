#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

BeforeAll {
    # Import module
    $ModulePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\..\src\Printer\Printer.psd1'
    Import-Module $ModulePath -Force

    # Import test helpers
    $TestHelpersPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\TestHelpers.psm1'
    Import-Module $TestHelpersPath -Force
}

Describe 'Invoke-PrinterCommand' {
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
        It 'Throws error when not connected' {
            InModuleScope Printer {
                $script:PrinterSession = $null

                { Invoke-PrinterCommand -Data @(0x1B, 0x40) } |
                    Should -Throw -ExpectedMessage '*Not connected*'
            }
        }

        It 'Throws error when session exists but not connected' {
            InModuleScope Printer {
                $script:PrinterSession.Connected = $false

                { Invoke-PrinterCommand -Data @(0x1B, 0x40) } |
                    Should -Throw -ExpectedMessage '*Not connected*'
            }
        }
    }

    Context 'Parameter Validation' {
        It 'Data parameter is mandatory' {
            InModuleScope Printer {
                # Verify Data parameter has Mandatory attribute
                $cmd = Get-Command Invoke-PrinterCommand
                $param = $cmd.Parameters['Data']
                $param.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory } | Should -Not -BeNullOrEmpty
            }
        }

        It 'Validates MaxRetries range (minimum)' {
            InModuleScope Printer {
                { Invoke-PrinterCommand -Data @(0x1B, 0x40) -MaxRetries 0 } |
                    Should -Throw
            }
        }

        It 'Validates MaxRetries range (maximum)' {
            InModuleScope Printer {
                { Invoke-PrinterCommand -Data @(0x1B, 0x40) -MaxRetries 11 } |
                    Should -Throw
            }
        }

        It 'Accepts valid MaxRetries' {
            InModuleScope Printer {
                Mock New-Object {
                    $mockClient = [PSCustomObject]@{}
                    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
                        $task = [PSCustomObject]@{}
                        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value { return $true }
                        return $task
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name GetStream -Value {
                        $stream = [PSCustomObject]@{ WriteTimeout = 5000; ReadTimeout = 5000 }
                        $stream | Add-Member -MemberType ScriptMethod -Name Write -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Flush -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                        return $stream
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                    return $mockClient
                } -ParameterFilter { $TypeName -eq 'System.Net.Sockets.TcpClient' }

                { Invoke-PrinterCommand -Data @(0x1B, 0x40) -MaxRetries 5 } |
                    Should -Not -Throw
            }
        }
    }

    Context 'Successful Operations' {
        It 'Updates LastContact timestamp on success' {
            InModuleScope Printer {
                $beforeTime = $script:PrinterSession.LastContact

                Mock New-Object {
                    $mockClient = [PSCustomObject]@{}
                    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
                        Start-Sleep -Milliseconds 10
                        $task = [PSCustomObject]@{}
                        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value { return $true }
                        return $task
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name GetStream -Value {
                        $stream = [PSCustomObject]@{ WriteTimeout = 5000; ReadTimeout = 5000 }
                        $stream | Add-Member -MemberType ScriptMethod -Name Write -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Flush -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                        return $stream
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                    return $mockClient
                } -ParameterFilter { $TypeName -eq 'System.Net.Sockets.TcpClient' }

                Invoke-PrinterCommand -Data @(0x1B, 0x40)

                $script:PrinterSession.LastContact | Should -BeGreaterOrEqual $beforeTime
            }
        }

        It 'Returns true on successful send' {
            InModuleScope Printer {
                Mock New-Object {
                    $mockClient = [PSCustomObject]@{}
                    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
                        $task = [PSCustomObject]@{}
                        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value { return $true }
                        return $task
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name GetStream -Value {
                        $stream = [PSCustomObject]@{ WriteTimeout = 5000; ReadTimeout = 5000 }
                        $stream | Add-Member -MemberType ScriptMethod -Name Write -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Flush -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                        return $stream
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                    return $mockClient
                } -ParameterFilter { $TypeName -eq 'System.Net.Sockets.TcpClient' }

                $result = Invoke-PrinterCommand -Data @(0x1B, 0x40)

                $result | Should -Be $true
            }
        }
    }

    Context 'Retry Logic' {
        It 'Retries on connection timeout' {
            InModuleScope Printer {
                $script:callCount = 0

                Mock New-Object {
                    $script:callCount++
                    $mockClient = [PSCustomObject]@{}
                    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
                        $task = [PSCustomObject]@{}
                        $currentCall = $script:callCount
                        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value {
                            # Fail first attempt, succeed on retry
                            return ($currentCall -ge 2)
                        }.GetNewClosure()
                        return $task
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name GetStream -Value {
                        $stream = [PSCustomObject]@{ WriteTimeout = 5000; ReadTimeout = 5000 }
                        $stream | Add-Member -MemberType ScriptMethod -Name Write -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Flush -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                        $stream | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                        return $stream
                    }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
                    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }
                    return $mockClient
                } -ParameterFilter { $TypeName -eq 'System.Net.Sockets.TcpClient' }

                Mock Start-Sleep { }

                $result = Invoke-PrinterCommand -Data @(0x1B, 0x40) -MaxRetries 3

                $script:callCount | Should -BeGreaterThan 1
            }
        }

        It 'Throws after max retries exhausted' {
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

                Mock Start-Sleep { }

                { Invoke-PrinterCommand -Data @(0x1B, 0x40) -MaxRetries 2 } |
                    Should -Throw
            }
        }
    }
}
