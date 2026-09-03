#Requires -Version 5.1
# Restore mobile_home UI PNGs from high backup (after compress_mobile_ui_pngs.py).
$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$Backup = Join-Path $PSScriptRoot "_ui_png_high_backup"
$Dest = Join-Path $Root "assets\maps\route_levels\mobile_home"
if (-not (Test-Path -LiteralPath $Backup)) { throw "Missing backup: $Backup" }
$n = 0
Get-ChildItem -LiteralPath $Backup -Recurse -File -Filter *.png | ForEach-Object {
	$rel = $_.FullName.Substring($Backup.Length).TrimStart('\','/')
	$out = Join-Path $Dest $rel
	New-Item -ItemType Directory -Force -Path (Split-Path $out) | Out-Null
	Copy-Item -LiteralPath $_.FullName -Destination $out -Force
	$n++
}
Write-Host "Restored $n UI PNGs to mobile_home"
