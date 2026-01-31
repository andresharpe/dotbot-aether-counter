function Write-PrinterError {
    <#
    .SYNOPSIS
        Writes standardized error messages for printer operations.

    .DESCRIPTION
        Helper function to output consistent error messages with context.
        Used by Invoke-PrinterCommand and other functions.

    .PARAMETER Message
        The error message to display.

    .PARAMETER ErrorCode
        Optional error code from the printer (if applicable).

    .PARAMETER Command
        Optional command name that failed.

    .EXAMPLE
        Write-PrinterError -Message "Connection failed" -Command "Print"

    .NOTES
        This is an internal helper function.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [int]$ErrorCode,

        [Parameter()]
        [string]$Command
    )

    $errorMessage = "Printer Error: $Message"

    if ($ErrorCode) {
        $errorMessage += " (Error Code: $ErrorCode)"
    }

    if ($Command) {
        $errorMessage += " [Command: $Command]"
    }

    Write-Error $errorMessage
}
