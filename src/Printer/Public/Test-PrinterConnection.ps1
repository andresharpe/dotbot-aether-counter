function Test-PrinterConnection {
    <#
    .SYNOPSIS
        Tests connectivity to the connected text printer.

    .DESCRIPTION
        Verifies that the printer is reachable by attempting a connection test.

    .EXAMPLE
        Test-PrinterConnection

    .OUTPUTS
        System.Boolean - $true if printer is reachable, $false otherwise.
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param()

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }

    process {
        if (-not (Test-PrinterSession)) {
            Write-Error "Not connected to a printer. Use Connect-Printer first."
            return $false
        }

        $tcpClient = $null
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $connectTask = $tcpClient.ConnectAsync($script:PrinterSession.IPAddress, $script:PrinterSession.Port)

            if ($connectTask.Wait(3000)) {
                Write-Verbose "Printer is reachable"
                return $true
            }
            else {
                Write-Warning "Connection timeout"
                return $false
            }
        }
        catch {
            Write-Error "Failed to connect: $($_.Exception.Message)"
            return $false
        }
        finally {
            if ($tcpClient) {
                $tcpClient.Close()
                $tcpClient.Dispose()
            }
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
