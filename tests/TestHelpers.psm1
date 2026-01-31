#Requires -Version 5.1

<#
.SYNOPSIS
    Shared test helper functions for Printer module tests.

.DESCRIPTION
    Provides common mocking functions and utilities for both unit and integration tests.
#>

# Create mock printer session for tests
function New-MockPrinterSession {
    <#
    .SYNOPSIS
        Creates a mock printer session for unit tests.
    #>

    param(
        [string]$IPAddress = '192.168.0.100',
        [int]$Port = 9100,
        [int]$CharactersPerLine = 40
    )

    return @{
        IPAddress = $IPAddress
        Port = $Port
        Connected = $true
        LastContact = [DateTime]::Now
        PrinterInfo = @{
            Name = 'Mock TM-U220IIB'
            CharactersPerLine = $CharactersPerLine
        }
    }
}

# Clear mock session
function Clear-MockPrinterSession {
    <#
    .SYNOPSIS
        Clears the mock printer session.
    #>

    $script:PrinterSession = $null
}

# Mock TcpClient for unit tests
function Get-MockTcpClient {
    <#
    .SYNOPSIS
        Returns a mock TcpClient object for testing.
    #>

    param(
        [bool]$ConnectSuccess = $true,
        [bool]$WriteSuccess = $true
    )

    $mockStream = [PSCustomObject]@{
        WriteTimeout = 5000
        ReadTimeout = 5000
        CanWrite = $true
    }

    $mockStream | Add-Member -MemberType ScriptMethod -Name Write -Value {
        param($data, $offset, $count)
        if (-not $using:WriteSuccess) {
            throw "Mock write failure"
        }
    }

    $mockStream | Add-Member -MemberType ScriptMethod -Name Flush -Value { }
    $mockStream | Add-Member -MemberType ScriptMethod -Name Close -Value { }
    $mockStream | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }

    $mockClient = [PSCustomObject]@{
        Connected = $ConnectSuccess
    }

    $mockClient | Add-Member -MemberType ScriptMethod -Name ConnectAsync -Value {
        param($ip, $port)
        $task = [PSCustomObject]@{}
        $task | Add-Member -MemberType ScriptMethod -Name Wait -Value {
            param($timeout)
            return $using:ConnectSuccess
        }
        return $task
    }

    $mockClient | Add-Member -MemberType ScriptMethod -Name GetStream -Value {
        return $mockStream
    }

    $mockClient | Add-Member -MemberType ScriptMethod -Name Close -Value { }
    $mockClient | Add-Member -MemberType ScriptMethod -Name Dispose -Value { }

    return $mockClient
}

# Helper to verify ESC/POS command bytes
function Test-PrinterCommand {
    <#
    .SYNOPSIS
        Verifies that a byte array contains expected ESC/POS command sequences.
    #>

    param(
        [byte[]]$Data,
        [byte[]]$ExpectedSequence,
        [string]$Description
    )

    $found = $false
    for ($i = 0; $i -le ($Data.Length - $ExpectedSequence.Length); $i++) {
        $match = $true
        for ($j = 0; $j -lt $ExpectedSequence.Length; $j++) {
            if ($Data[$i + $j] -ne $ExpectedSequence[$j]) {
                $match = $false
                break
            }
        }
        if ($match) {
            $found = $true
            break
        }
    }

    return $found
}

# Common ESC/POS command sequences for testing
$script:PrinterCommands = @{
    Initialize = @(0x1B, 0x40)
    AlignLeft = @(0x1B, 0x61, 0x00)
    AlignCenter = @(0x1B, 0x61, 0x01)
    AlignRight = @(0x1B, 0x61, 0x02)
    BoldOn = @(0x1B, 0x45, 0x01)
    BoldOff = @(0x1B, 0x45, 0x00)
    CutFull = @(0x1D, 0x56, 0x00)
    CutPartial = @(0x1D, 0x56, 0x01)
    LineFeed = @(0x0A)
    ColorBlack = @(0x1B, 0x72, 0x00)
    ColorRed = @(0x1B, 0x72, 0x01)
    FontA = @(0x1B, 0x4D, 0x00)
    FontB = @(0x1B, 0x4D, 0x01)
    Beep = @(0x07)
}

function Get-PrinterCommandBytes {
    <#
    .SYNOPSIS
        Returns known ESC/POS command byte sequences for testing.
    #>

    param(
        [Parameter(Mandatory)]
        [ValidateSet('Initialize', 'AlignLeft', 'AlignCenter', 'AlignRight',
                     'BoldOn', 'BoldOff', 'CutFull', 'CutPartial', 'LineFeed',
                     'ColorBlack', 'ColorRed', 'FontA', 'FontB', 'Beep')]
        [string]$Command
    )

    return $script:PrinterCommands[$Command]
}

Export-ModuleMember -Function @(
    'New-MockPrinterSession'
    'Clear-MockPrinterSession'
    'Get-MockTcpClient'
    'Test-PrinterCommand'
    'Get-PrinterCommandBytes'
)
