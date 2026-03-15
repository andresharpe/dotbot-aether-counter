function Disconnect-Printer {
    <#
    .SYNOPSIS
        Disconnects from the text printer.

    .DESCRIPTION
        Closes the connection and clears the module session.

    .EXAMPLE
        Disconnect-Printer

    .OUTPUTS
        None
    #>

    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }

    process {
        if ($script:PrinterSession) {
            Write-Host "Disconnecting from text printer at $($script:PrinterSession.IPAddress)..." -ForegroundColor Cyan
            $script:PrinterSession = $null
            Write-Host "Disconnected successfully" -ForegroundColor Green
        }
        else {
            Write-Warning "Not connected to any printer"
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
