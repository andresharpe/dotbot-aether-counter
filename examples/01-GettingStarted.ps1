# Example 1: Getting Started with Printer Module

# Import the module
Import-Module "$PSScriptRoot\..\src\Printer\Printer.psd1" -Force

# Discover text printers on the network
Write-Host "`n=== Discovering Printers ===" -ForegroundColor Yellow
$printers = Find-Printer
$printers | Format-Table Name, IP, Port, Source

# If no printers found, try a full scan
if ($printers.Count -eq 0) {
    Write-Host "`nNo printers found in ARP cache. Trying full scan..." -ForegroundColor Yellow
    $printers = Find-Printer -FullScan
}

# Connect to the first printer found
if ($printers.Count -gt 0) {
    Write-Host "`n=== Connecting to Printer ===" -ForegroundColor Yellow
    $printer = $printers[0]

    # Pipeline example: Find | Connect
    $printer | Connect-Printer

    # Test connection
    if (Test-PrinterConnection) {
        Write-Host "Connection test: PASSED" -ForegroundColor Green

        # Get printer configuration
        Write-Host "`n=== Printer Configuration ===" -ForegroundColor Yellow
        Get-PrinterConfiguration | Format-List

        # Send a test print
        Write-Host "`n=== Sending Test Print ===" -ForegroundColor Yellow
        Send-PrinterText -Text "Hello from PowerShell!" -Align Center -Bold
        Send-PrinterRule
        Send-PrinterText -Text "Printer Module Test" -Align Center
        Send-PrinterRule
        Send-PrinterText -Text "Timestamp: $(Get-Date)" -Align Left
        Clear-Printer -Lines 3
        Invoke-PrinterCut

        Write-Host "Test print sent successfully!" -ForegroundColor Green

        # Disconnect
        Disconnect-Printer
    }
}
else {
    Write-Host "`nNo printers found. Please verify:" -ForegroundColor Red
    Write-Host "  1. Printer is powered on" -ForegroundColor Yellow
    Write-Host "  2. Printer is connected to the network" -ForegroundColor Yellow
    Write-Host "  3. Printer is reachable on port 9100" -ForegroundColor Yellow
}
