# Download webrtc-native GDExtension binaries into res://webrtc/ (desktop P2P / WebRTC).
$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$LibDir = Join-Path $ProjectRoot "webrtc\lib"
$ReleaseUrl = "https://github.com/godotengine/webrtc-native/releases/download/1.1.0-stable/godot-extension-webrtc.zip"

New-Item -ItemType Directory -Force -Path $LibDir | Out-Null

$winDll = Join-Path $LibDir "libwebrtc_native.windows.template_debug.x86_64.dll"
if (Test-Path $winDll) {
    Write-Host "webrtc-native already present: $winDll"
    exit 0
}

Write-Host "Downloading webrtc-native 1.1.0-stable..."
$zip = Join-Path $env:TEMP "godot-extension-webrtc.zip"
$extract = Join-Path $env:TEMP "godot-extension-webrtc"
Invoke-WebRequest -Uri $ReleaseUrl -OutFile $zip -UseBasicParsing
if (Test-Path $extract) { Remove-Item $extract -Recurse -Force }
Expand-Archive -Path $zip -DestinationPath $extract -Force

$srcLib = Join-Path $extract "webrtc\lib"
if (-not (Test-Path $srcLib)) {
    Write-Error "Unexpected zip layout — expected webrtc/lib/"
}

Copy-Item (Join-Path $srcLib "*") $LibDir -Recurse -Force
Write-Host "Installed webrtc-native into $LibDir"
Write-Host "Next: .\tools\run_headless.ps1 -Mode import"
