function Invoke-PrinterBuzzer {
    <#
    .SYNOPSIS
        Sounds the buzzer on TM-U220IIB in real-time.

    .DESCRIPTION
        Activates the printer's buzzer using the real-time command.
        This is specific to impact printers like the TM-U220IIB.

    .PARAMETER Times
        Number of buzzer beeps (1-9, default: 1).

    .PARAMETER Duration
        Duration pattern:
        - Short: 1 beep (0.05s)
        - Long: 2 beeps (0.1s)
        - VeryLong: 3 beeps (0.2s)

    .EXAMPLE
        Invoke-PrinterBuzzer

    .EXAMPLE
        Invoke-PrinterBuzzer -Times 3 -Duration Long

    .NOTES
        Requires an active connection via Connect-Printer.
        Uses DLE DC4 fn=3 (0x10 0x14 0x03 n t)
        This is a real-time command specific to TM-U220IIB
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(1, 9)]
        [int]$Times = 1,

        [Parameter()]
        [ValidateSet('Short', 'Long', 'VeryLong')]
        [string]$Duration = 'Short'
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            $durationCode = switch ($Duration) {
                'Short' { 1 }
                'Long' { 2 }
                'VeryLong' { 3 }
            }

            # DLE DC4 (fn=3) - Sound buzzer in real-time
            # Format: DLE DC4 fn n t
            # DLE=0x10, DC4=0x14, fn=3, n=times, t=duration
            $data = @(0x10, 0x14, 0x03, $Times, $durationCode)

            Invoke-PrinterCommand -Data $data

            Write-Verbose "Buzzer activated: $Times times with $Duration duration"
        }
        catch {
            Write-Error "Failed to activate buzzer: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
