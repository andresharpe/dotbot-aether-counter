function Initialize-AetherCounter {
    <#
    .SYNOPSIS
        Initialize the Counter conduit (ESC/POS Printer).
    .DESCRIPTION
        Accepts configuration, validates hardware reachability, and prepares
        the Counter conduit for event handling.
    .PARAMETER Config
        Hashtable of conduit configuration from dotbot settings.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Config
    )
    Write-Verbose "Initializing Aether Counter conduit..."
    $script:AetherConfig = $Config
    $result = Test-PrinterConnection -ErrorAction SilentlyContinue
    if ($result) {
        Write-Verbose "Aether Counter conduit initialized successfully."
    }
    $result
}
