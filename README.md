# Printer PowerShell Module

A comprehensive PowerShell module for controlling text printers via TCP/IP network connection.

[![PowerShell Version](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Features

- **Complete Text Printing Support** - Text printing, formatting, paper cutting, and more
- **Network Discovery** - Automatic printer detection via ARP cache or subnet scanning
- **Pipeline Support** - Seamless integration with PowerShell pipelines
- **Easy Integration** - Perfect for Dotbot and other coding automation tools
- **Cross-Platform** - PowerShell 5.1+ (Windows) and PowerShell 7+ (Windows/Linux/macOS)
- **Epson TM-U220IIB Optimized** - Full support for impact printer features
- **Two-Color Printing** - Black and red text support
- **Real-Time Buzzer** - Loud attention-getting sounds for events!

## Quick Start

### Installation

```powershell
# Clone the repository
git clone https://github.com/yourusername/TextPrinter.git

# Import the module
Import-Module .\TextPrinter\src\Printer\Printer.psd1
```

### Basic Usage

```powershell
# Discover printers on your network
$printers = Find-Printer
$printers | Format-Table Name, IP, Port

# Connect to a printer (pipeline supported!)
$printers | Select-Object -First 1 | Connect-Printer

# Or connect directly by IP
Connect-Printer -IPAddress "192.168.0.100"

# Print some text
Send-PrinterText -Text "Hello from PowerShell!" -Align Center -Bold

# Print a formatted receipt
Send-PrinterReceipt `
    -Header "CODING SESSION" `
    -Body "Function: DoSomething()","Status: Success","Duration: 5 min" `
    -Footer "Keep coding! :)"

# Disconnect when done
Disconnect-Printer
```

## Functions Overview

The module provides **19 public functions** organized into four categories:

### Connection & Discovery (5 functions)
- `Find-Printer` - Discover printers (ARP + full scan options)
- `Connect-Printer` - Establish connection
- `Disconnect-Printer` - Close connection
- `Test-PrinterConnection` - Verify connectivity
- `Get-PrinterConfiguration` - Get printer settings

### Text Printing (6 functions)
- `Send-PrinterText` - Print text with formatting (alignment, bold, size)
- `Send-PrinterLine` - Quick single-line printing
- `Send-PrinterReceipt` - Formatted receipts with header/body/footer
- `Clear-Printer` - Feed blank lines
- `Invoke-PrinterCut` - Cut paper (full/partial)
- `Invoke-PrinterBeep` - Buzzer/beep (basic)

### Formatting (4 functions)
- `Set-PrinterAlignment` - Set text alignment (left/center/right)
- `Set-PrinterTextSize` - Set width/height multipliers
- `Set-PrinterEmphasis` - Bold on/off
- `Send-PrinterRule` - Print horizontal rule

### TM-U220IIB Specific (4 functions)
- `Set-PrinterColor` - Select print color (black/red)
- `Set-PrinterFont` - Select font (A/B)
- `Invoke-PrinterFeed` - Feed paper forward/reverse
- `Invoke-PrinterBuzzer` - Real-time buzzer with duration control

## Examples

See the [`examples/`](examples/) directory for comprehensive examples:

- **[01-GettingStarted.ps1](examples/01-GettingStarted.ps1)** - Discovery and connection basics
- **[02-PrintingText.ps1](examples/02-PrintingText.ps1)** - Text formatting and alignment
- **[03-PrintingReceipts.ps1](examples/03-PrintingReceipts.ps1)** - Structured receipt printing
- **[04-DotbotIntegration.ps1](examples/04-DotbotIntegration.ps1)** - Coding session receipts

### Dotbot Integration Example

Perfect for printing coding events during development:

```powershell
# Print a coding achievement in RED for impact!
Set-PrinterColor -Color Red
Send-PrinterReceipt `
    -Header "CODE COMPLETE" `
    -Body @(
        "Function: New-AwesomeFeature()",
        "Lines: 150",
        "Tests: 5 passed",
        "Time: $(Get-Date -Format 'HH:mm:ss')"
    ) `
    -Footer "Great work!" `
    -Cut
Set-PrinterColor -Color Black

# Make some noise! (LOUD real-time buzzer)
Invoke-PrinterBuzzer -Times 3 -Duration Long
```

## Documentation

### Function Help

Every function has comprehensive comment-based help:

```powershell
Get-Help Find-Printer -Full
Get-Help Send-PrinterText -Examples
Get-Help Send-PrinterReceipt -Parameter Body
```

### ESC/POS Command Reference

The module implements these standard ESC/POS commands:

- **Initialize**: `ESC @` (0x1B 0x40)
- **Text Alignment**: `ESC a n` (0x1B 0x61 n) - n=0(left), 1(center), 2(right)
- **Bold On**: `ESC E 1` (0x1B 0x45 0x01)
- **Bold Off**: `ESC E 0` (0x1B 0x45 0x00)
- **Text Size**: `GS ! n` (0x1D 0x21 n) - combines width/height
- **Paper Cut**: `GS V m` (0x1D 0x56 m) - m=0(full), 1(partial)
- **Line Feed**: `LF` (0x0A)

## Requirements

- **PowerShell**: Version 5.1 or later (Windows), or PowerShell 7+ (cross-platform)
- **Network**: Text printer on same network
- **Port**: Printer accessible on TCP port 9100 (standard ESC/POS port)
- **Printer**: Epson TM-U220IIB or compatible text printer

## TM-U220IIB Specific Features

### Two-Color Printing
```powershell
# Print in red (for emphasis)
Set-PrinterColor -Color Red
Send-PrinterText -Text "WARNING!" -Align Center -Bold
Set-PrinterColor -Color Black  # Back to black
```

### Real-Time Buzzer
```powershell
# Beep 3 times with long duration (LOUD!)
Invoke-PrinterBuzzer -Times 3 -Duration Long

# Short quick beep
Invoke-PrinterBuzzer -Times 1 -Duration Short
```

### Font Selection
```powershell
# Font A = larger, Font B = smaller/condensed
Set-PrinterFont -Font B
Send-PrinterText -Text "Smaller condensed text"
Set-PrinterFont -Font A
```

### Paper Feed Control
```powershell
# Feed 5 lines forward
Invoke-PrinterFeed -Lines 5

# Reverse feed (for special effects)
Invoke-PrinterFeed -Lines 2 -Reverse
```

## Key Features Explained

### Device Discovery

Find-Printer uses a two-stage discovery process:

1. **ARP Cache Scan** (default) - Fast, checks devices your computer has communicated with
2. **Full Subnet Scan** (optional with `-FullScan`) - Thorough, scans all /24 subnet IPs

```powershell
# Fast discovery (ARP cache)
Find-Printer

# Thorough discovery (full subnet scan)
Find-Printer -FullScan

# Custom subnet
Find-Printer -FullScan -Subnet "10.0.1.0/24"
```

### Pipeline Support

The module supports PowerShell pipelines for natural workflows:

```powershell
# Discover and connect in one line
Find-Printer | Select-Object -First 1 | Connect-Printer

# Send multiple text lines
"Line 1", "Line 2", "Line 3" | Send-PrinterText -Align Center
```

### Error Handling

Automatic retry logic for transient failures:
- **Retries**: Timeout, connection refused, network errors
- **Does NOT retry**: Invalid IP, permanent failures
- **Exponential backoff**: 1s, 2s, 4s between retries

## Troubleshooting

### Printer Not Found

1. Verify printer is powered on and connected to network
2. Check printer is accessible on port 9100
3. Try `-FullScan` parameter
4. Manually connect if you know the IP: `Connect-Printer -IPAddress "X.X.X.X"`

### Connection Timeout

- Verify firewall allows outbound connections on port 9100
- Check printer network settings
- Confirm printer is in network printing mode

### Text Not Printing Correctly

- Ensure CharactersPerLine matches your printer (default: 40)
- Adjust with: `Connect-Printer -CharactersPerLine 42`
- Check printer character encoding settings

## Contributing

Contributions are welcome! Feel free to:
- Report bugs via GitHub Issues
- Submit feature requests
- Create pull requests

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Based on the ESC/POS protocol specification
- Inspired by Hue and Pixoo PowerShell modules
- Built for Dotbot and the PowerShell community

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/TextPrinter/issues)
- **Examples**: See [`examples/`](examples/) directory
- **Documentation**: Use `Get-Help <Function-Name> -Full`

---

**Made with love for the PowerShell and maker communities**

**Perfect for**: Dotbot integration, CI/CD notifications, coding achievements, fun office automation!
