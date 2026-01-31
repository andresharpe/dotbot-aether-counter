# Example 2: Printing Text with Various Formatting

# Import the module
Import-Module "$PSScriptRoot\..\src\Printer\Printer.psd1" -Force

# Connect to printer (replace with your printer's IP)
$printerIP = "192.168.0.100"  # Change this to your printer's IP
Connect-Printer -IPAddress $printerIP

if (Test-PrinterConnection) {
    Write-Host "Printing text examples..." -ForegroundColor Cyan

    # Example 1: Basic text
    Send-PrinterText -Text "Basic Text Example" -Align Center
    Send-PrinterRule

    # Example 2: Bold text
    Send-PrinterText -Text "This is BOLD text" -Bold

    # Example 3: Aligned text
    Send-PrinterText -Text "Left Aligned" -Align Left
    Send-PrinterText -Text "Center Aligned" -Align Center
    Send-PrinterText -Text "Right Aligned" -Align Right

    Send-PrinterRule

    # Example 4: Different sizes
    Send-PrinterText -Text "Normal Size" -Align Center
    Send-PrinterText -Text "Wide" -Align Center -Width 2
    Send-PrinterText -Text "Tall" -Align Center -Height 2
    Send-PrinterText -Text "LARGE" -Align Center -Width 2 -Height 2 -Bold

    Send-PrinterRule

    # Example 5: Pipeline input
    Write-Host "`nPrinting multiple lines via pipeline..." -ForegroundColor Cyan
    @(
        "Line 1 from pipeline"
        "Line 2 from pipeline"
        "Line 3 from pipeline"
    ) | Send-PrinterText -Align Left

    Send-PrinterRule

    # Example 6: Using Send-PrinterLine for quick printing
    Send-PrinterLine "Quick line with Send-PrinterLine"
    Send-PrinterLine "Another quick line"

    # Add blank lines and cut
    Clear-Printer -Lines 3
    Invoke-PrinterCut

    Write-Host "Text examples printed!" -ForegroundColor Green

    Disconnect-Printer
}
else {
    Write-Host "Failed to connect to printer at $printerIP" -ForegroundColor Red
}
