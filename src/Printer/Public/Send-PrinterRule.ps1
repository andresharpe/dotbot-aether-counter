function Send-PrinterRule {
    <#
    .SYNOPSIS
        Prints a horizontal rule (line of characters).

    .DESCRIPTION
        Prints a line of repeated characters to create a visual separator.

    .PARAMETER Character
        Character to repeat (default: '-').

    .PARAMETER Width
        Number of characters (default: uses printer's characters per line setting).

    .EXAMPLE
        Send-PrinterRule

    .EXAMPLE
        Send-PrinterRule -Character "=" -Width 40

    .NOTES
        Requires an active connection via Connect-Printer.
    #>

    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateLength(1, 1)]
        [string]$Character = '-',

        [Parameter()]
        [ValidateRange(1, 80)]
        [int]$Width = 0
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            if ($Width -eq 0) {
                $Width = $script:PrinterSession.PrinterInfo.CharactersPerLine
            }

            $line = $Character * $Width
            Send-PrinterText -Text $line

            Write-Verbose "Printed rule: $Width characters"
        }
        catch {
            Write-Error "Failed to print rule: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
