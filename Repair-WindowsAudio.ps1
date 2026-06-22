<#
.SYNOPSIS
Reports Windows audio devices and restores stopped audio services.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param([switch]$Repair,[string]$LogRoot="$env:ProgramData\WindowsAudioRepair\Logs")

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $LogRoot (Get-Date -Format 'yyyyMMdd_HHmmss')

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    if(Get-Command Get-PnpDevice -ErrorAction SilentlyContinue){
        Get-PnpDevice -ErrorAction SilentlyContinue|Where-Object{$_.Class -in 'Media','AudioEndpoint'}|
            Select-Object FriendlyName,Status,Class,InstanceId,Problem|
            Export-Csv (Join-Path $runPath 'AudioDevices.csv') -NoTypeInformation
    }

    $services=Get-Service Audiosrv,AudioEndpointBuilder -ErrorAction Stop
    $services|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'AudioServices-Before.csv') -NoTypeInformation

    if($Repair -and $PSCmdlet.ShouldProcess('Stopped Windows audio services','Start services')){
        $services|Where-Object Status -ne 'Running'|ForEach-Object{Start-Service $_.Name}
    }

    Get-Service Audiosrv,AudioEndpointBuilder|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'AudioServices-After.csv') -NoTypeInformation
    Write-Host "[OK] Completed. Logs: $runPath" -ForegroundColor Green
    exit 0
}catch{Write-Error $_.Exception.Message;exit 1}
