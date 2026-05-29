# P2PNet V1 test suite — import, smoke 2p, mesh 4p, negative cases
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

function Invoke-GodotWait {
    param([string[]]$GodotArgs)
    $p = Start-Process -FilePath $godot -ArgumentList $GodotArgs -Wait -PassThru -NoNewWindow
    return [int]$p.ExitCode
}

function Start-Signaling {
    $sigScene = "res://addons/p2p_net/server/signaling_server.tscn"
    return Start-Process -FilePath $godot -ArgumentList (@("--headless", "--path", $ProjectRoot) + $sigScene) `
        -PassThru -NoNewWindow
}

function Stop-Signaling {
    param($Proc)
    if ($Proc -and -not $Proc.HasExited) {
        Stop-Process -Id $Proc.Id -Force -ErrorAction SilentlyContinue
    }
}

$godot = Find-Godot
if (-not $godot) { Write-Error "Godot not found. Set GODOT_BIN or tools/godot.env" }

$dll = Join-Path $ProjectRoot "webrtc\lib\libwebrtc_native.windows.template_debug.x86_64.dll"
if (-not (Test-Path $dll)) {
    Write-Error "webrtc-native DLL missing in webrtc/lib/"
}

$baseArgs = @("--headless", "--path", $ProjectRoot)
Write-Host "Godot: $godot"
Write-Host "Import GDExtension..."
$importExit = Invoke-GodotWait ($baseArgs + @("--import", "--quit"))
if ($importExit -ne 0) { Write-Error "Import failed exit=$importExit" }

$failures = @()

Write-Host "`n=== invalid_room ==="
$sig = Start-Signaling
Start-Sleep -Seconds 2
$env:P2P_NET_TEST = "invalid_room"
Remove-Item Env:P2P_NET_MODE, Env:P2P_NET_ROOM, Env:P2P_NET_ROOM_FILE, Env:P2P_NET_MAX_PEERS -ErrorAction SilentlyContinue
$code = Invoke-GodotWait ($baseArgs + @("res://addons/p2p_net/test/net_negative_test.tscn"))
Stop-Signaling $sig
if ($code -ne 0) { $failures += "invalid_room exit=$code" } else { Write-Host "OK invalid_room" }

Write-Host "`n=== smoke 2 players ==="
& (Join-Path $PSScriptRoot "run_p2p_smoke.ps1") -SignalingPort $SignalingPort
if ($LASTEXITCODE -ne 0) { $failures += "smoke exit=$LASTEXITCODE" }

Write-Host "`n=== room_full (max_peers=2) ==="
$sig = Start-Signaling
Start-Sleep -Seconds 2
$roomFile = Join-Path $env:TEMP "forces_p2p_full_room.txt"
Remove-Item $roomFile -ErrorAction SilentlyContinue
$env:P2P_NET_MODE = "host"
$env:P2P_NET_MAX_PEERS = "2"
$env:P2P_NET_ROOM_FILE = $roomFile
Remove-Item Env:P2P_NET_TEST, Env:P2P_NET_ROOM -ErrorAction SilentlyContinue
$hostFull = Start-Process -FilePath $godot -ArgumentList ($baseArgs + @("res://addons/p2p_net/test/net_smoke_test.tscn")) `
    -PassThru -NoNewWindow
$deadline = (Get-Date).AddSeconds(15)
$fullCode = ""
while ((Get-Date) -lt $deadline) {
    if (Test-Path $roomFile) {
        $fullCode = (Get-Content $roomFile -Raw).Trim()
        if ($fullCode.Length -ge 8) { break }
    }
    Start-Sleep -Milliseconds 200
}
if ($fullCode -eq "") {
    $failures += "room_full: no room code"
} else {
    $env:P2P_NET_MODE = "join"
    $env:P2P_NET_ROOM = $fullCode
    Remove-Item Env:P2P_NET_ROOM_FILE -ErrorAction SilentlyContinue
    $j1 = Invoke-GodotWait ($baseArgs + @("res://addons/p2p_net/test/net_smoke_test.tscn"))
    if ($j1 -ne 0) { $failures += "room_full join1 exit=$j1" }
    if (-not $hostFull.HasExited) { Wait-Process -Id $hostFull.Id -Timeout 15 -ErrorAction SilentlyContinue }
    Stop-Process -Id $hostFull.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    $env:P2P_NET_TEST = "room_full"
    $env:P2P_NET_ROOM = $fullCode
    Remove-Item Env:P2P_NET_MODE, Env:P2P_NET_ROOM_FILE, Env:P2P_NET_MAX_PEERS -ErrorAction SilentlyContinue
    $j2 = Invoke-GodotWait ($baseArgs + @("res://addons/p2p_net/test/net_negative_test.tscn"))
    if ($j2 -ne 0) { $failures += "room_full join2 expected fail exit=$j2" } else { Write-Host "OK room_full" }
}
Stop-Process -Id $hostFull.Id -Force -ErrorAction SilentlyContinue
Stop-Signaling $sig

Write-Host "`n=== mesh 4 players ==="
$sig = Start-Signaling
Start-Sleep -Seconds 2
$meshRoom = Join-Path $env:TEMP "forces_p2p_mesh_room.txt"
Remove-Item $meshRoom -ErrorAction SilentlyContinue
$env:P2P_NET_MODE = "host"
$env:P2P_NET_MAX_PEERS = "4"
$env:P2P_NET_ROOM_FILE = $meshRoom
Remove-Item Env:P2P_NET_TEST, Env:P2P_NET_ROOM -ErrorAction SilentlyContinue
$meshHost = Start-Process -FilePath $godot -ArgumentList ($baseArgs + @("res://addons/p2p_net/test/net_mesh_test.tscn")) `
    -PassThru -NoNewWindow
$deadline = (Get-Date).AddSeconds(20)
$meshCode = ""
while ((Get-Date) -lt $deadline) {
    if (Test-Path $meshRoom) {
        $meshCode = (Get-Content $meshRoom -Raw).Trim()
        if ($meshCode.Length -ge 8) { break }
    }
    Start-Sleep -Milliseconds 200
}
if ($meshCode -eq "") {
    $failures += "mesh: no room code"
} else {
    $env:P2P_NET_MODE = "join"
    $env:P2P_NET_ROOM = $meshCode
    $env:P2P_NET_MAX_PEERS = "4"
    Remove-Item Env:P2P_NET_ROOM_FILE, Env:P2P_NET_TEST -ErrorAction SilentlyContinue
    $joinProcs = @()
    for ($i = 0; $i -lt 3; $i++) {
        Start-Sleep -Seconds 1
        $joinProcs += Start-Process -FilePath $godot -ArgumentList ($baseArgs + @("res://addons/p2p_net/test/net_mesh_test.tscn")) `
            -PassThru -NoNewWindow
    }
    Wait-Process -Id $meshHost.Id -Timeout 45 -ErrorAction SilentlyContinue
    foreach ($jp in $joinProcs) {
        Wait-Process -Id $jp.Id -Timeout 45 -ErrorAction SilentlyContinue
    }
    $meshHostExit = if ($meshHost.HasExited) { [int]$meshHost.ExitCode } else { 1 }
    $meshJoinFails = @()
    foreach ($jp in $joinProcs) {
        if (-not $jp.HasExited) { Stop-Process -Id $jp.Id -Force -ErrorAction SilentlyContinue }
        $jexit = if ($jp.HasExited) { [int]$jp.ExitCode } else { 1 }
        if ($jexit -ne 0) { $meshJoinFails += $jexit }
    }
    if (-not $meshHost.HasExited) { Stop-Process -Id $meshHost.Id -Force -ErrorAction SilentlyContinue }
    if ($meshHostExit -ne 0 -or $meshJoinFails.Count -gt 0) {
        $failures += "mesh host=$meshHostExit joins=$($meshJoinFails -join ',')"
    } else {
        Write-Host "OK mesh 4p"
    }
}
Stop-Signaling $sig

