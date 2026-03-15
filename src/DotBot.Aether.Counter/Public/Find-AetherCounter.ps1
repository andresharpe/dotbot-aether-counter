function Find-AetherCounter {
    <#
    .SYNOPSIS
        Discover ESC/POS Printer hardware on network/bus.
    .DESCRIPTION
        Delegates to the underlying hardware discovery function.
    #>
    [CmdletBinding()]
    param()
    Write-Verbose "Discovering Aether Counter hardware..."
    Find-Printer @PSBoundParameters
}
