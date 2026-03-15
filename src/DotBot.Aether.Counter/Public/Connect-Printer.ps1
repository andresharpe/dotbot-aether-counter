function Connect-Printer {
    <#
    .SYNOPSIS
        Establishes connection to a text printer.

    .DESCRIPTION
        Tests connectivity to a text printer and creates a module session for subsequent commands.
        Supports pipeline input from Find-Printer.

    .PARAMETER IPAddress
        IP address of the text printer.
        Accepts 'IP' property from pipeline (e.g., from Find-Printer).

    .PARAMETER Port
        TCP port (default 9100 for ESC/POS).

    .PARAMETER CharactersPerLine
        Number of characters per line for text wrapping (default 40 for Epson UB-E04).

    .PARAMETER TimeoutSec
        Connection timeout in seconds (default 5).

    .EXAMPLE
        Connect-Printer -IPAddress '192.168.0.100'

    .EXAMPLE
        Find-Printer | Select-Object -First 1 | Connect-Printer

        Find and connect to the first discovered printer.

    .OUTPUTS
        System.Boolean - $true if connection successful, $false otherwise.

    .NOTES
        Creates $script:PrinterSession with connection details.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('IP')]
        [ValidateNotNullOrEmpty()]
        [string]$IPAddress,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 65535)]
        [int]$Port = 9100,

        [Parameter()]
        [ValidateRange(20, 80)]
        [int]$CharactersPerLine = 40,

        [Parameter()]
        [ValidateRange(1, 30)]
        [int]$TimeoutSec = 5
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }

    process {
        $target = "Text Printer at $IPAddress"
        $action = "Establish connection"

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            try {
                Write-Host "Connecting to text printer at ${IPAddress}:${Port}..." -ForegroundColor Cyan

                # Test connectivity with a simple connection attempt
                $tcpClient = $null
                try {
                    $tcpClient = New-Object System.Net.Sockets.TcpClient
                    $connectTask = $tcpClient.ConnectAsync($IPAddress, $Port)

                    if (-not $connectTask.Wait($TimeoutSec * 1000)) {
                        Write-Error "Connection timeout after $TimeoutSec seconds"
                        return $false
                    }

                    # Connection successful - create session
                    $script:PrinterSession = @{
                        IPAddress = $IPAddress
                        Port = $Port
                        Connected = $true
                        LastContact = [DateTime]::Now
                        PrinterInfo = @{
                            Name = 'Text Printer'
                            CharactersPerLine = $CharactersPerLine
                        }
                    }

                    Write-Host "Successfully connected to text printer at $IPAddress" -ForegroundColor Green
                    return $true
                }
                finally {
                    if ($tcpClient) {
                        $tcpClient.Close()
                        $tcpClient.Dispose()
                    }
                }
            }
            catch {
                Write-Error "Failed to connect to ${IPAddress}:${Port} : $($_.Exception.Message)"
                return $false
            }
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
