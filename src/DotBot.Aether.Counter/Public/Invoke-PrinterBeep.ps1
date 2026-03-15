function Invoke-PrinterBeep {
    <#
    .SYNOPSIS
        Activates the printer beep/buzzer if supported.

    .DESCRIPTION
        Sends a beep command to the printer. Not all printers support this feature.

    .PARAMETER Times
        Number of beeps (default: 1).

    .EXAMPLE
        Invoke-PrinterBeep

    .EXAMPLE
        Invoke-PrinterBeep -Times 3

    .NOTES
        Requires an active connection via Connect-Printer.
        Printer must have buzzer hardware support.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(1, 9)]
        [int]$Times = 1
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            # ESC (BEL) command (0x07) or ESC p for some printers
            # Using standard BEL character
            for ($i = 0; $i -lt $Times; $i++) {
                $data = @(0x07)
                Invoke-PrinterCommand -Data $data
                if ($i -lt $Times - 1) {
                    Start-Sleep -Milliseconds 200
                }
            }
            Write-Verbose "Beep command sent ($Times times)"
        }
        catch {
            Write-Error "Failed to send beep: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
