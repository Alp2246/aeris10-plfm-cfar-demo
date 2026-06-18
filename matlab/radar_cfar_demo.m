%% =========================================================================
%  AERIS-10 RADAR  -  CFAR DETECTION DEMO (MATLAB)
%
%  Bu script, iverilog'da kosturduğumuz radar_demo_tb.v ile birebir AYNI
%  senaryoyu MATLAB'da uretir, CA-CFAR uygulayip 4 ayri gorsel cikti uretir:
%
%    1) Range profile + CFAR threshold + tespitler
%    2) PPI (Plan Position Indicator) radar scope - kutupsal
%    3) Zaman alaninda echo sinyali (gercek darbe gidis-donus)
%    4) CFAR sliding window aciklamasi (egitsel diyagram)
%
%  Calistirma:  matlab > >> cd matlab; radar_cfar_demo
%
%  Radar parametreleri (AERIS-10N):
%    - Tasiyici frekansi  : 10.5 GHz (X-band)
%    - Baseband fs        : 100 MHz
%    - 1 CFAR bin         : 24 m  (16x decimation)
%    - Toplam menzil      : 1536 m
% =========================================================================

clear; clc; close all;

%% --- Radar parametreleri ------------------------------------------------
c           = 3e8;                      % isik hizi
fc          = 10.5e9;                   % tasiyici (X-band)
fs_baseband = 100e6;                    % baseband ornekleme
Ts          = 1/fs_baseband;            % = 10 ns
decimation  = 16;                       % range_bin_decimator.v: 1024->64
binSize_m   = c * Ts / 2 * decimation;  % 24 m / bin
NUM_BINS    = 64;
maxRange_m  = NUM_BINS * binSize_m;     % 1536 m

%% --- Senaryo: ayni gurultu seed + 3 hedef (iverilog ile eslesiyor) ------
rng(2779124276, 'twister');             % = hex A5A51234 - deterministik
mag = round(2000 + 1500*rand(NUM_BINS,1));   % gurultu zemini ~2000 magn
mag(8+1)  = 30000;   % MATLAB 1-tabanli (bin 8 -> index 9)
mag(22+1) = 20000;
mag(45+1) = 50000;
mag       = double(mag);

%% --- CA-CFAR parametreleri (cfar_ca.v ile birebir) ----------------------
guard      = 2;
train      = 8;
alpha_q44  = 5;                         % Q4.4 = 0x05
alpha      = alpha_q44 / 16;            % = 0.3125

