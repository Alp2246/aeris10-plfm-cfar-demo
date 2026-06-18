# sim.ps1 - AERIS-10 / PLFM Radar — Icarus Verilog simülasyon
#
# Kullanım:
#   .\sim.ps1 -Radar                    # radar zincirinin iverilog ile çalışan modülleri
#   .\sim.ps1 cfar_ca                    # tek modül
#   .\sim.ps1 cfar_ca -OpenWave          # + GTKWave dalga formu
#   .\sim.ps1 -List
#   .\sim.ps1 -All                       # 34 tb tara (Xilinx olanlar compile fail)

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string] $Module = "",
    [switch] $OpenWave,
    [switch] $List,
    [switch] $All,
    [switch] $Radar
)

$ErrorActionPreference = "Continue"

$workDir = $PSScriptRoot

$plfmRoot = if ($env:PLFM_RADAR_ROOT) { $env:PLFM_RADAR_ROOT } else {
    Join-Path (Split-Path -Parent (Split-Path -Parent $workDir)) "PLFM_RADAR-main\PLFM_RADAR-main"
}
$rtlDir  = Join-Path $plfmRoot "9_Firmware\9_2_FPGA"
$tbDir   = Join-Path $rtlDir "tb"

$env:Path = "C:\iverilog\bin;C:\iverilog\gtkwave\bin;" + $env:Path

# iverilog ile doğrulanmış radar modülleri (tam PASS)
$RadarPassModules = @(
    "cdc_modules",
    "cfar_ca",
    "edge_detector",
    "fir_lowpass",
    "fpga_self_test",
    "latency_buffer",
    "mf_cosim",
    "mti_canceller",
    "radar_mode_controller",
    "range_bin_decimator",
    "rx_gain_control"
)

function Get-RtlFiles {
    Get-ChildItem -Path $rtlDir -Filter "*.v" -File |
        Where-Object { $_.Name -notmatch "^radar_system_top" -and $_.Name -ne "adc_clk_mmcm.v" } |
        ForEach-Object { $_.FullName }
}

function Parse-SimResult {
    param([string]$Text)
    if ($Text -match "ALL TESTS PASSED" -or $Text -match "All \d+ tests passed" -or $Text -match "ALL \d+ TESTS PASSED") {
        return "PASS"
    }
    if ($Text -match "PASSED:\s*(\d+).*FAILED:\s*(\d+)") {
        if ([int]$Matches[2] -eq 0) { return "PASS" }
        return "FAIL ($($Matches[1])/$([int]$Matches[1]+[int]$Matches[2]))"
    }
    if ($Text -match "Results:\s*(\d+)/(\d+)\s*PASS") {
        if ($Matches[1] -eq $Matches[2]) { return "PASS" }
        return "FAIL ($($Matches[1])/$($Matches[2]))"
    }
    if ($Text -match "PASS:\s*(\d+).*FAIL:\s*(\d+)") {
        if ([int]$Matches[2] -eq 0) { return "PASS" }
        return "FAIL (pass=$($Matches[1]) fail=$($Matches[2]))"
    }
    if ($Text -match "(\d+)\s+passed,\s*0\s+failed") { return "PASS" }
    if ($Text -match "All RX gain control tests passed") { return "PASS" }
    if ($Text -match '\$finish') { return "DONE (sonucu kontrol et)" }
    return "UNKNOWN"
}

function List-Testbenches {
    Write-Host "Mevcut testbench'ler (9_Firmware/9_2_FPGA/tb/):" -ForegroundColor Cyan
    Get-ChildItem -Path $tbDir -Filter "tb_*.v" -File |
        Select-Object @{N='Module';E={ $_.BaseName -replace '^tb_','' }},
                      @{N='KB';E={[math]::Round($_.Length/1KB,1)}} |
        Format-Table -AutoSize
    Write-Host ""
    Write-Host "Radar paketi (-Radar):" -ForegroundColor Green
    $RadarPassModules -join ", "
}

