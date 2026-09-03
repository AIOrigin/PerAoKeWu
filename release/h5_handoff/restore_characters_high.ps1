#Requires -Version 5.1
<#
.SYNOPSIS
  Restore original character GLBs from high-poly backup (local high quality).

.DESCRIPTION
  Backup: release/h5_handoff/_characters_high_backup/
  (mirrors assets/maps/route_levels/...)

  From repo root:
    powershell -ExecutionPolicy Bypass -File .\release\h5_handoff\restore_characters_high.ps1
#>

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
$Backup = Join-Path $ScriptDir "_characters_high_backup"
$Route = Join-Path $RepoRoot "assets\maps\route_levels"

if (-not (Test-Path -LiteralPath $Backup)) {
	throw "Backup not found: $Backup"
}

$restored = 0
Get-ChildItem -LiteralPath $Backup -Recurse -Filter *.glb | ForEach-Object {
	$rel = $_.FullName.Substring($Backup.Length).TrimStart('\', '/')
	$dest = Join-Path $Route $rel
	$destDir = Split-Path -Parent $dest
	if (-not (Test-Path -LiteralPath $destDir)) {
		Write-Host "SKIP (no folder): $rel"
		return
	}
	Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
	$restored++
	Write-Host "Restored $rel"
}

Write-Host ""
Write-Host "Done. Restored $restored file(s)."
Write-Host "Local characters are HIGH quality again."
Write-Host "Re-run character optimize + H5 export before next shipping build."
