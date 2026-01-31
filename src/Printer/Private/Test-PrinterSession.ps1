function Test-PrinterSession {
    <#
    .SYNOPSIS
        Validates that a printer session exists.

    .DESCRIPTION
        Checks if the module-scoped $script:PrinterSession variable is initialized.
        Used internally by all functions that require an active connection.

    .PARAMETER Throw
        If specified, throws a terminating error when session is not found.
        Otherwise, returns $false.

    .EXAMPLE
        Test-PrinterSession -Throw

    .EXAMPLE
        if (Test-PrinterSession) { ... }

    .NOTES
        This is an internal helper function used for session validation.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Throw
    )

    $sessionExists = $null -ne $script:PrinterSession -and $script:PrinterSession.Connected -eq $true

    if (-not $sessionExists -and $Throw) {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new('Not connected to a text printer. Use Connect-Printer first.'),
            'PrinterSessionNotFound',
            [System.Management.Automation.ErrorCategory]::ConnectionError,
            $null
        )
        throw $errorRecord
    }

    # Only return value when not using -Throw (for conditional checks)
    if (-not $Throw) {
        return $sessionExists
    }
}
