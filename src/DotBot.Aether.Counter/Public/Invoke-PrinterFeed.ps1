function Invoke-PrinterFeed {
    <#
    .SYNOPSIS
        Prints buffered data and feeds paper.

    .DESCRIPTION
        Prints any buffered data and feeds the paper by the specified number of lines.
        Uses ESC d n command for forward feed or ESC e n for reverse feed.

    .PARAMETER Lines
        Number of lines to feed (1-255, default: 1).

    .PARAMETER Reverse
        Feed paper in reverse direction (if supported).

    .EXAMPLE
        Invoke-PrinterFeed -Lines 3

    .EXAMPLE
        Invoke-PrinterFeed -Lines 2 -Reverse

    .NOTES
        Requires an active connection via Connect-Printer.
        Forward feed: ESC d n (0x1B 0x64 n)
        Reverse feed: ESC e n (0x1B 0x65 n)
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(1, 255)]
        [int]$Lines = 1,

        [Parameter()]
        [switch]$Reverse
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            if ($Reverse) {
                # ESC e n (reverse feed)
                $data = @(0x1B, 0x65, $Lines)
                Write-Verbose "Reverse feeding $Lines lines"
            }
            else {
                # ESC d n (forward feed)
                $data = @(0x1B, 0x64, $Lines)
                Write-Verbose "Forward feeding $Lines lines"
            }

            Invoke-PrinterCommand -Data $data
        }
        catch {
            Write-Error "Failed to feed paper: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
