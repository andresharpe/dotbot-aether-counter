# Example 4: Dotbot Integration - Coding Session Receipts
# Optimized for Epson TM-U220IIB with RED color and LOUD buzzer!

# Import the module
Import-Module "$PSScriptRoot\..\src\Printer\Printer.psd1" -Force

# Helper function for Dotbot to print coding events (LOUDLY!)
function Print-CodingEvent {
    <#
    .SYNOPSIS
        Prints a coding event receipt for Dotbot sessions.
        Uses TM-U220IIB features: red text for success, loud buzzer!

    .EXAMPLE
        Print-CodingEvent -Event "Function Created" -Details "New-AwesomeFunction()" -Success -Loud
    #>
    param(
        [string]$Event,
        [string[]]$Details,
        [switch]$Success,
        [switch]$Warning,
        [switch]$Loud
    )

    $timestamp = Get-Date -Format "HH:mm:ss"

    # Initialize printer for clean state
    Initialize-Printer

    # Print header in RED if success, BLACK otherwise
    if ($Success) {
        Set-PrinterColor -Color Red
    }

    Send-PrinterText -Text "DOTBOT EVENT" -Align Center -Bold -Width 2 -Height 2
    Send-PrinterText -Text $timestamp -Align Center
    Send-PrinterRule -Character "="

    # Status line
    $status = if ($Success) { "[SUCCESS]" } elseif ($Warning) { "[WARNING]" } else { "[INFO]" }
    Send-PrinterText -Text "$status $Event" -Bold

    # Reset to black for body
    Set-PrinterColor -Color Black
    Send-PrinterRule

    # Print details
    foreach ($line in $Details) {
        Send-PrinterText -Text $line
    }

    # Footer
    Send-PrinterRule
    if ($Success) {
        Set-PrinterColor -Color Red
    }
    Send-PrinterText -Text "Keep coding! :)" -Align Center
    Set-PrinterColor -Color Black

    # Feed and cut
    Invoke-PrinterFeed -Lines 3
    Invoke-PrinterCut

    # LOUD buzzer if requested (TM-U220IIB real-time buzzer!)
    if ($Loud) {
        Invoke-PrinterBuzzer -Times 3 -Duration Long
    }
    elseif ($Success) {
        Invoke-PrinterBuzzer -Times 2 -Duration Short
    }
}

# Connect to printer (replace with your printer's IP)
$printerIP = "192.168.0.100"  # Change this to your printer's IP
Connect-Printer -IPAddress $printerIP

if (Test-PrinterConnection) {
    Write-Host "Printing Dotbot coding events (with TM-U220IIB features!)..." -ForegroundColor Cyan

    # Example 1: Function completed - SUCCESS with RED and LOUD buzzer!
    Print-CodingEvent `
        -Event "Function Completed" `
        -Details @(
            "Function: Get-UserData()",
            "Lines: 45",
            "Tests: 3 passed",
            "Duration: 12 minutes"
        ) `
        -Success `
        -Loud

    Start-Sleep -Seconds 2

    # Example 2: Build successful - RED header, short beep
    Print-CodingEvent `
        -Event "Build Successful" `
        -Details @(
            "Project: MyAwesomeApp",
            "Warnings: 0",
            "Errors: 0",
            "Time: 2.3s"
        ) `
        -Success

    Start-Sleep -Seconds 2

    # Example 3: Git commit - SUCCESS but quieter
    Print-CodingEvent `
        -Event "Git Commit" `
        -Details @(
            "Commit: feat: add new feature",
            "Files changed: 5",
            "Insertions: 150",
            "Deletions: 20"
        ) `
        -Success

    Start-Sleep -Seconds 2

    # Example 4: Warning - just info, no special color
    Print-CodingEvent `
        -Event "Code Review Needed" `
        -Details @(
            "PR: #42",
            "Title: Implement feature X",
            "Reviewer: @teammate",
            "",
            "Don't forget to follow up!"
        ) `
        -Warning

    Write-Host "Dotbot events printed!" -ForegroundColor Green
    Write-Host "`nTM-U220IIB Features Used:" -ForegroundColor Yellow
    Write-Host "  - RED text for success headers" -ForegroundColor Red
    Write-Host "  - LOUD real-time buzzer" -ForegroundColor Cyan
    Write-Host "  - Paper cut after each receipt" -ForegroundColor Cyan

    Disconnect-Printer
}
else {
    Write-Host "Failed to connect to printer at $printerIP" -ForegroundColor Red
    Write-Host "Make sure to update the IP address in this script." -ForegroundColor Yellow
}

# Usage in Dotbot:
# 1. Import-Module Printer
# 2. Connect-Printer -IPAddress "YOUR_PRINTER_IP"
# 3. Use Print-CodingEvent or Send-PrinterReceipt in your automation
# 4. Enjoy LOUD physical receipts of your coding achievements!
#
# TM-U220IIB Specific Features Available:
# - Set-PrinterColor -Color Red/Black   (two-color ribbon)
# - Invoke-PrinterBuzzer -Times 3 -Duration Long  (LOUD!)
# - Set-PrinterFont -Font A/B  (different sizes)
# - Invoke-PrinterFeed -Lines 5 -Reverse  (paper control)
