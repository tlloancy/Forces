# P2PNet smoke - signaling server + host + join (2 clients WebRTC)
param(
    [int]$SignalingPort = 8080
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
if (-not $godot) {
    Write-Error "Godot not found. Set GODOT_BIN or tools/godot.env"
}

$dll = Join-Path $ProjectRoot "webrtc\lib\libwebrtc_native.windows.template_debug.x86_64.dll"
if (-not (Test-Path $dll)) {
    & (Join-Path $PSScriptRoot "setup_webrtc.ps1")
    if (-not (Test-Path $dll)) {
        Write-Error "webrtc-native Windows DLL missing in webrtc/lib/"
    }
}

$roomFile = Join-Path $env:TEMP "forces_p2p_smoke_room.txt"
Remove-Item $roomFile -ErrorAction SilentlyContinue

Write-Host "Godot: $godot"

$sceneArgs = @("--headless", "--path", $ProjectRoot)
$smokeScene = "res://addons/p2p_net/test/net_smoke_test.tscn"
$sigScene = "res://addons/p2p_net/server/signaling_server.tscn"

$signaling = Start-Process -FilePath $godot -ArgumentList ($sceneArgs + $sigScene) -PassThru -NoNewWindow `
    -RedirectStandardOutput "$env:TEMP\p2p_sig_out.txt" -RedirectStandardError "$env:TEMP\p2p_sig_err.txt"
Start-Sleep -Seconds 2

$savedMode = $env:P2P_NET_MODE
$savedRoom = $env:P2P_NET_ROOM
$savedFile = $env:P2P_NET_ROOM_FILE

$env:P2P_NET_MODE = "host"
$env:P2P_NET_ROOM_FILE = $roomFile
Remove-Item Env:P2P_NET_ROOM -ErrorAction SilentlyContinue

Write-Host "Starting host..."
$hostProc = Start-Process -FilePath $godot -ArgumentList ($sceneArgs + $smokeScene) -PassThru -NoNewWindow `
    -RedirectStandardOutput "$env:TEMP\p2p_host_out.txt" -RedirectStandardError "$env:TEMP\p2p_host_err.txt"

$deadline = (Get-Date).AddSeconds(20)
$code = ""
while ((Get-Date) -lt $deadline) {
    if (Test-Path $roomFile) {
        $code = (Get-Content $roomFile -Raw).Trim()
        if ($code.Length -ge 8) { break }
    }
    Start-Sleep -Milliseconds 300
}

if ($code -eq "") {
    Write-Host "--- host stdout ---"
    Get-Content "$env:TEMP\p2p_host_out.txt" -ErrorAction SilentlyContinue
    Write-Host "--- host stderr ---"
    Get-Content "$env:TEMP\p2p_host_err.txt" -ErrorAction SilentlyContinue
    Stop-Process -Id $signaling.Id -Force -ErrorAction SilentlyContinue
    Stop-Process -Id $hostProc.Id -Force -ErrorAction SilentlyContinue
    Write-Error "No room code from host"
}

Write-Host "Room: $code"
Start-Sleep -Seconds 1

$env:P2P_NET_MODE = "join"
$env:P2P_NET_ROOM = $code
Remove-Item Env:P2P_NET_ROOM_FILE -ErrorAction SilentlyContinue

Write-Host "Starting join..."
$joinProc = Start-Process -FilePath $godot -Wait -PassThru -NoNewWindow -ArgumentList ($sceneArgs + $smokeScene) `
    -RedirectStandardOutput "$env:TEMP\p2p_join_out.txt" -RedirectStandardError "$env:TEMP\p2p_join_err.txt"

Start-Sleep -Seconds 2
if (-not $hostProc.HasExited) {
    Wait-Process -Id $hostProc.Id -Timeout 20
}

Stop-Process -Id $signaling.Id -Force -ErrorAction SilentlyContinue
if (-not $hostProc.HasExited) { Stop-Process -Id $hostProc.Id -Force -ErrorAction SilentlyContinue }

if ($savedMode) { $env:P2P_NET_MODE = $savedMode } else { Remove-Item Env:P2P_NET_MODE -ErrorAction SilentlyContinue }
if ($savedRoom) { $env:P2P_NET_ROOM = $savedRoom } else { Remove-Item Env:P2P_NET_ROOM -ErrorAction SilentlyContinue }
if ($savedFile) { $env:P2P_NET_ROOM_FILE = $savedFile } else { Remove-Item Env:P2P_NET_ROOM_FILE -ErrorAction SilentlyContinue }

Write-Host "--- join stdout ---"
Get-Content "$env:TEMP\p2p_join_out.txt" -ErrorAction SilentlyContinue
Write-Host "--- join stderr ---"
Get-Content "$env:TEMP\p2p_join_err.txt" -ErrorAction SilentlyContinue

$hostExit = if ($hostProc.HasExited) { [int]$hostProc.ExitCode } else { 1 }
$joinExit = [int]$joinProc.ExitCode

if ($hostExit -ne 0 -or $joinExit -ne 0) {
    Write-Host "--- host stdout ---"
    Get-Content "$env:TEMP\p2p_host_out.txt" -ErrorAction SilentlyContinue
    Write-Host "--- host stderr ---"
    Get-Content "$env:TEMP\p2p_host_err.txt" -ErrorAction SilentlyContinue
    Write-Error "[P2PNet smoke] FAIL host=$hostExit join=$joinExit"
}

Write-Host "[P2PNet smoke] OK"
exit 0
