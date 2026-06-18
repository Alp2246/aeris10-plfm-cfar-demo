# Fetch MATLAB gallery PNGs from sibling GitHub repos (MIT)
$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$gallery  = Join-Path $repoRoot "output\matlab\gallery"
New-Item -ItemType Directory -Path $gallery -Force | Out-Null

$sources = @(
    @{ Repo = "matlab-fmcw-isac-examples"; Path = "results/fmcw_range_doppler.png" },
    @{ Repo = "matlab-fmcw-isac-examples"; Path = "results/fmcw_mimo_animasyon.png" },
    @{ Repo = "matlab-fmcw-isac-examples"; Path = "results/fmcw_kalman_tracker.png" },
    @{ Repo = "matlab-fmcw-isac-examples"; Path = "results/isac_ofdm_sensing.png" },
    @{ Repo = "matlab-wireless-comm-examples"; Path = "results/bpsk_ber_awgn.png" },
    @{ Repo = "gnss-spoofing-research"; Path = "results/pseudorange_prn_bias_fig1.png" },
    @{ Repo = "gnss-spoofing-research"; Path = "results/pseudorange_prn_bias_fig2.png" },
    @{ Repo = "gnss-spoofing-research"; Path = "results/pseudorange_ramp_bias.png" },
    @{ Repo = "gnss-spoofing-research"; Path = "results/residual_spoof_detect.png" },
    @{ Repo = "gnss-spoofing-research"; Path = "results/softgnss_track_metrics.png" }
)

foreach ($s in $sources) {
    $name = Split-Path $s.Path -Leaf
    $url  = "https://raw.githubusercontent.com/Alp2246/$($s.Repo)/master/$($s.Path)"
    $dest = Join-Path $gallery $name
    Write-Host "GET $name"
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}
Write-Host "Done -> $gallery"
