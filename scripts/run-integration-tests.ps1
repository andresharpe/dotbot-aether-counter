Write-Host "=== INTEGRATION TEST CHECK ===" -ForegroundColor Cyan
Write-Host ""

# Import module to enable discovery
$ModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'src\Printer\Printer.psd1'
Import-Module $ModulePath -Force

# Try to discover printer if not manually configured
if (-not $env:PRINTER_TEST_IP) {
    Write-Host "No printer manually configured. Attempting discovery..." -ForegroundColor Cyan
    $discoveredPrinters = Find-Printer -ErrorAction SilentlyContinue

    if ($discoveredPrinters) {
        $env:PRINTER_TEST_IP = $discoveredPrinters[0].IP
        Write-Host "Discovered printer at: $env:PRINTER_TEST_IP" -ForegroundColor Green
    }
}

if ($env:PRINTER_TEST_IP) {
    Write-Host "Testing with printer: $env:PRINTER_TEST_IP" -ForegroundColor Green
    Write-Host "Running integration tests..." -ForegroundColor Cyan
    Write-Host ""

    Invoke-Pester -Path .\tests\Integration\ -Output Detailed
} else {
    Write-Host "No text printer found on network." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Integration tests require a physical text printer." -ForegroundColor Yellow
    Write-Host "To manually specify a printer, set:" -ForegroundColor Yellow
    Write-Host '  $env:PRINTER_TEST_IP = "192.168.x.x"' -ForegroundColor White
    Write-Host ""
    Write-Host "Skipping integration tests (optional for QA)." -ForegroundColor Yellow
}
