# ForcesNet E2E — full match flow (match_start + orders + state sync) for 2 or 4 players.
param(
    [ValidateSet("2", "4")]
    [string]$Players = "2"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
Set-Location $ProjectRoot

function Find-Godot {
    $envFile = Join-Path $PSScriptRoot "godot.env"
    if (Test-Path $envFile) {
        foreach ($line in Get-Content $envFile) {
            if ($line -match '^\s*GODOT_BIN\s*=\s*(.+)\s*$') {
                $p = $Matches[1].Trim()
                if (Test-Path $p) { return $p }
            }
        }
    }
    if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) { return $env:GODOT_BIN }
    $candidates = @(
        "$env:USERPROFILE\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe",
        "$env:USERPROFILE\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe"
    )
    foreach ($p in $candidates) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

$godot = Find-Godot
if (-not $godot) { Write-Error "Godot not found" }

$dll = Join-Path $ProjectRoot "webrtc\lib\libwebrtc_native.windows.template_debug.x86_64.dll"
if (-not (Test-Path $dll)) {
    & (Join-Path $PSScriptRoot "setup_webrtc.ps1")
}

$playerCount = [int]$Players
$joinCount = $playerCount - 1
$baseArgs = @("--headless", "--path", $ProjectRoot)
$e2eScene = "res://scenes/tests/forces_net_e2e_test.tscn"
$sigScene = "res://addons/p2p_net/server/signaling_server.tscn"
$roomFile = Join-Path $env:TEMP "forces_net_e2e_room.txt"
Remove-Item $roomFile -ErrorAction SilentlyContinue

Write-Host "ForcesNet E2E: $playerCount players"

$signaling = Start-Process -FilePath $godot -ArgumentList ($baseArgs + $sigScene) -PassThru -NoNewWindow
Start-Sleep -Seconds 2

$env:FORCES_NET_E2E = "host"
$env:FORCES_NET_PLAYERS = "$playerCount"
$env:FORCES_NET_ROOM_FILE = $roomFile
Remove-Item Env:FORCES_NET_ROOM -ErrorAction SilentlyContinue

$hostProc = Start-Process -FilePath $godot -ArgumentList ($baseArgs + $e2eScene) -PassThru -NoNewWindow

$deadline = (Get-Date).AddSeconds(25)
$code = ""
while ((Get-Date) -lt $deadline) {
    if (Test-Path $roomFile) {
        $code = (Get-Content $roomFile -Raw).Trim()
        if ($code.Length -ge 8) { break }
    }
    Start-Sleep -Milliseconds 300
}
if ($code -eq "") {
    Stop-Process -Id $signaling.Id -Force -ErrorAction SilentlyContinue
    Stop-Process -Id $hostProc.Id -Force -ErrorAction SilentlyContinue
    Write-Error "No room code from host"
}

Write-Host "Room: $code"
Start-Sleep -Seconds 2

$env:FORCES_NET_E2E = "join"
$env:FORCES_NET_PLAYERS = "$playerCount"
$env:FORCES_NET_ROOM = $code
Remove-Item Env:FORCES_NET_ROOM_FILE -ErrorAction SilentlyContinue

$joinProcs = @()
for ($i = 0; $i -lt $joinCount; $i++) {
    Start-Sleep -Seconds 1
    $joinProcs += Start-Process -FilePath $godot -ArgumentList ($baseArgs + $e2eScene) -PassThru -NoNewWindow
}

Wait-Process -Id $hostProc.Id -Timeout 60 -ErrorAction SilentlyContinue
foreach ($jp in $joinProcs) {
    Wait-Process -Id $jp.Id -Timeout 60 -ErrorAction SilentlyContinue
}

Stop-Process -Id $signaling.Id -Force -ErrorAction SilentlyContinue
if (-not $hostProc.HasExited) { Stop-Process -Id $hostProc.Id -Force -ErrorAction SilentlyContinue }
foreach ($jp in $joinProcs) {
    if (-not $jp.HasExited) { Stop-Process -Id $jp.Id -Force -ErrorAction SilentlyContinue }
}

Remove-Item Env:FORCES_NET_E2E, Env:FORCES_NET_PLAYERS, Env:FORCES_NET_ROOM, Env:FORCES_NET_ROOM_FILE -ErrorAction SilentlyContinue

$hostExit = if ($hostProc.HasExited) { [int]$hostProc.ExitCode } else { 1 }
$joinFails = @()
foreach ($jp in $joinProcs) {
    $jexit = if ($jp.HasExited) { [int]$jp.ExitCode } else { 1 }
    if ($jexit -ne 0) { $joinFails += $jexit }
}

if ($hostExit -ne 0 -or $joinFails.Count -gt 0) {
    Write-Error "[ForcesNet e2e ${playerCount}p] FAIL host=$hostExit joins=$($joinFails -join ',')"
}

Write-Host "[ForcesNet e2e ${playerCount}p] OK"
exit 0