%% --- CA-CFAR uygulamasi (Verilog FSM'in mantigi) ------------------------
threshold = zeros(NUM_BINS,1);
detect    = false(NUM_BINS,1);

for cut = 1:NUM_BINS
    leadIdx = (cut - guard - train) : (cut - guard - 1);
    lagIdx  = (cut + guard + 1)     : (cut + guard + train);
    leadIdx = leadIdx(leadIdx >= 1 & leadIdx <= NUM_BINS);
    lagIdx  = lagIdx(lagIdx  >= 1 & lagIdx  <= NUM_BINS);
    noise_sum   = sum(mag(leadIdx)) + sum(mag(lagIdx));
    threshold(cut) = floor(alpha_q44 * noise_sum / 16);     % >>4
    threshold(cut) = min(threshold(cut), 2^17 - 1);         % saturate 17-bit
    detect(cut) = mag(cut) > threshold(cut);
end

%% --- Konsol cikti -------------------------------------------------------
fprintf('\n=========================================================\n');
fprintf(' AERIS-10  CFAR DEMO  (MATLAB)\n');
fprintf('=========================================================\n');
fprintf('  Radar parametreleri:\n');
fprintf('    Frekans          : %.1f GHz\n', fc/1e9);
fprintf('    Baseband fs      : %d MHz\n',   fs_baseband/1e6);
fprintf('    Bin buyuklugu    : %.1f m\n',   binSize_m);
fprintf('    Toplam menzil    : %.0f m\n',   maxRange_m);
fprintf('  CFAR config        : CA-CFAR  G=%d  T=%d  alpha=%d/16 (=%.4f)\n', ...
        guard, train, alpha_q44, alpha);
fprintf('---------------------------------------------------------\n');
fprintf('  TESPIT EDILEN HEDEFLER:\n');
fprintf('   bin | menzil  | km      | mag      | thr     | margin\n');
fprintf('  -----+---------+---------+----------+---------+--------\n');
detBins = find(detect);
for k = 1:length(detBins)
    b      = detBins(k) - 1;            % 0-tabanli bin no
    rangeM = b * binSize_m;
    margin = round((mag(detBins(k)) - threshold(detBins(k))) ...
                   / threshold(detBins(k)) * 100);
    fprintf('   %3d | %4.0f m  | %5.2f   | %6d   | %6d  | %4d%%\n', ...
            b, rangeM, rangeM/1000, mag(detBins(k)), threshold(detBins(k)), margin);
end
fprintf('=========================================================\n\n');

%% =========================================================================
%  FIGURE 1: 4-panel master plot
% =========================================================================
fig = figure('Name','AERIS-10 CFAR Demo','Position',[100 100 1500 900], ...
             'Color',[0.08 0.08 0.10]);

% ------ PANEL 1: Range Profile + CFAR Threshold -------------------------
ax1 = subplot(2,2,1); hold on;
set(ax1,'Color',[0.10 0.10 0.13],'XColor','w','YColor','w','GridColor',[0.3 0.3 0.3]);

binAxis = (0:NUM_BINS-1)';
rangeAxis = binAxis * binSize_m;

% Noise floor (gri bar)
bar(rangeAxis(~detect), mag(~detect), 0.7, ...
    'FaceColor',[0.3 0.5 0.7],'EdgeColor','none','DisplayName','Gurultu');

% Detected targets (parlak kirmizi bar)
bar(rangeAxis(detect), mag(detect), 0.7, ...
    'FaceColor',[1 0.2 0.2],'EdgeColor',[1 1 0.3],'LineWidth',2, ...
    'DisplayName','HEDEF');

% CFAR threshold (kalin sari cizgi)
plot(rangeAxis, threshold, '-', 'Color',[1 0.9 0.2], 'LineWidth', 2.5, ...
     'DisplayName','CFAR Threshold');

% Hedef etiketleri
for k = 1:length(detBins)
    b = detBins(k);
    text(rangeAxis(b), mag(b) + 3000, ...
         sprintf('%d m', round(rangeAxis(b))), ...
         'Color',[1 1 0.3], 'FontSize',11,'FontWeight','bold', ...
         'HorizontalAlignment','center');
end

grid on; box on;
xlabel('Menzil (metre)','Color','w','FontSize',11);
ylabel('Magnitude (|I| + |Q|)','Color','w','FontSize',11);
title('1)  RANGE PROFILE  +  CFAR ESIK','Color','w','FontSize',13,'FontWeight','bold');
legend('Location','northwest','TextColor','w','Color',[0.15 0.15 0.18]);
ylim([0 max(mag)*1.15]);
xlim([0 maxRange_m]);

% ------ PANEL 2: PPI scope (kutupsal radar ekrani) ----------------------
ax2 = subplot(2,2,2); hold on;
set(ax2,'Color',[0.04 0.06 0.04],'XColor','w','YColor','w');
axis equal;
axis(maxRange_m * [-1.05 1.05 -0.05 1.05]);

% Menzil halkalari
ringRadii = [192 528 1080 1536];
ringTheta = linspace(0, pi, 200);
ringLabel = {'192 m','528 m','1080 m','1.5 km'};
for r = ringRadii
    plot(r*cos(ringTheta), r*sin(ringTheta), ':', ...
         'Color',[0 0.5 0.2],'LineWidth',0.7);
end

% Azimut cizgileri (her 30 derece)
for ang = 0:30:180
    plot([0 maxRange_m*cos(ang*pi/180)], [0 maxRange_m*sin(ang*pi/180)], ...
         ':','Color',[0 0.4 0.1],'LineWidth',0.5);
end

% Radar kaynagi (origin)
plot(0,0,'o','MarkerSize',12,'MarkerFaceColor',[0 0.7 0.2], ...
     'MarkerEdgeColor','w','LineWidth',1.5);
text(0,-60,'RADAR','Color',[0.5 1 0.5],'HorizontalAlignment','center','FontWeight','bold');

% Hedef tespitleri (sentetik azimut sirasi: 60, 120, 90 deg)
detAzimuth_deg = [60 120 90];                % sentetik (sadece gorsel)
for k = 1:length(detBins)
    b      = detBins(k);
    rangeM = rangeAxis(b);
    az     = detAzimuth_deg(k) * pi/180;
    x      = rangeM * cos(az);
    y      = rangeM * sin(az);

    % Hedef sembolu - boyut magnitude'a gore
    msz = 8 + mag(b)/2500;
    plot(x,y,'p','MarkerSize',msz, ...
         'MarkerFaceColor',[1 0.2 0.2], ...
         'MarkerEdgeColor',[1 1 0.4], 'LineWidth',2);

    % Etiket
    text(x, y+80, sprintf('T%d\n%.0f m', k, rangeM), ...
         'Color',[1 1 0.3],'FontWeight','bold','FontSize',10, ...
         'HorizontalAlignment','center');
end

% Menzil etiketleri
for i = 1:length(ringRadii)
    text(ringRadii(i)+30, 30, ringLabel{i}, ...
         'Color',[0.4 0.8 0.4],'FontSize',8);
end

grid off; box on;
title('2)  PPI SCOPE  (radar ekrani)','Color','w','FontSize',13,'FontWeight','bold');
xlabel('X (m)','Color','w'); ylabel('Y (m)','Color','w');

% ------ PANEL 3: Zaman alaninda echo dalga formu -----------------------
ax3 = subplot(2,2,3); hold on;
set(ax3,'Color',[0.10 0.10 0.13],'XColor','w','YColor','w');

% Her bin echo zamani = 2 * range / c, integration after MF
tAxis_ns = binAxis * 2 * binSize_m / c * 1e9;   % round-trip ns

% Echo envelope (simulated)
echoSig = mag;

% TX darbesi (t=0)
fill([0 -100 -100 0], [-5000 -5000 max(mag) max(mag)], ...
     [0 0.5 1],'FaceAlpha',0.15,'EdgeColor',[0 0.7 1],'LineWidth',1.5);
text(-50, max(mag)*0.7, sprintf('TX\ndarbe'), 'Color',[0.5 0.8 1], ...
     'HorizontalAlignment','center','FontWeight','bold', 'Interpreter','none');

% Echo'lar
stem(tAxis_ns(~detect), echoSig(~detect), 'filled', ...
     'Color',[0.3 0.5 0.7], 'MarkerSize',3, 'LineWidth',0.7, ...
     'DisplayName','Gurultu echo');
stem(tAxis_ns(detect), echoSig(detect), 'filled', ...
     'Color',[1 0.2 0.2], 'MarkerSize',10, 'LineWidth',2, ...
     'DisplayName','HEDEF echo');

% Echo zamani etiketleri
for k = 1:length(detBins)
    b   = detBins(k);
    t_us = tAxis_ns(b)/1000;
    text(tAxis_ns(b), echoSig(b)+4000, ...
         sprintf('%.2f us', t_us), ...
         'Color',[1 1 0.3],'FontWeight','bold','FontSize',9, ...
         'HorizontalAlignment','center');
end

grid on; box on;
xlabel('Zaman (ns) - TX dan itibaren','Color','w','FontSize',11);
ylabel('Echo gucu','Color','w','FontSize',11);
title('3)  ZAMAN ALANI  -  Echo geri donus zamani','Color','w', ...
      'FontSize',13,'FontWeight','bold');
legend({'TX darbe','Gurultu echo','HEDEF echo'}, 'Location','best', ...
       'TextColor','w','Color',[0.15 0.15 0.18]);
xlim([-150 tAxis_ns(end)+200]);

% ------ PANEL 4: CFAR sliding window aciklamasi ------------------------
ax4 = subplot(2,2,4); hold on;
set(ax4,'Color',[0.10 0.10 0.13],'XColor','w','YColor','w');

% Ornek olarak CUT = 22'yi gosterelim
cut_demo = 22;
leadStart = cut_demo - guard - train;
leadEnd   = cut_demo - guard - 1;
lagStart  = cut_demo + guard + 1;
lagEnd    = cut_demo + guard + train;

% Tum range profile (mini)
plot(binAxis, mag, '-','Color',[0.4 0.6 0.8],'LineWidth',1);
plot(binAxis(detect), mag(detect), 'o','Color',[1 0.3 0.3], ...
     'MarkerFaceColor',[1 0.3 0.3],'MarkerSize',8);

ymax = max(mag) * 1.1;
ymin = 0;

% Leading training cells (mavi)
fill([leadStart leadEnd leadEnd leadStart], ...
     [ymin ymin ymax ymax], [0.2 0.4 0.9], ...
     'FaceAlpha',0.25,'EdgeColor',[0.4 0.7 1],'LineStyle','--');
text((leadStart+leadEnd)/2, ymax*0.92, sprintf('LEADING\ntraining'), ...
     'Color',[0.5 0.8 1],'FontWeight','bold','HorizontalAlignment','center', ...
     'Interpreter','none');

% Guard cells - sol (sari)
fill([cut_demo-guard cut_demo-1 cut_demo-1 cut_demo-guard], ...
     [ymin ymin ymax ymax], [1 0.7 0.2], ...
     'FaceAlpha',0.3,'EdgeColor',[1 0.8 0.3],'LineStyle','--');

% CUT (kirmizi)
fill([cut_demo-0.5 cut_demo+0.5 cut_demo+0.5 cut_demo-0.5], ...
     [ymin ymin ymax ymax], [1 0.2 0.2], ...
     'FaceAlpha',0.5,'EdgeColor',[1 0.5 0.5],'LineWidth',2);
text(cut_demo, ymax*0.92,'CUT','Color',[1 0.8 0.8], ...
     'FontWeight','bold','FontSize',12,'HorizontalAlignment','center');

% Guard cells - sag
fill([cut_demo+1 cut_demo+guard cut_demo+guard cut_demo+1], ...
     [ymin ymin ymax ymax], [1 0.7 0.2], ...
     'FaceAlpha',0.3,'EdgeColor',[1 0.8 0.3],'LineStyle','--');
text(cut_demo+guard/2+0.5, ymax*0.82,'guard', ...
     'Color',[1 0.8 0.3],'FontWeight','bold','HorizontalAlignment','center');

% Lagging training (mavi)
fill([lagStart lagEnd lagEnd lagStart], ...
     [ymin ymin ymax ymax], [0.2 0.4 0.9], ...
     'FaceAlpha',0.25,'EdgeColor',[0.4 0.7 1],'LineStyle','--');
text((lagStart+lagEnd)/2, ymax*0.92, sprintf('LAGGING\ntraining'), ...
     'Color',[0.5 0.8 1],'FontWeight','bold','HorizontalAlignment','center', ...
     'Interpreter','none');

% CFAR cikis: threshold
plot(binAxis, threshold, '-','Color',[1 0.9 0.2],'LineWidth',2);

grid on; box on;
xlabel('Range bin','Color','w','FontSize',11);
ylabel('Magnitude','Color','w','FontSize',11);
title(sprintf('4)  CFAR SLIDING WINDOW  (CUT = bin %d)', cut_demo), ...
      'Color','w','FontSize',13,'FontWeight','bold');
xlim([0 NUM_BINS]);
ylim([ymin ymax]);

% ------ Master title ----------------------------------------------------
sgtitle('AERIS-10  PLFM RADAR  -  CFAR Detection Demo', ...
        'Color','w','FontSize',16,'FontWeight','bold');

%% --- PNG cikti ----------------------------------------------------------
outDir = fullfile(fileparts(mfilename('fullpath')), 'output');
if ~exist(outDir, 'dir'), mkdir(outDir); end
outFile = fullfile(outDir, 'cfar_demo.png');
exportgraphics(fig, outFile, 'Resolution', 150, 'BackgroundColor', 'current');
fprintf('  PNG yazildi  : %s\n\n', outFile);

%% --- Tek ayrı PPI penceresi (buyuk) -----------------------------------
fig2 = figure('Name','PPI Scope','Position',[200 150 800 800], ...
              'Color',[0.04 0.06 0.04]);
ax = axes('Color',[0.04 0.06 0.04],'XColor',[0.5 1 0.5], ...
          'YColor',[0.5 1 0.5]); hold on;
axis equal;
axis(maxRange_m * [-1.05 1.05 -0.05 1.05]);

% Menzil halkalari
for r = ringRadii
    plot(r*cos(ringTheta), r*sin(ringTheta), '-', ...
         'Color',[0 0.5 0.2 0.4],'LineWidth',1);
    text(0, r+30, sprintf('%d m', r), 'Color',[0.4 0.9 0.4], ...
         'FontSize',9,'HorizontalAlignment','center');
end

% Tarama cizgileri her 15 derecede
for ang = 0:15:180
    plot([0 maxRange_m*cos(ang*pi/180)], [0 maxRange_m*sin(ang*pi/180)], ...
         '-','Color',[0 0.4 0.1 0.3],'LineWidth',0.5);
    text((maxRange_m+50)*cos(ang*pi/180), (maxRange_m+50)*sin(ang*pi/180), ...
         sprintf('%d°', ang), 'Color',[0.4 0.9 0.4],'FontSize',9, ...
         'HorizontalAlignment','center');
end

% Tarama anasiri (dinamik gozetleme efekti)
sweepAngle = 100;
sweep_x = [0 maxRange_m*cos(sweepAngle*pi/180)];
sweep_y = [0 maxRange_m*sin(sweepAngle*pi/180)];
plot(sweep_x, sweep_y, '-', 'Color',[0.2 1 0.3 0.8],'LineWidth',2);

% Radar konumu
plot(0,0,'o','MarkerSize',16,'MarkerFaceColor',[0.2 1 0.3], ...
     'MarkerEdgeColor',[0.9 1 0.9],'LineWidth',2);

% Hedefler
for k = 1:length(detBins)
    b      = detBins(k);
    rangeM = rangeAxis(b);
    az     = detAzimuth_deg(k) * pi/180;
    x      = rangeM * cos(az);
    y      = rangeM * sin(az);
    msz    = 14 + mag(b)/2000;

    % Hedef glow efekti (scatter AlphaData - plot() 4-kanal RGB desteklemez)
    for glow = 5:-1:1
        scatter(x, y, (msz+glow*4)^2, [1 0.3 0.3], 'filled', ...
                'MarkerFaceAlpha', 0.04, 'MarkerEdgeColor', 'none');
    end
    plot(x,y,'p','MarkerSize',msz, ...
         'MarkerFaceColor',[1 0.2 0.2], ...
         'MarkerEdgeColor',[1 1 0.4],'LineWidth',2);

    text(x, y-100, sprintf('TARGET %d\n%.0f m\n%.2f km', k, rangeM, rangeM/1000), ...
         'Color',[1 1 0.5],'FontWeight','bold','FontSize',11, ...
         'HorizontalAlignment','center');
end

title('AERIS-10 PPI SCOPE  -  Tespit edilen hedefler', ...
      'Color',[0.5 1 0.5],'FontSize',16,'FontWeight','bold');
xlabel('Cross-range (m)','Color',[0.5 1 0.5]);
ylabel('Down-range (m)','Color',[0.5 1 0.5]);
grid off; box on;

ppiFile = fullfile(outDir, 'cfar_ppi.png');
exportgraphics(fig2, ppiFile, 'Resolution', 150, 'BackgroundColor','current');
fprintf('  PPI PNG     : %s\n', ppiFile);

% Konsol ozeti de kaydet (GitHub / dokumantasyon icin)
summaryFile = fullfile(outDir, 'cfar_results.txt');
fid = fopen(summaryFile, 'w');
fprintf(fid, 'AERIS-10 CFAR Demo Results\n');
fprintf(fid, 'Generated: %s\n\n', datestr(now));
fprintf(fid, 'Radar: fc=10.5 GHz, fs=100 MHz, bin=%.1f m, max_range=%d m\n', binSize_m, maxRange_m);
fprintf(fid, 'CFAR: CA-CFAR G=%d T=%d alpha=%d/16\n\n', guard, train, alpha_q44);
fprintf(fid, 'bin | range_m | km   | mag   | thr   | margin_pct\n');
fprintf(fid, '----+---------+------+-------+-------+-----------\n');
for k = 1:length(detBins)
    b = detBins(k);
    margin_pct = round((mag(b)/threshold(b)-1)*100);
    fprintf(fid, '%3d | %7.0f | %.2f | %5.0f | %5.0f | %d%%\n', ...
        b, rangeAxis(b), rangeAxis(b)/1000, mag(b), threshold(b), margin_pct);
end
fclose(fid);
fprintf('  Ozet TXT    : %s\n', summaryFile);
fprintf('\n>> Iki figure penceresi acildi. Kapatmak icin: close all\n\n');
