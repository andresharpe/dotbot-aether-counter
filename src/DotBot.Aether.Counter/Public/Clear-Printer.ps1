function Clear-Printer {
    <#
    .SYNOPSIS
        Clears the visible area by feeding blank lines.

    .DESCRIPTION
        Sends multiple line feeds to clear the visible paper area.

    .PARAMETER Lines
        Number of blank lines to feed (default: 5).

    .EXAMPLE
        Clear-Printer

    .EXAMPLE
        Clear-Printer -Lines 10

    .NOTES
        Requires an active connection via Connect-Printer.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(1, 20)]
        [int]$Lines = 5
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            $data = @(0x0A) * $Lines
            Invoke-PrinterCommand -Data $data
            Write-Verbose "Fed $Lines blank lines"
        }
        catch {
            Write-Error "Failed to clear printer: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
