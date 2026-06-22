<#
.SYNOPSIS
Reports Windows audio devices and restores stopped audio services.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param([switch]$Repair,[string]$LogRoot="$env:ProgramData\WindowsAudioRepair\Logs")

Set-StrictMode -Version 2.0
$ErrorActionPreference='Stop'
$runPath=Join-Path $LogRoot (Get-Date -Format 'yyyyMMdd_HHmmss')
$warnings=New-Object System.Collections.Generic.List[string]

function Test-Admin{
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal($id)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

try{
    if($env:OS -ne 'Windows_NT'){throw 'Windows is required.'}
    if($Repair -and -not(Test-Admin)){throw 'Run PowerShell as Administrator for repair mode.'}
    New-Item $runPath -ItemType Directory -Force|Out-Null

    if(Get-Command Get-PnpDevice -ErrorAction SilentlyContinue){
        Get-PnpDevice -ErrorAction SilentlyContinue|Where-Object{$_.Class -in 'Media','AudioEndpoint'}|
            Select-Object FriendlyName,Status,Class,InstanceId,Problem|
            Export-Csv (Join-Path $runPath 'AudioDevices.csv') -NoTypeInformation
    }else{
        $warnings.Add('PnPDevice cmdlets are unavailable.')
    }

    $serviceNames=@('AudioEndpointBuilder','Audiosrv')
    Get-Service $serviceNames -ErrorAction Stop|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'AudioServices-Before.csv') -NoTypeInformation

    if($Repair -and $PSCmdlet.ShouldProcess('Windows audio services','Set automatic start and restore services')){
        foreach($name in $serviceNames){
            Set-Service $name -StartupType Automatic -ErrorAction Stop
            $service=Get-Service $name -ErrorAction Stop
            if($service.Status -ne 'Running'){Start-Service $name -ErrorAction Stop}
        }
    }

    $after=@(Get-Service $serviceNames -ErrorAction Stop)
    $after|Select-Object Name,Status,StartType|
        Export-Csv (Join-Path $runPath 'AudioServices-After.csv') -NoTypeInformation

    if($Repair){
        foreach($service in $after){
            if($service.Status -ne 'Running'){$warnings.Add("Service $($service.Name) is not running after repair.")}
            if($service.StartType -eq 'Disabled'){$warnings.Add("Service $($service.Name) remains disabled after repair.")}
        }
    }

    $warnings|Out-File (Join-Path $runPath 'Warnings.txt') -Encoding UTF8
    if($warnings.Count -gt 0){Write-Host "[WARN] Completed with warnings. Logs: $runPath" -ForegroundColor Yellow;exit 2}
    Write-Host "[OK] Completed. Logs: $runPath" -ForegroundColor Green
    exit 0
}catch{Write-Error $_.Exception.Message;exit 1}
