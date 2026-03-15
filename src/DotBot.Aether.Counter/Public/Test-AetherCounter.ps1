function Test-AetherCounter {
    <#
    .SYNOPSIS
        Health check for the Counter conduit.
    .DESCRIPTION
        Returns $true if the ESC/POS Printer hardware is reachable.
    #>
    [CmdletBinding()]
    param()
    Write-Verbose "Testing Aether Counter conduit health..."
    Test-PrinterConnection @PSBoundParameters
}
