function Connect-AetherCounter {
    <#
    .SYNOPSIS
        Connect to discovered ESC/POS Printer hardware.
    .DESCRIPTION
        Delegates to the underlying hardware connection function.
    #>
    [CmdletBinding()]
    param()
    Write-Verbose "Connecting Aether Counter conduit..."
    Connect-Printer @PSBoundParameters
}
