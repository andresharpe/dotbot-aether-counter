function Invoke-PrinterParallelProbe {
    <#
    .SYNOPSIS
        Probes multiple IP addresses in parallel for text printers.

    .DESCRIPTION
        Tests a list of IP addresses concurrently to identify text printers.
        Uses throttled parallel execution with configurable timeout.

    .PARAMETER IPAddresses
        Array of IP addresses to probe.

    .PARAMETER Port
        TCP port to test (default 9100 for ESC/POS).

    .PARAMETER TimeoutSec
        Timeout in seconds for each probe attempt (default 2).

    .PARAMETER ThrottleLimit
        Maximum number of concurrent connections (default 50).

    .EXAMPLE
        Invoke-PrinterParallelProbe -IPAddresses @('192.168.0.100', '192.168.0.101')

    .NOTES
        This is an internal helper function used by Find-Printer.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$IPAddresses,

        [Parameter()]
        [int]$Port = 9100,

        [Parameter()]
        [ValidateRange(1, 30)]
        [int]$TimeoutSec = 2,

        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$ThrottleLimit = 50
    )

    begin {
        Write-Verbose "Starting parallel probe of $($IPAddresses.Count) IP addresses"
    }

    process {
        $timeoutMs = $TimeoutSec * 1000

        $probeResults = $IPAddresses | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
            $IP = $_
            $Port = $using:Port
            $TimeoutMs = $using:timeoutMs

            $tcpClient = $null
            try {
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $connectTask = $tcpClient.ConnectAsync($IP, $Port)

                if ($connectTask.Wait($TimeoutMs)) {
                    [PSCustomObject]@{
                        IP = $IP
                        Port = $Port
                        IsAccessible = $true
                        Name = "Text Printer"
                    }
                }
            }
            catch {
                # Ignore errors
            }
            finally {
                if ($tcpClient) {
                    $tcpClient.Close()
                    $tcpClient.Dispose()
                }
            }
        }

        return $probeResults | Where-Object { $_ -ne $null }
    }

    end {
        Write-Verbose "Parallel probe completed"
    }
}
