function Disconnect-AetherCounter {
    <#
    .SYNOPSIS
        Disconnect from ESC/POS Printer hardware.
    .DESCRIPTION
        Clean shutdown of the Counter conduit.
    #>
    [CmdletBinding()]
    param()
    Write-Verbose "Disconnecting Aether Counter conduit..."
    Disconnect-Printer @PSBoundParameters
}
