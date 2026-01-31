function Set-PrinterEmphasis {
    <#
    .SYNOPSIS
        Enables or disables bold emphasis for subsequent text.

    .DESCRIPTION
        Toggles bold mode for all following text until changed again.

    .PARAMETER Enable
        Enable (true) or disable (false) bold.

    .EXAMPLE
        Set-PrinterEmphasis -Enable $true

    .EXAMPLE
        Set-PrinterEmphasis -Enable $false

    .NOTES
        Requires an active connection via Connect-Printer.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [bool]$Enable
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            $boldCode = if ($Enable) { 1 } else { 0 }
            $data = @(0x1B, 0x45, $boldCode)

            Invoke-PrinterCommand -Data $data

            Write-Verbose "Set bold to $Enable"
        }
        catch {
            Write-Error "Failed to set emphasis: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
