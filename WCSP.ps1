# Wemo Control Script for Powershell
#
# robert.labrie@gmail.com
#
# Ported from original BASH version written by rich@netmagi.com
#
# todo: Stop using a large XML string and use .Net native XML classes
# todo: Convert to importable powershell module

function Execute-WemoCommand {
    param(
        $body,
        $soapaction,
        $device
    )

    $headers = @{}
    $headers['Accept'] = ' '
    $headers['Content-Type'] = 'text/xml; charset="utf-8"'
    $headers['SOAPACTION'] = "`"urn:Belkin:service:basicevent:1#$($soapaction)`""

    #depending on device and firmware, a WeMo can listen on a number of ports
    $ports = (49152,49153,49154,49155)
    
    $timeout = 3
    
    $result = $false
    Remove-Item $env:TEMP\wemo.txt -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    foreach ($port in $ports)
    {
        try
        {
            $result = Invoke-WebRequest -Uri "http://$($device):$($port)/upnp/control/basicevent1" -Headers $headers -Method Post -Body $body -TimeoutSec $timeout -UseBasicParsing -OutFile $env:TEMP\wemo.txt
            $result = Get-Content $env:TEMP\wemo.txt
            return $result
        }
        catch
        {
        }
    }
    

}




Function Set-PowerState {
    param(
        [Parameter(Position=0)]
        [ValidateSet('on','off')]
        [System.String]$powerState,

        [Parameter(Position=1)]
        [System.String]$device
    )
    
    $powerState = $powerState.toLower()
    switch ($powerState)
    {
        "on" { $body = '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' }
        "off" { $body = '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>0</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' }
    }

    Execute-WemoCommand -body $body -soapaction 'SetBinaryState' -device $device
}

function Get-PowerState {
    param(
        [Parameter(Position=0)]
        [System.String]$device
    )

    $body = '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:GetBinaryState></s:Body></s:Envelope>'

    Execute-WemoCommand -body $body -soapaction 'GetBinaryState' -device $device
}

Get-PowerState -device netopswemo
Set-PowerState -powerState off -device netopswemo