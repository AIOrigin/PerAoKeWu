# Sync opening comic panels (p1.png – p8.png) from Desktop source into this folder.
$ErrorActionPreference = "Stop"
$dest = $PSScriptRoot
$src = Join-Path $env:USERPROFILE "Desktop\星火信使\开场剧情漫画"
if (-not (Test-Path -LiteralPath $src)) {
    Write-Host "Source not found: $src"
    exit 1
}
1..8 | ForEach-Object {
    $name = "p$_.png"
    Copy-Item -LiteralPath (Join-Path $src $name) -Destination (Join-Path $dest $name) -Force
    Write-Host "Copied $name"
}
Write-Host "Done."
