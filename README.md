# Windows Audio Repair

> **Testing note:** This was tested by me to be working. User experience may vary.

Included script: `Repair-WindowsAudio.ps1`

```powershell
.\Repair-WindowsAudio.ps1
.\Repair-WindowsAudio.ps1 -Repair
.\Repair-WindowsAudio.ps1 -Repair -WhatIf
```

The default mode reports audio devices and service status. Repair mode requires administrator rights, restores the Audio Endpoint Builder and Windows Audio services, and verifies that they are running afterward. Drivers and device settings are not removed.

Logs: `C:\ProgramData\WindowsAudioRepair\Logs`

Exit codes: `0` success, `1` fatal error, `2` repair or verification warnings.

Use at your own risk. Audio applications may need to be reopened after service recovery.

MIT License.
