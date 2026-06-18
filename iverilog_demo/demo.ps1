# ============================================================================
# demo.ps1 - AERIS-10 RADAR CFAR DEMO (renkli + radar scope)
# ============================================================================

[CmdletBinding()]
param(
    [switch] $NoWave
)

$ErrorActionPreference = "Continue"
$env:Path = "C:\iverilog\bin;C:\iverilog\gtkwave\bin;" + $env:Path

$workDir = $PSScriptRoot
Set-Location $workDir

$bundledRtl = Join-Path $workDir "rtl"
$plfmRoot   = if ($env:PLFM_RADAR_ROOT) { $env:PLFM_RADAR_ROOT } else {
    Join-Path (Split-Path -Parent (Split-Path -Parent $workDir)) "PLFM_RADAR-main\PLFM_RADAR-main"
}
if (Test-Path (Join-Path $bundledRtl "cfar_ca.v")) {
    $rtlDir = $bundledRtl
} elseif (Test-Path (Join-Path $plfmRoot "9_Firmware\9_2_FPGA\cfar_ca.v")) {
    $rtlDir = Join-Path $plfmRoot "9_Firmware\9_2_FPGA"
} else {
    Write-Host "HATA: cfar_ca.v bulunamadi. rtl/ klasorunu veya PLFM_RADAR_ROOT ortam degiskenini ayarla." -ForegroundColor Red
    exit 1
}

# ANSI 24-bit renkler
$ESC   = [char]27
function C-FG($r,$g,$b,$t) { "$ESC[38;2;${r};${g};${b}m$t$ESC[0m" }
function C-BG($r,$g,$b,$t) { "$ESC[48;2;${r};${g};${b}m$t$ESC[0m" }
function C-Bold($t)        { "$ESC[1m$t$ESC[0m" }

Write-Host ""
Write-Host (C-Bold (C-FG 0 230 230 "==============================================================")) 
Write-Host (C-Bold (C-FG 0 230 230 "   AERIS-10 RADAR  -  CFAR DETECTION DEMO"))
Write-Host (C-Bold (C-FG 0 230 230 "=============================================================="))
Write-Host (C-FG 220 220 80 " Adim 1/4 : Compile (iverilog)")

$cfarSrc = Join-Path $rtlDir "cfar_ca.v"
$tbSrc   = Join-Path $workDir "radar_demo_tb.v"
$vvp     = Join-Path $workDir "radar_demo.vvp"
$vcd     = Join-Path $workDir "radar_demo.vcd"
$gtkw    = Join-Path $workDir "radar_demo.gtkw"

$compile = & iverilog -g2012 -DSIMULATION -o $vvp -s radar_demo_tb $tbSrc $cfarSrc 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  COMPILE FAILED" -ForegroundColor Red
    $compile | ForEach-Object { Write-Host "  $_" }
    exit 1
}
Write-Host (C-FG 0 220 0 "  OK")

Write-Host ""
Write-Host (C-FG 220 220 80 " Adim 2/4 : Simulasyon (vvp) + canli tespit logu")
Write-Host (C-FG 80 80 80 "--------------------------------------------------------------")

$simStart = Get-Date
$simLines = vvp $vvp 2>&1
$simSec   = [math]::Round(((Get-Date) - $simStart).TotalSeconds, 2)

# Sim ciktisini renkli bas + tespit anlarini sakla
$detections = @()
foreach ($line in $simLines) {
    $l = "$line"
    if ($l -match "\*\*\* DETECTION \*\*\*\s+bin=(\d+)\s+range=(\d+) m \((\S+) km\)\s+mag=(\d+)\s+thr=(\d+)\s+margin=(-?\d+)") {
        $detections += [PSCustomObject]@{
            TimeNs  = ($l -replace '.*t=(\d+).*','$1')
            Bin     = [int]$Matches[1]
            RangeM  = [int]$Matches[2]
            RangeKm = $Matches[3]
            Mag     = [int]$Matches[4]
            Thr     = [int]$Matches[5]
            Margin  = [int]$Matches[6]
        }
        Write-Host (C-FG 255 80 80 $l)
    } elseif ($l -match "<-- HEDEF") {
        Write-Host (C-FG 255 120 0 $l)
    } elseif ($l -match "BASARILI|PASS|3 hedef") {
        Write-Host (C-FG 0 255 0 $l)
    } elseif ($l -match "WARN|kacirildi|false alarm") {
        Write-Host (C-FG 255 200 0 $l)
    } elseif ($l -match "Radar parametreleri|Ground truth|hedefler|SONUC|Hedef listesi") {
        Write-Host (C-Bold (C-FG 0 200 255 $l))
    } elseif ($l -match "^={5,}|^-{5,}") {
        Write-Host (C-FG 100 200 200 $l)
    } elseif ($l -match "CFAR isleme|frame_complete|Frame yukleniyor|Frame yuklendi|tamamlandi") {
        Write-Host (C-FG 180 180 80 $l)
    } else {
        Write-Host $l
    }
}

Write-Host (C-FG 80 80 80 "--------------------------------------------------------------")
Write-Host (C-FG 100 100 100 (" Simulasyon suresi: $simSec saniye"))

# ============================================================
# RADAR SCOPE - PowerShell renkli gorsel
# ============================================================
Write-Host ""
Write-Host (C-Bold (C-FG 0 200 255 " Adim 3/4 : RADAR SCOPE (renkli gorsellestirme)"))
Write-Host ""

# Range axis: 0 m -> 1536 m
$rangeAxisM   = 1536
$scopeWidth   = 64
$detList      = $detections  # already extracted

