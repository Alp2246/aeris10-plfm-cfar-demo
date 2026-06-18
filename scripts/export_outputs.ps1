# AERIS-10 PLFM Radar Demos — Export All Outputs (MIT)
#
# Regenerates committed output/ artifacts from MATLAB + Icarus Verilog demos.
# Requires: MATLAB (batch), Icarus Verilog on PATH, optional Python+matplotlib.
#
# Usage (from repo root):
#   .\scripts\export_outputs.ps1

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$outDir   = Join-Path $repoRoot "output"
$matDir   = Join-Path $repoRoot "matlab"
$ivDir    = Join-Path $repoRoot "iverilog_demo"
$plfmRoot = Join-Path (Split-Path -Parent $repoRoot) "PLFM_RADAR-main\PLFM_RADAR-main"

if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

Write-Host "==> MATLAB CFAR demo"
$matlab = Get-ChildItem "C:\Program Files\MATLAB" -Directory -ErrorAction SilentlyContinue |
    Where-Object { Test-Path (Join-Path $_.FullName "bin\matlab.exe") } |
    Sort-Object Name -Descending | Select-Object -First 1
if ($matlab) {
    $exe = Join-Path $matlab.FullName "bin\matlab.exe"
    Push-Location $matDir
    & $exe -batch "radar_cfar_demo; exit"
    Pop-Location
} else {
    Write-Warning "MATLAB not found — skipping MATLAB outputs"
}

Write-Host "==> MATLAB gallery (sibling repos)"
& (Join-Path $repoRoot "scripts\fetch_matlab_gallery.ps1")

Write-Host "==> Icarus Verilog CFAR demo"
$env:Path = "C:\iverilog\bin;C:\iverilog\gtkwave\bin;" + $env:Path
Push-Location $ivDir
if (Test-Path (Join-Path $plfmRoot "9_Firmware\9_2_FPGA\cfar_ca.v")) {
    .\demo.ps1 -NoWave 2>&1 | Out-File (Join-Path $outDir "iverilog_cfar_demo_log.txt") -Encoding utf8
} else {
    Write-Warning "PLFM_RADAR RTL not found at $plfmRoot — run demo from full PLFM checkout"
}
if (Test-Path (Join-Path $plfmRoot "9_Firmware\9_2_FPGA\tb")) {
    .\sim.ps1 -Radar 2>&1 | Out-File (Join-Path $outDir "iverilog_module_tests_log.txt") -Encoding utf8
}
Pop-Location

Write-Host "==> Python range plot (optional)"
$py = Join-Path $repoRoot "scripts\plot_range_profile.py"
if ((Get-Command python -ErrorAction SilentlyContinue) -and (Test-Path $py)) {
    python $py
}

Write-Host "Done. See output/ folder."
