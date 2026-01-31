# Mock data and responses for testing

# Mock printer device info
$script:MockPrinterInfo = @{
    Name = 'Mock TM-U220IIB'
    IP = '192.168.0.100'
    Port = 9100
    CharactersPerLine = 40
}

# Mock discovered printers (simulates ARP scan results)
$script:MockDiscoveredPrinters = @(
    [PSCustomObject]@{
        Name = 'Text Printer'
        IP = '192.168.0.100'
        Port = 9100
        IsAccessible = $true
        Source = 'ARP'
    }
    [PSCustomObject]@{
        Name = 'Text Printer'
        IP = '192.168.0.101'
        Port = 9100
        IsAccessible = $true
        Source = 'ARP'
    }
)

# Mock empty discovery
$script:MockEmptyDiscovery = @()

# Mock session object
$script:MockSession = @{
    IPAddress = '192.168.0.100'
    Port = 9100
    Connected = $true
    LastContact = [DateTime]::Now
    PrinterInfo = @{
        Name = 'Mock TM-U220IIB'
        CharactersPerLine = 40
    }
}

# Mock successful TCP connection result
$script:MockTcpConnectSuccess = $true

# Mock failed TCP connection result
$script:MockTcpConnectFailure = $false

# Expected ESC/POS command byte sequences
$script:ExpectedCommands = @{
    # ESC @ - Initialize printer
    Initialize = [byte[]]@(0x1B, 0x40)

    # ESC a n - Set alignment
    AlignLeft = [byte[]]@(0x1B, 0x61, 0x00)
    AlignCenter = [byte[]]@(0x1B, 0x61, 0x01)
    AlignRight = [byte[]]@(0x1B, 0x61, 0x02)

    # ESC E n - Bold on/off
    BoldOn = [byte[]]@(0x1B, 0x45, 0x01)
    BoldOff = [byte[]]@(0x1B, 0x45, 0x00)

    # GS ! n - Text size
    SizeNormal = [byte[]]@(0x1D, 0x21, 0x00)
    SizeDoubleWidth = [byte[]]@(0x1D, 0x21, 0x10)
    SizeDoubleHeight = [byte[]]@(0x1D, 0x21, 0x01)
    SizeDoubleBoth = [byte[]]@(0x1D, 0x21, 0x11)

    # GS V m - Cut paper
    CutFull = [byte[]]@(0x1D, 0x56, 0x00)
    CutPartial = [byte[]]@(0x1D, 0x56, 0x01)

    # LF - Line feed
    LineFeed = [byte[]]@(0x0A)

    # ESC r n - Select print color (TM-U220IIB)
    ColorBlack = [byte[]]@(0x1B, 0x72, 0x00)
    ColorRed = [byte[]]@(0x1B, 0x72, 0x01)

    # ESC M n - Select font
    FontA = [byte[]]@(0x1B, 0x4D, 0x00)
    FontB = [byte[]]@(0x1B, 0x4D, 0x01)

    # ESC d n - Feed n lines
    Feed3Lines = [byte[]]@(0x1B, 0x64, 0x03)
    Feed5Lines = [byte[]]@(0x1B, 0x64, 0x05)

    # DLE DC4 fn n t - Buzzer (TM-U220IIB)
    BuzzerShort = [byte[]]@(0x10, 0x14, 0x03, 0x01, 0x01)
    BuzzerLong = [byte[]]@(0x10, 0x14, 0x03, 0x01, 0x02)

    # BEL - Basic beep
    Beep = [byte[]]@(0x07)
}

# Helper to get expected command bytes
function Get-ExpectedCommand {
    param([string]$CommandName)
    return $script:ExpectedCommands[$CommandName]
}
