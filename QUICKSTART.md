# Printer Quick Start Guide

## Setup

1. **Import the module:**
   ```powershell
   Import-Module .\src\Printer\Printer.psd1
   ```

2. **Find your printer:**
   ```powershell
   # Quick scan (ARP cache)
   Find-Printer

   # Full subnet scan
   Find-Printer -FullScan
   ```

3. **Connect to printer:**
   ```powershell
   # Via pipeline
   Find-Printer | Select-Object -First 1 | Connect-Printer

   # Or directly if you know the IP
   Connect-Printer -IPAddress "192.168.0.100"
   ```

## Basic Usage

### Print Simple Text
```powershell
Send-PrinterText -Text "Hello, World!"
```

### Print with Formatting
```powershell
# Centered, bold, large text
Send-PrinterText -Text "IMPORTANT!" -Align Center -Bold -Width 2 -Height 2

# Left-aligned, normal
Send-PrinterText -Text "Normal text" -Align Left
```

### Print a Receipt
```powershell
Send-PrinterReceipt `
    -Header "MY RECEIPT" `
    -Body @(
        "Item 1: $10.00",
        "Item 2: $15.00",
        "--------------",
        "Total: $25.00"
    ) `
    -Footer "Thank you!"
```

### For Dotbot - Print Coding Events
```powershell
Send-PrinterReceipt `
    -Header "CODE COMPLETE" `
    -Body @(
        "Function: New-Feature()",
        "Status: SUCCESS",
        "Time: $(Get-Date -Format 'HH:mm:ss')"
    ) `
    -Footer "Keep coding!"

# Add a beep for celebration!
Invoke-PrinterBeep -Times 3
```

## Common Commands

| Command | Purpose |
|---------|---------|
| `Find-Printer` | Discover printers on network |
| `Connect-Printer` | Connect to a printer |
| `Send-PrinterText` | Print text with formatting |
| `Send-PrinterReceipt` | Print structured receipt |
| `Send-PrinterLine` | Quick single line print |
| `Invoke-PrinterCut` | Cut paper |
| `Invoke-PrinterBeep` | Beep/buzzer |
| `Disconnect-Printer` | Disconnect |

## Pipeline Examples

```powershell
# Print multiple lines
"Line 1", "Line 2", "Line 3" | Send-PrinterText

# Find and connect
Find-Printer | Select-Object -First 1 | Connect-Printer
```

## Get Help

Every function has comprehensive help:
```powershell
Get-Help Send-PrinterText -Full
Get-Help Find-Printer -Examples
```

## Next Steps

- Check out the **[examples/](examples/)** directory for detailed examples
- Read the **[README.md](README.md)** for complete documentation
- Run **[examples/01-GettingStarted.ps1](examples/01-GettingStarted.ps1)** for a test
- Try **[examples/04-DotbotIntegration.ps1](examples/04-DotbotIntegration.ps1)** for Dotbot usage

## Troubleshooting

**Printer not found?**
- Verify it's on and connected to network
- Check it's accessible on port 9100
- Try `-FullScan` parameter

**Connection issues?**
- Check firewall allows port 9100
- Verify printer IP address
- Use `Test-PrinterConnection` to diagnose

**Text not printing correctly?**
- Adjust `CharactersPerLine` when connecting
- Default is 40 for Epson UB-E04

## TM-U220IIB Specific Commands

```powershell
# Print in RED (two-color ribbon)
Set-PrinterColor -Color Red
Send-PrinterText -Text "IMPORTANT!" -Bold
Set-PrinterColor -Color Black

# LOUD real-time buzzer
Invoke-PrinterBuzzer -Times 3 -Duration Long

# Font selection (A=larger, B=smaller)
Set-PrinterFont -Font B

# Paper feed control
Invoke-PrinterFeed -Lines 5
```

## Module Info

- **Version:** 1.0.0
- **Functions:** 20 public functions
- **Platform:** PowerShell 5.1+ (Windows), PowerShell 7+ (cross-platform)
- **Protocol:** ESC/POS over TCP/IP (port 9100)
- **Optimized for:** Epson TM-U220IIB (40 characters, impact printer)
- **Features:** Two-color printing (black/red), real-time buzzer, font selection

---

**Happy LOUD Printing!**
