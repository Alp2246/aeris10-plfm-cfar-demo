================================================================
   AERIS-10 RADAR  -  MATLAB CFAR DEMO
================================================================

DOSYA   : radar_cfar_demo.m
KONUM   : matlab\radar_cfar_demo.m

NE YAPAR
--------
  iverilog ile kosturdugumuz radar_demo_tb.v ile AYNI senaryoyu
  MATLAB'da yeniden uretir ve 5 grafik gosterir:

   1) Range profile + CFAR esik (cizgi/bar)
   2) PPI scope (kutupsal radar ekrani - tek pencerede ayri)
   3) Zaman alaninda echo (TX darbeden hedef echo'larina)
   4) CFAR sliding window egitsel diyagram
   5) Konsolda hedef listesi (bin/m/km/mag/thr/margin)

NASIL CALISTIRILIR
------------------
  1. MATLAB'i ac
  2. Komut penceresinde:

       cd 'C:\fpga_work\PLFM_RADAR-main\PLFM_RADAR-main\matlab'
       radar_cfar_demo

  3. 2 figure penceresi acilir:
        - 4 panelli ana grafik
        - Buyuk PPI scope
     PNG cikti dosyalari da uretilir:
        - cfar_demo.png
        - cfar_ppi.png

GEREKLI MATLAB SURUMU
---------------------
  R2019b veya daha yeni (transparency/4-kanal renk icin)
  Hicbir toolbox gerekmez - sadece temel MATLAB.

KOMUTSUZ CALISTIRMA (Windows batch)
-----------------------------------
  Aciksa, scripti acmadan komut satirindan:

    "C:\Program Files\MATLAB\R2024b\bin\matlab.exe" -batch ^
        "cd 'C:\fpga_work\PLFM_RADAR-main\PLFM_RADAR-main\matlab'; radar_cfar_demo"

  (R2024b'yi kendi MATLAB surumune gore degistir)

CIKTI ORNEGI (konsol)
---------------------
  =========================================================
   AERIS-10  CFAR DEMO  (MATLAB)
  =========================================================
    Radar parametreleri:
      Frekans          : 10.5 GHz
      Baseband fs      : 100 MHz
      Bin buyuklugu    : 24.0 m
      Toplam menzil    : 1536 m
    CFAR config        : CA-CFAR  G=2  T=8  alpha=5/16 (=0.3125)
  ---------------------------------------------------------
    TESPIT EDILEN HEDEFLER:
     bin | menzil  | km      | mag      | thr     | margin
    -----+---------+---------+----------+---------+--------
       8 |  192 m  |  0.19   |  30000   |   ...   |   ...
      22 |  528 m  |  0.53   |  20000   |   ...   |   ...
      45 | 1080 m  |  1.08   |  50000   |   ...   |   ...
  =========================================================

GERCEK FPGA ILE BAGLANTI
------------------------
  Bu MATLAB grafigi, FPGA uzerinde cfar_ca.v modulunun ne
  yaptigini gorsel olarak gosterir. Verilog testbench ile
  AYNI sonuclari uretir cunku:
    - Ayni alpha (5/16)
    - Ayni guard/train (2/8)
    - Ayni CA-CFAR formulu
    - Ayni gurultu seed

  FPGA'da bitstream calisirken USB uzerinden gerek (range,
  doppler, mag, thr) dataset alip MATLAB'a yukleyip
  burada aynen ploit edebilirsin.
================================================================
