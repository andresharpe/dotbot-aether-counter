function Set-PrinterTextSize {
    <#
    .SYNOPSIS
        Sets the text size for subsequent prints.

    .DESCRIPTION
        Changes the width and height multipliers for all following text until changed again.

    .PARAMETER Width
        Width multiplier (1-2).

    .PARAMETER Height
        Height multiplier (1-2).

    .EXAMPLE
        Set-PrinterTextSize -Width 2 -Height 2

    .NOTES
        Requires an active connection via Connect-Printer.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateRange(1, 2)]
        [int]$Width = 1,

        [Parameter()]
        [ValidateRange(1, 2)]
        [int]$Height = 1
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            $sizeCode = (($Width - 1) -shl 4) -bor ($Height - 1)
            $data = @(0x1D, 0x21, $sizeCode)

            Invoke-PrinterCommand -Data $data

            Write-Verbose "Set text size to Width=$Width, Height=$Height"
        }
        catch {
            Write-Error "Failed to set text size: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