# Ust eksen
$top = "    " + (C-FG 100 100 100 "0 m")
$top += (" " * ($scopeWidth - 3 - 5)) + (C-FG 100 100 100 "1.5 km")
Write-Host $top

# Renkli scope satiri (her sutun 1 bin = 24 m)
$row = (C-FG 100 100 100 "  | ")
for ($b = 0; $b -lt $scopeWidth; $b++) {
    $det = $detList | Where-Object { $_.Bin -eq $b }
    if ($det) {
        # Hedef sutunu - magnitude'a gore renk
        $mag = $det.Mag
        if ($mag -gt 40000) {
            $row += (C-Bold (C-BG 200 0 0 (C-FG 255 255 255 "*")))      # cok guclu
        } elseif ($mag -gt 25000) {
            $row += (C-Bold (C-BG 200 100 0 (C-FG 255 255 255 "*")))    # guclu
        } else {
            $row += (C-Bold (C-BG 180 180 0 (C-FG 0 0 0 "*")))           # orta
        }
    } else {
        # Gurultu zemini - donuk gri nokta
        $row += (C-FG 60 60 60 ".")
    }
}
$row += (C-FG 100 100 100 " |")
Write-Host $row

# Alt eksen tick'leri (her 240 m'de bir)
$tick = "  | "
for ($b = 0; $b -lt $scopeWidth; $b++) {
    if ($b % 10 -eq 0) { $tick += (C-FG 100 100 100 "+") }
    else               { $tick += " " }
}
$tick += " |"
Write-Host $tick

# Metre etiketleri
$lbl = "  | "
for ($b = 0; $b -lt $scopeWidth; $b++) {
    if ($b % 10 -eq 0) {
        $m = ($b * 24).ToString()
        # tek karakter ekle, sonra digerlerini bosluk birak
        $lbl += (C-FG 100 100 100 $m.Substring(0,1))
        # geri kalan rakamlar
        for ($k = 1; $k -lt $m.Length; $k++) {
            if ($b + $k -lt $scopeWidth) {
                # zaten yazildi, bu satira eklemiyoruz tickte
            }
        }
    }
}
Write-Host (C-FG 100 100 100 "  |  0      240    480    720    960   1200   1440  metre")
Write-Host ""

# Detayli tespit kutusu
if ($detList.Count -gt 0) {
    Write-Host (C-Bold (C-FG 0 255 100 " TESPIT EDILEN HEDEFLER:"))
    Write-Host (C-FG 100 200 200 " +-------+--------+----------+-----------+------------+---------+")
    Write-Host (C-FG 100 200 200 " |  bin  |  m     |  km      | magnitude | threshold  | margin  |")
    Write-Host (C-FG 100 200 200 " +-------+--------+----------+-----------+------------+---------+")
    foreach ($d in $detList) {
        $col = if ($d.Margin -gt 200) { "255 80 80" }
               elseif ($d.Margin -gt 80) { "255 180 0" }
               else { "255 230 100" }
        $rgb = $col -split ' '
        $line = (" | {0,3}   | {1,4} m | {2,5} km | {3,7}   | {4,7}    | {5,4}%   |" -f $d.Bin, $d.RangeM, $d.RangeKm, $d.Mag, $d.Thr, $d.Margin)
        Write-Host (C-FG $rgb[0] $rgb[1] $rgb[2] $line)
    }
    Write-Host (C-FG 100 200 200 " +-------+--------+----------+-----------+------------+---------+")
    Write-Host ""
    Write-Host (C-FG 150 150 150 " Renk kodu:")
    Write-Host (C-FG 255 80 80  "   KIRMIZI = guclu hedef (margin > %200)")
    Write-Host (C-FG 255 180 0  "   TURUNCU = orta margin")
    Write-Host (C-FG 255 230 100 "   SARI    = zayif margin")
    Write-Host ""
}

# ============================================================
# GTKWave
# ============================================================
Write-Host (C-FG 220 220 80 " Adim 4/4 : Dalga formu (GTKWave)")
$vcdKB = [math]::Round((Get-Item $vcd).Length / 1KB, 1)
Write-Host (C-FG 0 220 0 ("  radar_demo.vcd       ({0} KB)" -f $vcdKB))
Write-Host (C-FG 0 220 0 "  radar_demo.gtkw      (sinyal duzeni hazir)")
if ($NoWave) {
    Write-Host (C-FG 100 100 100 "  -NoWave: GTKWave acilmadi. Manuel: gtkwave radar_demo.gtkw")
} else {
    Write-Host (C-FG 0 220 0 "  GTKWave aciliyor...")
    Start-Process gtkwave -ArgumentList $gtkw
    Write-Host ""
    Write-Host (C-FG 200 200 100 " GTKWave'de tespit anini gormek icin:")
    Write-Host (C-FG 200 200 100 "   1. det_flag sinyaline sag tik -> Edit Color -> Red")
    Write-Host (C-FG 200 200 100 "   2. Ctrl+Shift+F  (tum zamani sigdir)")
    Write-Host (C-FG 200 200 100 "   3. det_flag = 1 olan 3 dik pulse'u gor")
    Write-Host (C-FG 200 200 100 "   4. det_range[5:0] degerleri = 8, 22, 45 olmali")
}

Write-Host ""
Write-Host (C-Bold (C-FG 0 230 230 "=============================================================="))
Write-Host (C-Bold (C-FG 0 230 230 " Demo tamamlandi - 3 hedef yakalandi"))
Write-Host (C-Bold (C-FG 0 230 230 "=============================================================="))
Write-Host ""
