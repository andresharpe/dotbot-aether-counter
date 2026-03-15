#Requires -Version 5.1

<#
.SYNOPSIS
    Printer PowerShell Module - Main module file

.DESCRIPTION
    PowerShell module for controlling text printers via TCP/IP network connection.
    Provides complete support for text printing, formatting, and receipt generation with
    automatic discovery and connection management.

.NOTES
    Author: Printer PowerShell Module Contributors
    Version: 1.0.0
    License: MIT
#>

# Initialize module-scoped session variable
$script:PrinterSession = $null

# Get module paths
$PrivatePath = Join-Path -Path $PSScriptRoot -ChildPath 'Private'
$PublicPath = Join-Path -Path $PSScriptRoot -ChildPath 'Public'

# Dot-source all private functions
if (Test-Path -Path $PrivatePath) {
    $PrivateFunctions = Get-ChildItem -Path $PrivatePath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
    foreach ($Function in $PrivateFunctions) {
        try {
            . $Function.FullName
            Write-Verbose "Imported private function: $($Function.BaseName)"
        }
        catch {
            Write-Error "Failed to import private function $($Function.FullName): $_"
        }
    }
}

# Dot-source all public functions
if (Test-Path -Path $PublicPath) {
    $PublicFunctions = Get-ChildItem -Path $PublicPath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
    foreach ($Function in $PublicFunctions) {
        try {
            . $Function.FullName
            Write-Verbose "Imported public function: $($Function.BaseName)"
        }
        catch {
            Write-Error "Failed to import public function $($Function.FullName): $_"
        }
    }
}

# Module cleanup on removal
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    if ($script:PrinterSession) {
        Write-Verbose "Clearing printer session on module removal"
        $script:PrinterSession = $null
    }
}

# Export public functions (defined in manifest)
Export-ModuleMember -Function @(
    # Aether Interface Contract
    'Initialize-AetherCounter'
    'Find-AetherCounter'
    'Connect-AetherCounter'
    'Disconnect-AetherCounter'
    'Test-AetherCounter'
    'Invoke-AetherCounterEvent'
    # Connection & Discovery
    'Find-Printer'
    'Connect-Printer'
    'Disconnect-Printer'
    'Test-PrinterConnection'
    'Get-PrinterConfiguration'

    # Text Printing
    'Send-PrinterText'
    'Send-PrinterLine'
    'Send-PrinterReceipt'
    'Clear-Printer'
    'Invoke-PrinterCut'
    'Invoke-PrinterBeep'

    # Formatting
    'Set-PrinterAlignment'
    'Set-PrinterTextSize'
    'Set-PrinterEmphasis'
    'Send-PrinterRule'

    # TM-U220IIB Specific
    'Set-PrinterColor'
    'Set-PrinterFont'
    'Invoke-PrinterFeed'
    'Invoke-PrinterBuzzer'
    'Initialize-Printer'
)
