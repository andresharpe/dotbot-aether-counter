function Get-PrinterConfiguration {
    <#
    .SYNOPSIS
        Retrieves the current printer configuration.

    .DESCRIPTION
        Returns the session configuration including IP, port, and printer settings.

    .EXAMPLE
        Get-PrinterConfiguration

    .OUTPUTS
        PSCustomObject with printer configuration.
    #>

    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }

    process {
        if (-not (Test-PrinterSession)) {
            Write-Error "Not connected to a printer. Use Connect-Printer first."
            return
        }

        return [PSCustomObject]@{
            IPAddress = $script:PrinterSession.IPAddress
            Port = $script:PrinterSession.Port
            Connected = $script:PrinterSession.Connected
            LastContact = $script:PrinterSession.LastContact
            PrinterName = $script:PrinterSession.PrinterInfo.Name
            CharactersPerLine = $script:PrinterSession.PrinterInfo.CharactersPerLine
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
