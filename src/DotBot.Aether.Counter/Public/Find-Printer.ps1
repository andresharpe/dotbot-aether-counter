function Find-Printer {
    <#
    .SYNOPSIS
        Discovers text printers on the local network.

    .DESCRIPTION
        Two-stage device discovery process:
        1. Build IP candidate list from ARP cache or full subnet scan
        2. Probe each IP in parallel to verify text printers on port 9100

    .PARAMETER FullScan
        Scan entire /24 subnet instead of just ARP cache entries.
        Slower but more thorough.

    .PARAMETER TimeoutSec
        Timeout in seconds for each device probe (default 2).

    .PARAMETER Subnet
        Override subnet for full scan (e.g., '192.168.1.0/24').
        If not specified, uses the subnet of the first active network adapter.

    .PARAMETER Port
        TCP port to scan for text printers (default 9100).

    .EXAMPLE
        Find-Printer

        Discovers printers using ARP cache (fastest).

    .EXAMPLE
        Find-Printer -FullScan

        Scan entire subnet (slower but finds all printers).

    .EXAMPLE
        Find-Printer | Select-Object -First 1 | Connect-Printer

        Find and connect to the first discovered printer.

    .OUTPUTS
        PSCustomObject[] - Array of printers with Name, IP, Port, IsAccessible properties.

    .NOTES
        Performance targets:
        - ARP scan: < 5 seconds
        - Full scan: < 20 seconds

        Uses parallel probing with throttle limit of 50 concurrent connections.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter()]
        [switch]$FullScan,

        [Parameter()]
        [ValidateRange(1, 30)]
        [int]$TimeoutSec = 2,

        [Parameter()]
        [string]$Subnet,

        [Parameter()]
        [ValidateRange(1, 65535)]
        [int]$Port = 9100
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        $discoveredPrinters = [System.Collections.ArrayList]::new()
    }

    process {
        # Stage 1: Build IP Candidate List
        Write-Host "Scanning local network for text printers..." -ForegroundColor Cyan

        $ipCandidates = [System.Collections.ArrayList]::new()

        if ($FullScan) {
            # Full subnet scan
            if (-not $Subnet) {
                # Auto-detect subnet from first active adapter
                try {
                    $adapter = Get-NetIPAddress -AddressFamily IPv4 |
                               Where-Object {
                                   $_.InterfaceAlias -notlike '*Loopback*' -and
                                   $_.InterfaceAlias -notlike '*WSL*' -and
                                   $_.InterfaceAlias -notlike '*Hyper-V*' -and
                                   $_.InterfaceAlias -notlike '*Default Switch*' -and
                                   $_.InterfaceAlias -notlike '*NordLynx*' -and
                                   $_.InterfaceAlias -notlike '*OpenVPN*' -and
                                   $_.InterfaceAlias -notlike '*vEthernet*' -and
                                   $_.PrefixOrigin -ne 'WellKnown' -and
                                   $_.IPAddress -notlike '169.254.*' -and
                                   $_.IPAddress -notlike '127.*'
                               } |
                               Select-Object -First 1

                    if ($adapter) {
                        $ipParts = $adapter.IPAddress -split '\.'
                        $Subnet = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2]).0/24"
                        Write-Verbose "Auto-detected subnet: $Subnet"
                    }
                    else {
                        Write-Error "Could not auto-detect subnet. Please specify -Subnet parameter."
                        return
                    }
                }
                catch {
                    Write-Error "Failed to detect subnet: $($_.Exception.Message)"
                    return
                }
            }

            # Generate all IPs in subnet
            $subnetParts = $Subnet -split '/'
            $baseIP = $subnetParts[0]
            $ipParts = $baseIP -split '\.'

            Write-Verbose "Generating full subnet IP list for $Subnet"

            for ($i = 1; $i -le 254; $i++) {
                $ip = "$($ipParts[0]).$($ipParts[1]).$($ipParts[2]).$i"
                [void]$ipCandidates.Add($ip)
            }

            Write-Host "  Scanning $($ipCandidates.Count) IP addresses..." -ForegroundColor Cyan
        }
        else {
            # ARP cache scan (faster)
            Write-Verbose "Reading ARP cache"

            try {
                $arpOutput = & arp -a
                foreach ($line in $arpOutput) {
                    if ($line -match '^\s+(\d+\.\d+\.\d+\.\d+)\s+') {
                        [void]$ipCandidates.Add($Matches[1])
                    }
                }

                Write-Host "  Found $($ipCandidates.Count) IPs in ARP cache" -ForegroundColor Cyan
            }
            catch {
                Write-Warning "Failed to read ARP cache: $($_.Exception.Message)"
            }
        }

        # Build ARP MAC address lookup table
        $macLookup = @{}
        try {
            $arpAll = & arp -a
            foreach ($line in $arpAll) {
                if ($line -match '^\s+(\d+\.\d+\.\d+\.\d+)\s+([\w-]{17})\s+') {
                    $macLookup[$Matches[1]] = $Matches[2].ToUpper()
                }
            }
            Write-Verbose "Built MAC lookup table with $($macLookup.Count) entries"
        }
        catch {
            Write-Verbose "Could not build MAC lookup: $($_.Exception.Message)"
        }

        # Known manufacturer OUI prefixes (first 3 octets, colon-separated)
        $ouiTable = @{
            # Epson
            '00:26:AB' = 'Epson'; '00:1B:35' = 'Epson'; '88:12:4E' = 'Epson'
            '00:80:87' = 'Epson'; 'AC:18:26' = 'Epson'; '60:7D:09' = 'Epson'
            '48:44:F7' = 'Epson'; 'D4:6A:6A' = 'Epson'; 'EC:9B:8B' = 'Epson'
            '38:1A:52' = 'Epson'; '64:EB:8C' = 'Epson'; 'E0:4F:43' = 'Epson'
            # Star Micronics
            '00:07:4D' = 'Star Micronics'; '00:11:62' = 'Star Micronics'
            '00:1A:B6' = 'Star Micronics'
            # Bixolon / Samsung
            '00:01:E3' = 'Bixolon'; '00:15:99' = 'Samsung (Bixolon)'
            # Citizen
            '00:1C:BE' = 'Citizen Systems'
            # HP (not a receipt printer, but useful for identification)
            '6C:C2:17' = 'HP'; '3C:D9:2B' = 'HP'; '10:60:4B' = 'HP'
            '94:57:A5' = 'HP'; 'A0:D3:C1' = 'HP'; 'F4:CE:46' = 'HP'
        }

        # Stage 2: Parallel Probe
        if ($ipCandidates.Count -gt 0) {
            Write-Host "Probing devices on port $Port..." -ForegroundColor Cyan

            $probeResults = Invoke-PrinterParallelProbe -IPAddresses $ipCandidates.ToArray() -Port $Port -TimeoutSec $TimeoutSec

            foreach ($result in $probeResults) {
                # Resolve hostname via reverse DNS
                $hostname = $null
                try {
                    $dnsResult = [System.Net.Dns]::GetHostEntry($result.IP)
                    if ($dnsResult.HostName -and $dnsResult.HostName -ne $result.IP) {
                        $hostname = $dnsResult.HostName
                    }
                }
                catch {
                    # DNS lookup failed - that's fine
                }

                # Look up MAC address and manufacturer
                $mac = $null
                $manufacturer = $null
                if ($macLookup.ContainsKey($result.IP)) {
                    $mac = $macLookup[$result.IP]
                    $ouiPrefix = ($mac -replace '-', ':').Substring(0, 8)
                    if ($ouiTable.ContainsKey($ouiPrefix)) {
                        $manufacturer = $ouiTable[$ouiPrefix]
                    }
                }

                # Build display name from manufacturer or fall back to generic
                $displayName = $result.Name
                if ($manufacturer -and $displayName -eq 'Text Printer') {
                    $displayName = "$manufacturer Printer"
                }

                $printerObj = [PSCustomObject]@{
                    Name = $displayName
                    IP = $result.IP
                    Port = $result.Port
                    Hostname = $hostname
                    MACAddress = $mac
                    Manufacturer = $manufacturer
                    IsAccessible = $result.IsAccessible
                    Source = if ($FullScan) { 'FullScan' } else { 'ARP' }
                }
                [void]$discoveredPrinters.Add($printerObj)

                $detail = $displayName
                if ($hostname) { $detail += " ($hostname)" }
                if ($mac) { $detail += " [$mac]" }
                Write-Host "  Found: $detail at $($result.IP):$Port" -ForegroundColor Green
            }
        }

        # Summary
        Write-Host "`nDiscovery complete: $($discoveredPrinters.Count) printer(s) found" -ForegroundColor Green

        if ($discoveredPrinters.Count -eq 0) {
            Write-Warning "No text printers found on port $Port. Try using -FullScan for a more thorough search."
        }

        return $discoveredPrinters.ToArray()
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
