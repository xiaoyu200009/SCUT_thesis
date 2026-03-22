%--------------------------------------------------------------------------原始电流数据（单图版）
% clc; clear; close all;
% 
% data = importdata('.\exp_data\data4.log');
% 
% 
% y = (data(:, 2)/1023) * 3.3;  %恢复信号实际值10bit分辨率
% x = data(:, 1);
% 
% fig = figure;
% 
% plot(x, y, '-o','LineWidth', 1.2, 'MarkerSize', 2);
% hold on; box on;
% 
% xlim([0,50]);
% ylim([0,0.7]);
% xlabel('点数', 'FontName', '黑体', 'FontSize', 10);
% ylabel('电流(A)', 'FontName', '黑体', 'FontSize', 10);
% 
% % 坐标轴字体
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 1);
% 
% % 调整图窗背景为白色
% set(fig, 'Color', 'w');
% 
% PlotToFileColorPDF(fig, 'samp_volcur', 7.5, 5);
%--------------------------------------------------------------------------加窗电流数据（单图版）
% clc; clear; close all;
% 
% data = importdata('.\exp_data\data4.log');
% 
% N=1022;
% window = hann(N);
% 
% w_gain = sum(window)/N;
% value_win = data(1:1022, 2) .* window;
% 
% y = (value_win/1023) * 3.3;  %恢复信号实际值10bit分辨率
% x = data(1:1022, 1);
% 
% fig = figure;
% 
% 
% plot(x, y, '-o','LineWidth', 1.2, 'MarkerSize', 2);
% hold on; box on;
% 
% xlim([0,50]);
% % ylim([0,0.016]);
% xlabel('点数', 'FontName', '黑体', 'FontSize', 10);
% ylabel('电流(A)', 'FontName', '黑体', 'FontSize', 10);
% 
% % 坐标轴字体
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 1);
% 
% % 调整图窗背景为白色
% set(fig, 'Color', 'w');
% 
% PlotToFileColorPDF(fig, 'samp_volcur_win', 7.5, 5);

%--------------------------------------------------------------------------原始电流数据频域分析（单图版）
% clc; clear; close all;
% 
% data = importdata('.\exp_data\data4.log');
% 
% 
% y = (data(:, 2)/1023) * 3.3;  %恢复信号实际值10bit分辨率
% x = data(:, 1);
% 
% Fs = 2.4e6;
% N = 1022;   %1022点DFT
% 
% freqY = fft(y,N);
% freqX = (0:N-1)*(Fs/N); %x轴频率
% half_N = floor(N/2);
% f_plot = freqX(1:half_N);   %单边频谱
% %Y_plot = abs(freqY(1:half_N)) * 2 / N; 
% Y_plot = abs(freqY(1:half_N)) / N; %归一化：对实信号来说，除了直流和 Nyquist 点外，其频谱是对称的；所以，单边频谱幅值需要乘以 2，用来补偿另一半；除以 N 是做幅值归一化，因为 FFT 本身不归一化，值与采样点数成比例。
% Y_plot(2:end-1) = Y_plot(2:end-1) * 2;   %特殊电位幅值补偿
% 
% fig = figure;
% 
% plot(f_plot / 1000, Y_plot, 'LineWidth', 1.2, 'MarkerSize', 2);
% hold on; box on;
% 
% plot(f_plot(150) /1000, Y_plot(150), 'ro', 'MarkerSize', 7, 'LineWidth', 1.2);   % 画点
% x0 = f_plot(150) /1000;
% y0 = Y_plot(150);
% text(x0*1.1, y0*0.8, sprintf('(%.3f KHz, %.5f)', x0, y0), ...
%     'VerticalAlignment', 'bottom', ...
%     'HorizontalAlignment', 'left', ...
%     'FontSize', 8);
% 
% 
% 
% % xlim([0,50]);
% % ylim([0,0.7]);
% xlabel('频率(KHz)', 'FontName', '黑体', 'FontSize', 10);
% ylabel('幅值', 'FontName', '黑体', 'FontSize', 10);
% % grid on;
% 
% 
% % 坐标轴字体
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 1);
% 
% % 调整图窗背景为白色
% set(fig, 'Color', 'w');
% 
% PlotToFileColorPDF(fig, 'samp_volcur_fft', 7.5, 5);

%--------------------------------------------------------------------------原始电流数据频域分析（单图版）
% clc; clear; close all;
% 
% data = importdata('.\exp_data\data4.log');
% 
% Fs = 2.4e6;
% N = 1022;   %1022点DFT
% window = hann(N);
% w_gain = sum(window)/N;
% value_win = data(1:1022, 2) .* window;
% 
% y = (value_win/1023) * 3.3;  %恢复信号实际值10bit分辨率
% x = data(1:1022, 1);
% 
% freqY = fft(y,N);
% freqX = (0:N-1)*(Fs/N); %x轴频率
% half_N = floor(N/2);
% f_plot = freqX(1:half_N);   %单边频谱
% %Y_plot = abs(freqY(1:half_N)) * 2 / N; 
% Y_plot = abs(freqY(1:half_N)) / (N*w_gain); %归一化：对实信号来说，除了直流和 Nyquist 点外，其频谱是对称的；所以，单边频谱幅值需要乘以 2，用来补偿另一半；除以 N 是做幅值归一化，因为 FFT 本身不归一化，值与采样点数成比例。
% Y_plot(2:end-1) = Y_plot(2:end-1) * 2;   %特殊电位幅值补偿
% 
% fig = figure;
% 
% plot(f_plot / 1000, Y_plot, 'LineWidth', 1.2, 'MarkerSize', 2);
% hold on; box on;
% 
% plot(f_plot(150) /1000, Y_plot(150), 'ro', 'MarkerSize', 7, 'LineWidth', 1.2);   % 画点
% x0 = f_plot(150) /1000;
% y0 = Y_plot(150);
% text(x0*1.1, y0*0.8, sprintf('(%.3f KHz, %.5f)', x0, y0), ...
%     'VerticalAlignment', 'bottom', ...
%     'HorizontalAlignment', 'left', ...
%     'FontSize', 8);
% 
% 
% 
% % xlim([0,50]);
% % ylim([0,0.7]);
% xlabel('频率(KHz)', 'FontName', '黑体', 'FontSize', 10);
% ylabel('幅值', 'FontName', '黑体', 'FontSize', 10);
% % grid on;
% 
% 
% % 坐标轴字体
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 1);
% 
% % 调整图窗背景为白色
% set(fig, 'Color', 'w');
% 
% PlotToFileColorPDF(fig, 'samp_volcur_win_fft', 7.5, 5);

