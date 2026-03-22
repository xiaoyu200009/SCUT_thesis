clc; clear; close all;

data1 = importdata('.\exp_data\2025.8.21双极电压电流采样数据.txt');
%对电压采样数据进行拟合
 % X_Voltage = data1(:, 2)/1022;
X_Voltage = data1(:, 2);    %使用Goertzel算法，而不使用DFT算法
Y_Voltage = data1(:, 1);
% 创建范德蒙矩阵（不包含常数项）
V_Voltage = [X_Voltage, X_Voltage.^2];
% 使用最小二乘法求解系数
coefficients = (V_Voltage' * V_Voltage) \ (V_Voltage' * Y_Voltage);
result = V_Voltage * coefficients;

fig = figure;

plot(X_Voltage, Y_Voltage, 'o', X_Voltage, result, '-','LineWidth', 1.2,'MarkerSize', 4);
hold on; box on;

xlabel('采样电压幅值(V)', 'FontName', '黑体', 'FontSize', 10);
ylabel('测试电压幅值(V)', 'FontName', '黑体', 'FontSize', 10);


% xlim([0,50]);
% ylim([0,0.7]);
xlim([0,1.2]);
xticks(0:0.6:1.2);

lgd = legend({'样本分布','拟合曲线'}, ...
       'FontName','黑体', ...
       'FontSize',9, ...
       'Location','southeast');

% % 坐标轴字体
set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 1);

% 调整图窗背景为白色
set(fig, 'Color', 'w');


PlotToFileColorPDF(fig, 'outputfit_vol', 7.5, 5);
% ---------------------------------------------------------------------------
% clc; clear; close all;
% 
% data1 = importdata('.\exp_data\2025.8.21双极电压电流采样数据.txt');
% %对电压采样数据进行拟合
%  % X_Voltage = data1(:, 2)/1022;
% X_Current = data1(:, 4); 
% Y_Current = data1(:, 3) * 0.008136725;%4700pf-0.010335839,%1500pf-0.003298672 %9400pf-0.020671679 %3600pf-0.007916813 %3700pf-0.008136725
% 
% V_Current = [X_Current, X_Current.^2];
% coefficient = (V_Current' * V_Current) \ (V_Current' * Y_Current);
% result1 = V_Current * coefficient;
% 
% % power = (result .* result1)/2;
% % impedance = result ./ result1;
% 
% 
% 
% fig = figure;
% 
% plot(X_Current, Y_Current, 'o', X_Current, result1, '-','LineWidth', 1.2,'MarkerSize', 4);
% hold on; box on;
% 
% xlabel('采样电流幅值(A)', 'FontName', '黑体', 'FontSize', 10);
% ylabel('测试电流幅值(A)', 'FontName', '黑体', 'FontSize', 10);
% 
% 
% ylim([0,0.6]);
% yticks(0:0.2:0.6);
% 
% % % 坐标轴字体
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 10, 'LineWidth', 1);
% 
% % 调整图窗背景为白色
% set(fig, 'Color', 'w');
% 
% lgd = legend({'样本分布','拟合曲线'}, ...
%        'FontName','黑体', ...
%        'FontSize',9, ...
%        'Location','southeast');
% 
% 
% PlotToFileColorPDF(fig, 'outputfit_cur', 7.5, 5);

%对电流采样数据进行拟合
 % 
%  
% 







