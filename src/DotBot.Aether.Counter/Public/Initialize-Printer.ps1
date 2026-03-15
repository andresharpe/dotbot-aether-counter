function Initialize-Printer {
    <#
    .SYNOPSIS
        Initializes the printer to default settings.

    .DESCRIPTION
        Sends the ESC @ command to reset the printer to its default state.
        This clears the print buffer and resets all settings (font, alignment, etc.).

    .EXAMPLE
        Initialize-Printer

    .NOTES
        Requires an active connection via Connect-Printer.
        Command: ESC @ (0x1B 0x40)

        This is useful to ensure a clean state before printing.
        Send-PrinterReceipt automatically calls this.
    #>

    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            # ESC @ (Initialize printer)
            $data = @(0x1B, 0x40)
            Invoke-PrinterCommand -Data $data

            Write-Verbose "Printer initialized"
        }
        catch {
            Write-Error "Failed to initialize printer: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
