# Windows Audio Repair

> **Testing note:** This was tested by me to be working. User experience may vary.

## One-click use

1. Download and extract the repository.
2. Double-click `Run-OneClick.bat`.
3. Approve the Windows administrator prompt.
4. The launcher restores and verifies the Windows audio services directly—there is no menu.
5. Review the exit code and logs in `C:\ProgramData\WindowsAudioRepair\Logs`.

Included script: `Repair-WindowsAudio.ps1`

## PowerShell usage

```powershell
.\Repair-WindowsAudio.ps1
.\Repair-WindowsAudio.ps1 -Repair
.\Repair-WindowsAudio.ps1 -Repair -WhatIf
```

The default mode reports audio devices and service status. Repair mode restores the Audio Endpoint Builder and Windows Audio services and verifies that they are running afterward. Drivers and device settings are not removed.

Exit codes: `0` success, `1` fatal error, `2` repair or verification warnings.

Audio applications may need to be reopened after service recovery. MIT License.
