function Set-PrinterColor {
    <#
    .SYNOPSIS
        Sets the print color for Epson TM-U220IIB (red/black).

    .DESCRIPTION
        Changes the print color for printers with two-color ribbons.
        The TM-U220IIB supports black (default) and red printing.

    .PARAMETER Color
        Print color: Black or Red (default: Black).

    .EXAMPLE
        Set-PrinterColor -Color Red

    .EXAMPLE
        Set-PrinterColor -Color Black

    .NOTES
        Requires an active connection via Connect-Printer.
        Only works on printers with two-color ribbon (like TM-U220IIB).
        Command: ESC r n (0x1B 0x72 n) where n=0(black) or 1(red)
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Black', 'Red')]
        [string]$Color
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            $colorCode = if ($Color -eq 'Black') { 0 } else { 1 }

            # ESC r n
            $data = @(0x1B, 0x72, $colorCode)
            Invoke-PrinterCommand -Data $data

            Write-Verbose "Set print color to $Color"
        }
        catch {
            Write-Error "Failed to set color: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
