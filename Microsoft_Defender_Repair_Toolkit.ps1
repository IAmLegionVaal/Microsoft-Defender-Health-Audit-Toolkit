[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
 [switch]$EnableRealTimeProtection,
 [switch]$UpdateSignatures,
 [ValidateSet('Quick','Full','Custom')][string]$ScanType,
 [string]$CustomScanPath,
 [switch]$StartDefenderServices,
 [switch]$DryRun,
 [switch]$Yes,
 [string]$OutputPath=(Join-Path $env:ProgramData 'MicrosoftDefenderRepair')
)
$ErrorActionPreference='Stop';$script:Failures=0;$script:Actions=0
$run=Join-Path $OutputPath (Get-Date -Format yyyyMMdd_HHmmss);New-Item -ItemType Directory $run -Force|Out-Null
$log=Join-Path $run 'repair.log';$before=Join-Path $run 'before.json';$after=Join-Path $run 'after.json'
function Log($m){"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $m"|Tee-Object -FilePath $log -Append}
function Admin{$p=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent());$p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
function State{[pscustomobject]@{Collected=Get-Date;Status=Get-MpComputerStatus|Select-Object AntivirusEnabled,AntispywareEnabled,RealTimeProtectionEnabled,BehaviorMonitorEnabled,IoavProtectionEnabled,AntivirusSignatureVersion,AntivirusSignatureLastUpdated,QuickScanAge,FullScanAge;Preferences=Get-MpPreference|Select-Object DisableRealtimeMonitoring,DisableBehaviorMonitoring,PUAProtection;Services=Get-Service WinDefend,WdNisSvc,SecurityHealthService -ErrorAction SilentlyContinue|Select-Object Name,Status,StartType}}
function Act($d,[scriptblock]$a){$script:Actions++;Log $d;if($DryRun){Log "DRY-RUN: $d";return};try{&$a;Log "SUCCESS: $d"}catch{$script:Failures++;Log "FAILED: $d - $($_.Exception.Message)"}}
State|ConvertTo-Json -Depth 6|Set-Content $before -Encoding UTF8
if(-not($EnableRealTimeProtection -or $UpdateSignatures -or $ScanType -or $StartDefenderServices)){Write-Error 'Choose at least one repair action.';exit 2}
if($ScanType -eq 'Custom' -and -not(Test-Path $CustomScanPath)){Write-Error 'A valid -CustomScanPath is required.';exit 2}
if(-not $DryRun -and -not(Admin)){Write-Error 'Run from elevated PowerShell.';exit 4}
if(-not $Yes -and -not $DryRun){if((Read-Host 'Apply selected Microsoft Defender repairs? Type YES') -ne 'YES'){Log 'Cancelled.';exit 10}}
if($StartDefenderServices){foreach($s in 'WinDefend','WdNisSvc','SecurityHealthService'){if(Get-Service $s -ErrorAction SilentlyContinue){Act "Starting $s" {Start-Service $s -ErrorAction Stop}}}}
if($EnableRealTimeProtection){Act 'Enabling Defender real-time and behavior monitoring' {Set-MpPreference -DisableRealtimeMonitoring $false -DisableBehaviorMonitoring $false -DisableIOAVProtection $false}}
if($UpdateSignatures){Act 'Updating Defender signatures' {Update-MpSignature}}
if($ScanType){switch($ScanType){Quick{Act 'Starting Defender quick scan' {Start-MpScan -ScanType QuickScan}}Full{Act 'Starting Defender full scan' {Start-MpScan -ScanType FullScan}}Custom{Act "Starting Defender custom scan on $CustomScanPath" {Start-MpScan -ScanType CustomScan -ScanPath $CustomScanPath}}}}
Start-Sleep 2;State|ConvertTo-Json -Depth 6|Set-Content $after -Encoding UTF8
if($script:Failures){exit 20};Log "Repair completed. Actions: $script:Actions";exit 0
