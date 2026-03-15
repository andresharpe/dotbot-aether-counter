function Send-PrinterText {
    <#
    .SYNOPSIS
        Prints text to the printer with formatting options.

    .DESCRIPTION
        Sends formatted text to the printer with optional alignment, bold, and size settings.
        Automatically wraps text based on printer's characters per line setting.

    .PARAMETER Text
        The text to print. Supports pipeline input for multiple lines.

    .PARAMETER Align
        Text alignment: Left, Center, or Right (default: Left).

    .PARAMETER Bold
        Print text in bold.

    .PARAMETER Width
        Text width multiplier (1-2, default: 1).

    .PARAMETER Height
        Text height multiplier (1-2, default: 1).

    .PARAMETER NewLine
        Add line feed after text (default: $true).

    .EXAMPLE
        Send-PrinterText -Text "Hello, World!"

    .EXAMPLE
        Send-PrinterText -Text "RECEIPT" -Align Center -Bold -Width 2 -Height 2

    .EXAMPLE
        "Line 1", "Line 2", "Line 3" | Send-PrinterText

    .NOTES
        Requires an active connection via Connect-Printer.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Text,

        [Parameter()]
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Align = 'Left',

        [Parameter()]
        [switch]$Bold,

        [Parameter()]
        [ValidateRange(1, 2)]
        [int]$Width = 1,

        [Parameter()]
        [ValidateRange(1, 2)]
        [int]$Height = 1,

        [Parameter()]
        [bool]$NewLine = $true
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        Test-PrinterSession -Throw
    }

    process {
        try {
            $commands = [System.Collections.ArrayList]::new()

            # Set alignment
            $alignCode = switch ($Align) {
                'Left' { 0 }
                'Center' { 1 }
                'Right' { 2 }
            }
            [void]$commands.AddRange(@(0x1B, 0x61, $alignCode))

            # Set text size (combine width and height)
            $sizeCode = (($Width - 1) -shl 4) -bor ($Height - 1)
            [void]$commands.AddRange(@(0x1D, 0x21, $sizeCode))

            # Set bold
            if ($Bold) {
                [void]$commands.AddRange(@(0x1B, 0x45, 0x01))
            }
            else {
                [void]$commands.AddRange(@(0x1B, 0x45, 0x00))
            }

            # Add text (UTF-8 encoding)
            $textBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
            [void]$commands.AddRange($textBytes)

            # Add line feed if requested
            if ($NewLine) {
                [void]$commands.Add(0x0A)
            }

            # Send to printer
            $data = $commands.ToArray()
            Invoke-PrinterCommand -Data $data

            Write-Verbose "Sent text: $Text"
        }
        catch {
            Write-Error "Failed to send text: $($_.Exception.Message)"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
