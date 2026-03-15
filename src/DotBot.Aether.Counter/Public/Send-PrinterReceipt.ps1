function Send-PrinterReceipt {
    <#
    .SYNOPSIS
        Prints a formatted receipt with header, body, and footer.

    .DESCRIPTION
        Convenience function for printing structured receipts with automatic formatting and paper cutting.

    .PARAMETER Header
        Header lines (centered, bold, double height).

    .PARAMETER Body
        Body lines (left-aligned, normal text).

    .PARAMETER Footer
        Footer lines (centered, normal text).

    .PARAMETER Cut
        Automatically cut paper after printing (default: $true).

    .EXAMPLE
        Send-PrinterReceipt -Header "MY RECEIPT" -Body "Item 1","Item 2" -Footer "Thank you!"

    .EXAMPLE
        Send-PrinterReceipt -Header "CODE COMPLETE" -Body "Function: DoSomething()","Status: Success" -Cut

    .NOTES
        Requires an active connection via Connect-Printer.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$Header,

        [Parameter(Mandatory)]
        [string[]]$Body,

        [Parameter()]
        [string[]]$Footer,

        [Parameter()]
        [bool]$Cut = $true
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            # Initialize printer
            $initData = @(0x1B, 0x40)  # ESC @
            Invoke-PrinterCommand -Data $initData

            # Print header
            if ($Header) {
                foreach ($line in $Header) {
                    Send-PrinterText -Text $line -Align Center -Bold -Width 2 -Height 2
                }
                Send-PrinterRule
            }

            # Print body
            foreach ($line in $Body) {
                Send-PrinterText -Text $line -Align Left
            }

            # Print footer
            if ($Footer) {
                Send-PrinterRule
                foreach ($line in $Footer) {
                    Send-PrinterText -Text $line -Align Center
                }
            }

            # Add some blank lines
            Clear-Printer -Lines 3

            # Cut paper if requested
            if ($Cut) {
                Invoke-PrinterCut
            }

            Write-Verbose "Receipt printed successfully"
        }
        catch {
            Write-Error "Failed to print receipt: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
