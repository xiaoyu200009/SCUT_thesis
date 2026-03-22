clc; clear; close all;

%% 参数设置
N = 1022;               % 窗长
Nfft = 65536;           % 零填充FFT点数，增大后频谱更平滑
n = 0:N-1;              % 时域序列
f = (0:Nfft/2) / Nfft;  % 单边归一化频率，单位：cycles/sample

%% 生成常见窗函数
w_rect     = rectwin(N);
w_hann     = hann(N);
w_hamming  = hamming(N);
w_blackman = blackman(N);

wins = {w_rect, w_hann, w_hamming, w_blackman};
names = {'矩形窗', '汉宁窗', '海明窗', '布莱克曼窗'};
styles = {'-', '-', '-', '-'};

%% =========================
%% 1. 时域对比图
%% =========================
% % fi = figure('Color','w');
% % fi = figure('Color','w','Position',[100 100 900 420]);
% fig = figure;
% hold on; box on;
% 
% for k = 1:length(wins)
%     plot(n, wins{k}, styles{k}, 'LineWidth', 1.2);
% end
% 
% % grid on;
% xlabel('样本点', 'FontName', '黑体', 'FontSize', 10);
% ylabel('幅值', 'FontName', '黑体', 'FontSize', 10);
% lgd = legend(names, 'Location', 'south', 'FontName', '黑体', 'FontSize', 9);
% lgd.NumColumns = 2;
% xlim([0 N-1]);
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 1);
% 
% PlotToFileColorPDF(fig, 'window_t', 15.5, 5);

%% =========================
%% 2. 频谱主瓣对比图
%% =========================
% figure('Color','w','Position',[100 100 900 420]);
fig = figure;
hold on; box on;

for k = 1:length(wins)
    w = wins{k};
    W = fft(w, Nfft);
    W = abs(W(1:Nfft/2+1));
    W = W / max(W);                     % 归一化
    W_dB = 20*log10(W + 1e-12);         % 转为dB

    plot(f, W_dB, styles{k}, 'LineWidth', 1.2);
end

% grid on;
xlabel('归一化频率', 'FontName', '黑体', 'FontSize', 10);
ylabel('幅度(dB)', 'FontName', '黑体', 'FontSize', 10);
lgd = legend(names, 'Location', 'northeast', 'FontName', '黑体', 'FontSize', 9);
lgd.NumColumns = 4;

xlim([0 0.014]);      % 放大主瓣区域，便于比较主瓣宽度
ylim([-100 5]);
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 1);

PlotToFileColorPDF(fig, 'window_f', 15.5, 5);
