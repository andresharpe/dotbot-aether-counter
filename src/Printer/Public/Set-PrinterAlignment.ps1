function Set-PrinterAlignment {
    <#
    .SYNOPSIS
        Sets the text alignment for subsequent prints.

    .DESCRIPTION
        Changes the alignment mode for all following text until changed again.

    .PARAMETER Align
        Alignment: Left, Center, or Right.

    .EXAMPLE
        Set-PrinterAlignment -Align Center

    .NOTES
        Requires an active connection via Connect-Printer.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            $alignCode = switch ($Align) {
                'Left' { 0 }
                'Center' { 1 }
                'Right' { 2 }
            }

            $data = @(0x1B, 0x61, $alignCode)
            Invoke-PrinterCommand -Data $data

            Write-Verbose "Set alignment to $Align"
        }
        catch {
            Write-Error "Failed to set alignment: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