function Invoke-Sim {
    param(
        [string]$ModuleName,
        [switch]$Quiet
    )

    $tbFile = Join-Path $tbDir "tb_${ModuleName}.v"
    if (-not (Test-Path $tbFile)) {
        if (-not $Quiet) { Write-Host "HATA: $tbFile yok." -ForegroundColor Red }
        return @{ Ok = $false; Status = "NO_TB" }
    }

    $vvp = Join-Path $workDir "tb_${ModuleName}.vvp"
    $vcd = Join-Path $workDir "tb_${ModuleName}.vcd"

    if (-not $Quiet) {
        Write-Host ""
        Write-Host "=== $ModuleName ===" -ForegroundColor Cyan
        Write-Host "[1/2] Compile..." -ForegroundColor DarkGray
    }

    $rtlFiles = Get-RtlFiles
    $compileOut = & iverilog -g2012 -o $vvp -s "tb_$ModuleName" $tbFile @rtlFiles 2>&1
    if ($LASTEXITCODE -ne 0) {
        if (-not $Quiet) {
            Write-Host "  COMPILE FAIL" -ForegroundColor Red
            $compileOut | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" }
        }
        return @{ Ok = $false; Status = "COMPILE_FAIL" }
    }

    if (-not $Quiet) { Write-Host "  OK" -ForegroundColor Green; Write-Host "[2/2] Simulate..." -ForegroundColor DarkGray }

    Push-Location $workDir
    $simOut = (vvp "tb_${ModuleName}.vvp" 2>&1 | Out-String)
    Pop-Location

    $status = Parse-SimResult $simOut
    $ok = ($status -eq "PASS")

    if (-not $Quiet) {
        $simOut -split "`n" | Select-Object -Last 12 | ForEach-Object {
            if ($_ -match "PASS|FAIL|RESULT|====") { Write-Host "  $_" }
        }
        $color = if ($ok) { "Green" } else { "Yellow" }
        Write-Host "  >> $status" -ForegroundColor $color
    }

    if ($OpenWave -and (Test-Path $vcd)) {
        Start-Process gtkwave -ArgumentList $vcd
    }

    return @{ Ok = $ok; Status = $status; Vcd = $vcd }
}

# --- main ---
if ($List) { List-Testbenches; exit 0 }

if ($Radar) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host " AERIS-10 Radar - Icarus Verilog Paketi" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    $pass = 0; $fail = 0
    foreach ($m in $RadarPassModules) {
        $r = Invoke-Sim $m -Quiet
        $icon = if ($r.Ok) { "PASS" } else { "FAIL" }
        $col  = if ($r.Ok) { "Green" } else { "Yellow" }
        Write-Host ("  [{0,-5}] {1,-28} {2}" -f $icon, $m, $r.Status) -ForegroundColor $col
        if ($r.Ok) { $pass++ } else { $fail++ }
    }
    Write-Host ""
    Write-Host ("  Ozet: {0} PASS, {1} FAIL / {2} modul" -f $pass, $fail, $RadarPassModules.Count) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Dalga formu: .\sim.ps1 cfar_ca -OpenWave" -ForegroundColor DarkGray
    Write-Host "  Tek modul:   .\sim.ps1 radar_mode_controller" -ForegroundColor DarkGray
    exit $(if ($fail -gt 0) { 1 } else { 0 })
}

if ($All) {
    $tbs = Get-ChildItem -Path $tbDir -Filter "tb_*.v" | ForEach-Object { $_.BaseName -replace '^tb_','' }
    $stats = @{}
    foreach ($t in $tbs) {
        $r = Invoke-Sim $t -Quiet
        if (-not $stats.ContainsKey($r.Status)) { $stats[$r.Status] = 0 }
        $stats[$r.Status]++
        $icon = if ($r.Ok) { "PASS" } elseif ($r.Status -eq "COMPILE_FAIL") { "SKIP" } else { "WARN" }
        Write-Host ("  [{0,-4}] {1,-30} {2}" -f $icon, $t, $r.Status)
    }
    Write-Host ""; Write-Host "Ozet:" -ForegroundColor Cyan
    $stats.GetEnumerator() | Sort-Object Name | ForEach-Object { Write-Host ("  {0}: {1}" -f $_.Key, $_.Value) }
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Module)) {
    Write-Host "AERIS-10 Radar Simulasyon (iverilog)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  .\sim.ps1 -Radar                 # 11 modul, radar isleme zinciri"
    Write-Host "  .\sim.ps1 cfar_ca                # tek modul"
    Write-Host "  .\sim.ps1 cfar_ca -OpenWave      # + GTKWave"
    Write-Host "  .\sim.ps1 -List"
    Write-Host "  .\sim.ps1 -All"
    exit 0
}

Invoke-Sim $Module | Out-Null
