function Invoke-PrinterCut {
    <#
    .SYNOPSIS
        Cuts the printer paper.

    .DESCRIPTION
        Sends the paper cut command to the printer. Supports partial and full cuts
        depending on printer capabilities.

    .PARAMETER CutType
        Type of cut: Full or Partial (default: Full).

    .EXAMPLE
        Invoke-PrinterCut

    .EXAMPLE
        Invoke-PrinterCut -CutType Partial

    .NOTES
        Requires an active connection via Connect-Printer.
        Not all printers support both cut types.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Full', 'Partial')]
        [string]$CutType = 'Full'
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            $cutCode = if ($CutType -eq 'Full') { 0 } else { 1 }

            # GS V m (cut paper)
            $data = @(0x1D, 0x56, $cutCode)

            Invoke-PrinterCommand -Data $data

            Write-Verbose "Paper cut command sent ($CutType)"
        }
        catch {
            Write-Error "Failed to cut paper: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
