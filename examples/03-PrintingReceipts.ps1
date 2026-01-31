# Example 3: Printing Formatted Receipts

# Import the module
Import-Module "$PSScriptRoot\..\src\Printer\Printer.psd1" -Force

# Connect to printer (replace with your printer's IP)
$printerIP = "192.168.0.100"  # Change this to your printer's IP
Connect-Printer -IPAddress $printerIP

if (Test-PrinterConnection) {
    Write-Host "Printing receipt examples..." -ForegroundColor Cyan

    # Example 1: Simple Receipt
    Send-PrinterReceipt `
        -Header "COFFEE SHOP" `
        -Body @(
            "1x Cappuccino       $4.50"
            "1x Croissant        $3.00"
            "------------------------"
            "Total:              $7.50"
        ) `
        -Footer @(
            "Thank you!"
            "Come again!"
        )

    Start-Sleep -Seconds 2

    # Example 2: Receipt with timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Send-PrinterReceipt `
        -Header "STORE RECEIPT" `
        -Body @(
            "Date: $timestamp"
            ""
            "Item A              $10.00"
            "Item B              $15.00"
            "Item C               $5.00"
            "------------------------"
            "Subtotal:           $30.00"
            "Tax (10%):           $3.00"
            "========================"
            "TOTAL:              $33.00"
        ) `
        -Footer "Receipt #12345"

    Write-Host "Receipts printed!" -ForegroundColor Green

    Disconnect-Printer
}
else {
    Write-Host "Failed to connect to printer at $printerIP" -ForegroundColor Red
}
