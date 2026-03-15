# DotBot.Aether.Counter

Aether **Counter** conduit — ESC/POS receipt printer integration for [dotbot](https://github.com/andresharpe/dotbot-v3). Part of the [dotbot-aether](https://github.com/andresharpe/dotbot-aether) conduit plugin collection.

[![PowerShell 7.0+](https://img.shields.io/badge/PowerShell-7.0%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## What It Does

Translates dotbot event bus events into physical printed records — task tallies, workflow summaries, daily/weekly reckoning receipts. Supports text formatting (alignment, bold, size), two-color printing (black/red), paper cut, font selection, buzzer alerts, and receipt templates. Optimized for Epson TM-U220IIB.

## Quick Start

```powershell
Import-Module ./src/DotBot.Aether.Counter/DotBot.Aether.Counter.psd1

# Discover and connect
Find-AetherCounter | Connect-AetherCounter

# Or use the native Printer functions directly
Find-Printer | Connect-Printer
Send-PrinterReceipt -Header "CODE COMPLETE" -Body "Status: Success" -Footer "Keep coding!" -Cut
Invoke-PrinterBuzzer -Times 3 -Duration Long
```

## Aether Contract Functions

Every Aether conduit exports these standard lifecycle functions:

- `Initialize-AetherCounter` — validate config and hardware reachability
- `Find-AetherCounter` — discover printers on the network
- `Connect-AetherCounter` — bond to a discovered printer
- `Disconnect-AetherCounter` — clean shutdown
- `Test-AetherCounter` — health check
- `Invoke-AetherCounterEvent` — handle an event bus event (the sink entry point)

## Native Functions (20)

### Connection & Discovery
`Find-Printer`, `Connect-Printer`, `Disconnect-Printer`, `Test-PrinterConnection`, `Get-PrinterConfiguration`, `Initialize-Printer`

### Text Printing
`Send-PrinterText`, `Send-PrinterLine`, `Send-PrinterReceipt`, `Send-PrinterRule`, `Clear-Printer`, `Invoke-PrinterCut`

### Formatting
`Set-PrinterAlignment`, `Set-PrinterTextSize`, `Set-PrinterEmphasis`, `Set-PrinterFont`, `Set-PrinterColor`

### Alerts
`Invoke-PrinterBeep`, `Invoke-PrinterBuzzer`, `Invoke-PrinterFeed`

## Documentation

- [TM-U220IIB Technical Reference](docs/tm-u220ii_trg_en_rev_c.pdf)

## Testing

```powershell
Invoke-Pester ./tests/Unit
Invoke-Pester ./tests/Integration  # requires printer
```

## License

MIT — see [LICENSE](LICENSE)