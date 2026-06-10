# Sync assetlib/p2p_net -> local godot-p2p-net repo (no git push until Tom approves).
param(
    [string]$DestRepo = "C:\Users\tom\Documents\macgyver\tananananana\godot-p2p-net"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$Src = Join-Path $ProjectRoot "assetlib\p2p_net"

& (Join-Path $PSScriptRoot "export_p2p_assetlib.ps1")

if (-not (Test-Path $Src)) {
    Write-Error "Missing $Src - run export_p2p_assetlib.ps1 first."
}

if (-not (Test-Path $DestRepo)) {
    Write-Host "Creating $DestRepo"
    New-Item -ItemType Directory -Force -Path $DestRepo | Out-Null
}

$Preserve = @(".git", ".gitattributes")
Get-ChildItem $DestRepo -Force | Where-Object { $Preserve -notcontains $_.Name } | Remove-Item -Recurse -Force
Copy-Item -Path (Join-Path $Src "*") -Destination $DestRepo -Recurse -Force

Write-Host "Synced to $DestRepo"
Write-Host "NOT pushed - run git commit/push only after Tom approves publication."
