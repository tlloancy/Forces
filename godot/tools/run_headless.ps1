# Forces — tests headless Godot 4
# Définir GODOT_BIN si besoin, ex.:
#   $env:GODOT_BIN = "C:\Users\tom\Downloads\Godot_v4.6.3-stable_win64.exe"
param(
    [ValidateSet("smoke", "regression", "compile", "import", "p2p")]
    [string]$Mode = "smoke"
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
                if (Test-Path $p) {
                    return $p
                }
            }
        }
    }
    if ($env:GODOT_BIN -and (Test-Path $env:GODOT_BIN)) {
        return $env:GODOT_BIN
    }
    $candidates = @(
        "$env:USERPROFILE\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe",
        "$env:USERPROFILE\Downloads\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64.exe",
        "$env:USERPROFILE\Downloads\Godot_v4.6.3-stable_win64.exe",
        "$env:LOCALAPPDATA\Godot\Godot_v4.6-stable_win64.exe",
        "$env:LOCALAPPDATA\Godot\Godot_v4.4-stable_win64.exe",
        "C:\Godot\Godot_v4.6-stable_win64.exe"
    )
    foreach ($p in $candidates) {
        if (Test-Path $p) {
            return $p
        }
    }
    $cmd = Get-Command godot -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }
    return $null
}

$godot = Find-Godot
if (-not $godot) {
    Write-Host @"

Godot introuvable. Installe Godot 4.x puis définis le chemin :

  winget install GodotEngine.Godot
  # ou télécharge depuis https://godotengine.org/download

Puis :
  `$env:GODOT_BIN = 'C:\chemin\vers\Godot_v4.x-stable_win64.exe'
  .\tools\run_headless.ps1

"@ -ForegroundColor Yellow
    exit 2
}

Write-Host "Godot: $godot"
Write-Host "Projet: $ProjectRoot"
Write-Host "Mode: $Mode"
Write-Host ""

function Invoke-Godot {
    param([string[]]$GodotArgs)
    $proc = Start-Process -FilePath $godot -ArgumentList $GodotArgs -Wait -PassThru -NoNewWindow
    return $proc.ExitCode
}

switch ($Mode) {
    "smoke" {
        # parse d'abord → régénère atlas_sprites.json avec les bons mappings
        python (Join-Path $PSScriptRoot "parse_atlas_meta.py") | Out-Null
        python (Join-Path $PSScriptRoot "extract_layout_from_board_atlas.py") | Out-Null
        python (Join-Path $PSScriptRoot "compose_board_from_tiles.py") | Out-Null
        # vérification après génération
        python (Join-Path $PSScriptRoot "verify_atlas_shapes.py")
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        $code = Invoke-Godot @("--headless", "--path", $ProjectRoot, "res://scenes/headless_test.tscn")
    }
    "regression" {
        python (Join-Path $PSScriptRoot "parse_atlas_meta.py") | Out-Null
        python (Join-Path $PSScriptRoot "verify_atlas_shapes.py")
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
        $code = Invoke-Godot @("--headless", "--path", $ProjectRoot, "res://scenes/headless_test.tscn")
    }
    "compile" {
        $code = Invoke-Godot @("--headless", "--path", $ProjectRoot, "res://scenes/menu/main_menu.tscn", "--quit-after", "2")
    }
    "import" {
        $code = Invoke-Godot @("--headless", "--path", $ProjectRoot, "--import", "--quit")
    }
    "p2p" {
        & (Join-Path $PSScriptRoot "run_p2p_all.ps1")
        $code = $LASTEXITCODE
    }
}
if ($code -eq 0) {
    Write-Host "`n[OK] exit $code" -ForegroundColor Green
} else {
    Write-Host "`n[FAIL] exit $code" -ForegroundColor Red
}
exit $code