Write-Host "`n=== seal_lobby ==="
$sig = Start-Signaling
Start-Sleep -Seconds 2
$sealRoom = Join-Path $env:TEMP "forces_p2p_seal_room.txt"
Remove-Item $sealRoom -ErrorAction SilentlyContinue
$env:P2P_NET_TEST = "seal"
$env:P2P_NET_MODE = "host"
$env:P2P_NET_ROOM_FILE = $sealRoom
Remove-Item Env:P2P_NET_ROOM, Env:P2P_NET_MAX_PEERS -ErrorAction SilentlyContinue
$sealHost = Start-Process -FilePath $godot -ArgumentList ($baseArgs + @("res://addons/p2p_net/test/net_negative_test.tscn")) `
    -PassThru -NoNewWindow
Wait-Process -Id $sealHost.Id -Timeout 20 -ErrorAction SilentlyContinue
$sealHostExit = if ($sealHost.HasExited) { [int]$sealHost.ExitCode } else { 1 }
Stop-Signaling $sig
if ($sealHostExit -ne 0) { $failures += "seal exit=$sealHostExit" } else { Write-Host "OK seal_lobby" }

Remove-Item Env:P2P_NET_TEST, Env:P2P_NET_MODE, Env:P2P_NET_ROOM, Env:P2P_NET_ROOM_FILE, Env:P2P_NET_MAX_PEERS -ErrorAction SilentlyContinue

if ($failures.Count -gt 0) {
    Write-Error ("[P2PNet all] FAIL: " + ($failures -join "; "))
}
Write-Host "`n[P2PNet all] OK"
exit 0
