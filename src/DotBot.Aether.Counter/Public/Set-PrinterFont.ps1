function Set-PrinterFont {
    <#
    .SYNOPSIS
        Selects the character font.

    .DESCRIPTION
        Changes the character font for subsequent text.
        TM-U220IIB typically supports Font A (12x24) and Font B (9x17).

    .PARAMETER Font
        Font selection: A or B (default: A).

    .EXAMPLE
        Set-PrinterFont -Font A

    .EXAMPLE
        Set-PrinterFont -Font B

    .NOTES
        Requires an active connection via Connect-Printer.
        Command: ESC M n (0x1B 0x4D n) where n=0(Font A) or 1(Font B)
        Font A is typically 12x24 dots, Font B is 9x17 dots
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('A', 'B')]
        [string]$Font
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            $fontCode = if ($Font -eq 'A') { 0 } else { 1 }

            # ESC M n
            $data = @(0x1B, 0x4D, $fontCode)
            Invoke-PrinterCommand -Data $data

            Write-Verbose "Set font to $Font"
        }
        catch {
            Write-Error "Failed to set font: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
