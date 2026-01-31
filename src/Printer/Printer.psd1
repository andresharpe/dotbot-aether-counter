@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Printer.psm1'

    # Version number of this module.
    ModuleVersion = '1.0.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = 'e8f7a6b5-c4d3-4e5f-a1b2-9c8d7e6f5a4b'

    # Author of this module
    Author = 'Printer PowerShell Module Contributors'

    # Company or vendor of this module
    CompanyName = 'Community'

    # Copyright statement for this module
    Copyright = '(c) 2026 Printer PowerShell Module Contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'PowerShell module for controlling text printers via TCP/IP. Provides network discovery, text printing, formatting, and receipt generation for Epson and compatible printers.'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        # Connection & Discovery (5)
        'Find-Printer'
        'Connect-Printer'
        'Disconnect-Printer'
        'Test-PrinterConnection'
        'Get-PrinterConfiguration'

        # Text Printing (6)
        'Send-PrinterText'
        'Send-PrinterLine'
        'Send-PrinterReceipt'
        'Clear-Printer'
        'Invoke-PrinterCut'
        'Invoke-PrinterBeep'

        # Formatting (4)
        'Set-PrinterAlignment'
        'Set-PrinterTextSize'
        'Set-PrinterEmphasis'
        'Send-PrinterRule'

        # TM-U220IIB Specific (5)
        'Set-PrinterColor'
        'Set-PrinterFont'
        'Invoke-PrinterFeed'
        'Invoke-PrinterBuzzer'
        'Initialize-Printer'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('ESC/POS', 'TextPrinter', 'Epson', 'Receipt', 'Printer', 'POS', 'TCP', 'Network', 'Hardware')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/yourusername/TextPrinter/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/yourusername/TextPrinter'

            # ReleaseNotes of this module
            ReleaseNotes = @'
v1.0.0 - Initial Release

Complete PowerShell module for text printer control:
- 19 public functions with ESC/POS protocol support
- Network device discovery (ARP cache + full subnet scan)
- Pipeline support throughout (Find-Printer | Connect-Printer)
- Comprehensive error handling with retry logic
- Cross-platform (PowerShell 5.1+ and 7+)
- Text formatting: alignment, bold, size adjustments
- Receipt generation with automatic formatting
- Optimized for Epson TM-U220IIB (40-character impact printer)
- Two-color printing support (black/red)
- Real-time buzzer control

Functions:
- Connection: Find-Printer, Connect-Printer, Disconnect-Printer, Test-PrinterConnection, Get-PrinterConfiguration
- Printing: Send-PrinterText, Send-PrinterLine, Send-PrinterReceipt, Clear-Printer, Invoke-PrinterCut, Invoke-PrinterBeep
- Formatting: Set-PrinterAlignment, Set-PrinterTextSize, Set-PrinterEmphasis, Send-PrinterRule
- TM-U220IIB: Set-PrinterColor, Set-PrinterFont, Invoke-PrinterFeed, Invoke-PrinterBuzzer

See README.md for full details and examples.
'@
        }
    }
}
