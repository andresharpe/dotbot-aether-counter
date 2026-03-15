function Send-PrinterLine {
    <#
    .SYNOPSIS
        Prints a single line of text (simplified wrapper for Send-PrinterText).

    .DESCRIPTION
        Simplified version of Send-PrinterText for quick single-line printing.

    .PARAMETER Text
        The text to print.

    .EXAMPLE
        Send-PrinterLine "Hello, World!"

    .NOTES
        Requires an active connection via Connect-Printer.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Text
    )

    process {
        Send-PrinterText -Text $Text
    }
}
