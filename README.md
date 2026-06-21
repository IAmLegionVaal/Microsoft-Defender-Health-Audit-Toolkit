# Microsoft Defender Health Audit Toolkit

PowerShell tools for Microsoft Defender configuration, signature and health auditing plus guarded repair actions.

## Audit

Use the repository's Defender health audit script to collect configuration and signature evidence.

## Repair

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Microsoft_Defender_Repair_Toolkit.ps1 -UpdateSignatures -DryRun
```

Examples:

```powershell
.\Microsoft_Defender_Repair_Toolkit.ps1 -EnableRealTimeProtection
.\Microsoft_Defender_Repair_Toolkit.ps1 -UpdateSignatures
.\Microsoft_Defender_Repair_Toolkit.ps1 -ScanType Quick
.\Microsoft_Defender_Repair_Toolkit.ps1 -ScanType Full
.\Microsoft_Defender_Repair_Toolkit.ps1 -ScanType Custom -CustomScanPath C:\Temp
.\Microsoft_Defender_Repair_Toolkit.ps1 -StartDefenderServices
```

The repair workflow captures Defender status, preferences and service state before and after changes. It supports `-DryRun`, confirmation, logs and clear exit codes. Custom scans require an existing path and no exclusions are changed automatically.

## Author

Dewald Pretorius — L2 IT Support Engineer
