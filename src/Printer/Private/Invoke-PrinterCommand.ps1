function Invoke-PrinterCommand {
    <#
    .SYNOPSIS
        Core function for sending ESC/POS commands to printer via TCP/IP.

    .DESCRIPTION
        Sends raw byte arrays to the text printer over TCP connection with automatic
        retry logic for transient failures. This is the foundation function used by all
        public printing commands.

    .PARAMETER Data
        Byte array containing the ESC/POS command sequence to send to the printer.

    .PARAMETER MaxRetries
        Maximum number of retry attempts for transient failures (timeout, connection refused).
        Default is 3. Does NOT retry on permanent errors.

    .EXAMPLE
        $data = @(0x1B, 0x40)  # ESC @ (initialize)
        Invoke-PrinterCommand -Data $data

    .NOTES
        - Validates session exists before sending request
        - Uses exponential backoff: 1s, 2s, 4s between retries
        - Updates $script:PrinterSession.LastContact on successful send
        - Only retries on transient failures (network issues)
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [byte[]]$Data,

        [Parameter()]
        [ValidateRange(1, 10)]
        [int]$MaxRetries = 3
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"

        # Validate session exists
        if (-not (Test-PrinterSession)) {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new('Not connected to a text printer. Use Connect-Printer first.'),
                'PrinterSessionNotFound',
                [System.Management.Automation.ErrorCategory]::ConnectionError,
                $null
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    process {
        $attempt = 0
        $lastError = $null

        while ($attempt -lt $MaxRetries) {
            $attempt++
            $tcpClient = $null
            $stream = $null

            try {
                Write-Verbose "Attempt $attempt of $MaxRetries - Connecting to $($script:PrinterSession.IPAddress):$($script:PrinterSession.Port)"

                # Create TCP client
                $tcpClient = New-Object System.Net.Sockets.TcpClient
                $connectTask = $tcpClient.ConnectAsync($script:PrinterSession.IPAddress, $script:PrinterSession.Port)

                # Wait for connection with timeout
                if (-not $connectTask.Wait(5000)) {
                    throw "Connection timeout after 5 seconds"
                }

                # Get network stream
                $stream = $tcpClient.GetStream()
                $stream.WriteTimeout = 5000
                $stream.ReadTimeout = 5000

                Write-Verbose "Sending $($Data.Length) bytes to printer"

                # Send data
                $stream.Write($Data, 0, $Data.Length)
                $stream.Flush()

                # Update last contact timestamp
                $script:PrinterSession.LastContact = [DateTime]::Now

                Write-Verbose "Data sent successfully"
                return $true
            }
            catch {
                $lastError = $_
                Write-Verbose "Error on attempt $attempt : $($_.Exception.Message)"

                # Determine if we should retry
                $shouldRetry = $true

                # Check for permanent errors (don't retry these)
                if ($_.Exception.Message -match 'No connection could be made|actively refused') {
                    # Connection refused might be transient, retry
                    $shouldRetry = $true
                }
                elseif ($_.Exception.Message -match 'not exist|not found|invalid') {
                    # Host not found, invalid address - don't retry
                    $shouldRetry = $false
                    break
                }

                if (-not $shouldRetry -or $attempt -ge $MaxRetries) {
                    break
                }

                # Exponential backoff: 1s, 2s, 4s
                $backoffSeconds = [Math]::Pow(2, $attempt - 1)
                Write-Verbose "Waiting $backoffSeconds seconds before retry..."
                Start-Sleep -Seconds $backoffSeconds
            }
            finally {
                # Clean up resources
                if ($stream) {
                    $stream.Close()
                    $stream.Dispose()
                }
                if ($tcpClient) {
                    $tcpClient.Close()
                    $tcpClient.Dispose()
                }
            }
        }

        # All retries exhausted or non-retryable error
        if ($lastError) {
            $errorMessage = "Failed to send command after $attempt attempt(s): $($lastError.Exception.Message)"
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new($errorMessage),
                'PrinterCommandFailed',
                [System.Management.Automation.ErrorCategory]::ConnectionError,
                $Data
            )
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
