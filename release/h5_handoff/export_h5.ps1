#Requires -Version 5.1
<#
.SYNOPSIS
  Export Ember Runner as Godot Web/H5 and zip for handoff.

.DESCRIPTION
  Requires Godot 4.4.x + export templates (web_*).
  Run from repo root:
    powershell -ExecutionPolicy Bypass -File .\release\h5_handoff\export_h5.ps1
#>

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..")).Path
$OutDir = $ScriptDir
$BuildDir = Join-Path $OutDir "build"
$Stamp = Get-Date -Format "yyyyMMdd"
$ZipPath = Join-Path $OutDir ("EmberRunner_H5_{0}.zip" -f $Stamp)
$PresetExample = Join-Path $OutDir "export_presets.web.example.cfg"
$PresetCfg = Join-Path $RepoRoot "export_presets.cfg"

$Godot = $null
$godotDirs = Get-ChildItem (Join-Path $env:USERPROFILE "Downloads") -Directory -Filter "Godot_v4.4*" -ErrorAction SilentlyContinue
foreach ($dir in $godotDirs) {
	# Prefer console build for headless CLI (GUI exe may return immediately)
	$console = Get-ChildItem $dir.FullName -Filter "Godot_v4.4*_win64_console.exe" -ErrorAction SilentlyContinue |
		Select-Object -First 1
	if ($console) {
		$Godot = $console.FullName
		break
	}
	$exe = Get-ChildItem $dir.FullName -Filter "Godot_v4.4*_win64.exe" -ErrorAction SilentlyContinue |
		Where-Object { $_.Name -notmatch "console" } |
		Select-Object -First 1
	if ($exe) {
		$Godot = $exe.FullName
		break
	}
}
if (-not $Godot) {
	$cmd = Get-Command godot -ErrorAction SilentlyContinue
	if ($cmd) { $Godot = $cmd.Source }
}
if (-not $Godot -or -not (Test-Path -LiteralPath $Godot)) {
	throw "Godot 4.4.x not found under Downloads. Install Godot 4.4.1 stable win64."
}

$Tpl = Join-Path $env:APPDATA "Godot\export_templates\4.4.1.stable"
$hasWeb = (Test-Path (Join-Path $Tpl "web_release.zip")) -or (Test-Path (Join-Path $Tpl "web_nothreads_release.zip"))
if (-not $hasWeb) {
	throw "Missing Web export templates under $Tpl"
}

Write-Host "Godot : $Godot"
Write-Host "Repo  : $RepoRoot"
Write-Host "Build : $BuildDir"

# Ensure export_presets.cfg has Web preset (do not clobber unrelated presets if present)
if (-not (Test-Path $PresetCfg)) {
	Copy-Item -LiteralPath $PresetExample -Destination $PresetCfg -Force
	Write-Host "Created export_presets.cfg from web example"
}
else {
	$cfgText = Get-Content -LiteralPath $PresetCfg -Raw -Encoding UTF8
	if ($cfgText -notmatch 'platform="Web"') {
		# Append web preset as next index
		$idxs = [regex]::Matches($cfgText, '\[preset\.(\d+)\]') | ForEach-Object { [int]$_.Groups[1].Value }
		$next = if ($idxs.Count -gt 0) { ($idxs | Measure-Object -Maximum).Maximum + 1 } else { 0 }
		$web = Get-Content -LiteralPath $PresetExample -Raw -Encoding UTF8
		$web = $web -replace '\[preset\.0\]', "[preset.$next]"
		$web = $web -replace '\[preset\.0\.options\]', "[preset.$next.options]"
		# strip comment header lines starting with ;
		Add-Content -LiteralPath $PresetCfg -Value "`r`n$web" -Encoding UTF8
		Write-Host "Appended Web preset as preset.$next"
	}
}

if (Test-Path $BuildDir) {
	Remove-Item -LiteralPath $BuildDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
$IndexHtml = Join-Path $BuildDir "index.html"

Write-Host "Exporting Web (this can take several minutes)..."
$IndexHtmlAbs = [System.IO.Path]::GetFullPath((Join-Path $BuildDir "index.html"))
$exportTarget = $IndexHtmlAbs
$godotLog = Join-Path $OutDir "export_godot_log.txt"
$errLog = Join-Path $OutDir "export_godot_err.txt"
# Quote paths that contain spaces (folder name has " - ")
$argLine = @(
	"--headless",
	"--path", "`"$RepoRoot`"",
	"--export-release", "Web",
	"`"$exportTarget`""
) -join " "

Push-Location $RepoRoot
try {
	# Avoid PowerShell treating Godot stderr "ERROR:" lines as terminating
	$prevEap = $ErrorActionPreference
	$ErrorActionPreference = "Continue"
	$cmd = "`"$Godot`" $argLine"
	Write-Host "CMD: $cmd"
	cmd.exe /c "$cmd > `"$godotLog`" 2> `"$errLog`""
	$code = $LASTEXITCODE
	$ErrorActionPreference = $prevEap
}
finally {
	Pop-Location
}

if ($null -eq $code) { $code = -1 }
if ($code -ne 0) {
	Write-Host "---- godot log (tail) ----"
	if (Test-Path $godotLog) { Get-Content -LiteralPath $godotLog -Tail 60 }
	if (Test-Path $errLog) {
		Write-Host "---- godot err (tail) ----"
		Get-Content -LiteralPath $errLog -Tail 60
	}
	throw "Godot export failed with exit $code"
}
if (-not (Test-Path -LiteralPath $IndexHtmlAbs)) {
	throw "Export finished but index.html missing: $IndexHtmlAbs"
}

# Copy handoff docs into build parent zip root
$StageRoot = Join-Path $env:TEMP ("EmberRunner_H5_pack_" + [guid]::NewGuid().ToString("N"))
$Stage = Join-Path $StageRoot "EmberRunner_H5"
New-Item -ItemType Directory -Force -Path $Stage | Out-Null
Copy-Item -LiteralPath $BuildDir -Destination (Join-Path $Stage "build") -Recurse -Force
foreach ($doc in @("HANDOFF_H5.md", "CHECKLIST_H5.md", "export_presets.web.example.cfg", "export_h5.ps1")) {
	$src = Join-Path $OutDir $doc
	if (Test-Path $src) {
		Copy-Item -LiteralPath $src -Destination (Join-Path $Stage $doc) -Force
	}
}
@"
# Ember Runner H5

1. Read HANDOFF_H5.md
2. Mount build/ (entry: build/index.html) in your iOS shell WebView
3. Controls: swipe L/R lanes, swipe up jump, swipe down slide

Pack date: $Stamp
"@ | Set-Content -LiteralPath (Join-Path $Stage "00_READ_ME_FIRST.md") -Encoding UTF8

if (Test-Path $ZipPath) {
	Remove-Item -LiteralPath $ZipPath -Force
}
Push-Location $StageRoot
try {
	& tar -a -c -f $ZipPath "EmberRunner_H5"
	if ($LASTEXITCODE -ne 0) { throw "zip failed" }
}
finally {
	Pop-Location
}
Remove-Item -LiteralPath $StageRoot -Recurse -Force -ErrorAction SilentlyContinue

$mb = [math]::Round((Get-Item $ZipPath).Length / 1MB, 1)
Write-Host ""
Write-Host "DONE: $ZipPath"
Write-Host ("SIZE: {0} MB" -f $mb)
Write-Host "Build folder: $BuildDir"
