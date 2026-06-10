# Sync addons/p2p_net into assetlib/p2p_net/addons/p2p_net for GitHub / Asset Library publish.
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$Src = Join-Path $ProjectRoot "addons\p2p_net"
$DstRoot = Join-Path $ProjectRoot "assetlib\p2p_net"
$Dst = Join-Path $DstRoot "addons\p2p_net"

if (-not (Test-Path $Src)) {
    Write-Error "Source addon not found: $Src"
}

New-Item -ItemType Directory -Force -Path $Dst | Out-Null
Get-ChildItem $Dst -Force | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $Src "*") -Destination $Dst -Recurse -Force

$iconSrc = Join-Path $DstRoot "icon.png"
if (-not (Test-Path $iconSrc)) {
    Write-Warning "Missing $iconSrc - add a 128x128 square icon before Asset Library submit."
}

Write-Host "Exported addon to $Dst"
Write-Host "Publish repo root: $DstRoot"
Write-Host "Next: cd assetlib/p2p_net; git init; git remote add origin YOUR_GITHUB_REPO_URL"
