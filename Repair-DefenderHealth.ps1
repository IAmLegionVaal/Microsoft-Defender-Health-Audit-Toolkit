#requires -Version 5.1
<# Created by Dewald Pretorius. Guarded Defender signature and health-service recovery. #>
[CmdletBinding(SupportsShouldProcess=$true)]
param([ValidateSet('Diagnose','UpdateSignatures','StartHealthService')][string]$Action='Diagnose',[string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Defender_Health_Repair'))
$ErrorActionPreference='Stop';New-Item -ItemType Directory $OutputPath -Force|Out-Null;$s=Get-Date -Format yyyyMMdd_HHmmss
$before=[ordered]@{Status=(Get-MpComputerStatus|Select-Object AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,AntispywareEnabled,AntivirusSignatureVersion,AntivirusSignatureLastUpdated);Service=(Get-Service SecurityHealthService -ErrorAction SilentlyContinue|Select-Object Name,Status,StartType)};$before|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputPath "before_$s.json")
if($Action-eq'Diagnose'){exit 0}
try{if($Action-eq'UpdateSignatures'-and$PSCmdlet.ShouldProcess('Microsoft Defender signatures','Update')){Update-MpSignature}elseif($Action-eq'StartHealthService'-and$PSCmdlet.ShouldProcess('SecurityHealthService','Start if stopped')){$svc=Get-Service SecurityHealthService;if($svc.Status-eq'Stopped'){Start-Service SecurityHealthService}}}catch{Write-Error $_;exit 5}
$after=Get-MpComputerStatus;$after|Select-Object AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,AntivirusSignatureVersion,AntivirusSignatureLastUpdated|ConvertTo-Json|Set-Content (Join-Path $OutputPath "after_$s.json");if(-not$after.AntivirusEnabled){exit 6};exit 0
