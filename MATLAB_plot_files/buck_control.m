%% 1.Buck电路设计参数
UO = 20;                %输出电压
UI = 50;                %输入电压
D = 0.4;                %占空比
P = 100;                %输出功率
f = 1e5;                %开关频率
T = 1/f;                %开关周期
I = P/UO;               %输出电流
R = UO / I;             %负载电阻
deta_I_per = 0.3;       %电感电流纹波电流（峰峰值）百分比  
deta_U_per = 0.02;      %电容电压纹波电流（峰峰值）百分比
deta_I = I*deta_I_per;  %电感电流纹波电流（峰峰值）
deta_U = UO*deta_U_per; %电容电压纹波电流（峰峰值）
%% 2.Buck电路电感电容参数计算
L = (UI-UO)*D/(f*deta_I);        %电感值计算
(UI-UO)*D*T/L/2;                 %输出电流不能小于此值，否则电感电流不能连续（临界连续情况下的输出电流）
C = D*(1-D)*UI/(8*deta_U*L*f*f);%电容值计算
C = 47e-6;                       %电容值实际取值
%% 3.电流平均值模型
s = tf('s');
Hs = 1/(L*C*s^2 + L/R*s + 1);   %构建平均值开环传递函数
% bode(Hs)
% hold on
% step(Hs*20,0.05)
% grid on
%----------------------------绘图部分begin
% fig = figure;
% 
% w = logspace(4, 7, 1000);
% % [mag, phase, wout] = bode(Hs, w);
% [mag, phase, wout] = bode(Hs);
% 
% mag = squeeze(mag);
% phase = squeeze(phase);
% 
% % f1 = wout / (2*pi);
% mag_db = 20 * log10(mag);
% 
% fig = figure;
% set(fig, 'Color', 'w');
% 
% ax1=subplot(2,1,1);
% semilogx(wout, mag_db, 'LineWidth', 1.2);
% box on;
% ylabel('幅值(dB)', 'FontName', '黑体', 'FontSize', 9);
% set(gca, ...
%     'FontName', 'Times New Roman', ...
%     'FontSize', 9, ...
%     'LineWidth', 1);
% 
% % 不在上图显示x轴标签
% set(gca, 'XTickLabel', []);
% ylim(ax1, [-80 20]);
% yticks(ax1, [-80 -40 0 20]);
% 
% ax2=subplot(2,1,2);
% semilogx(wout, phase, 'LineWidth', 1.2);
% box on;
% 
% xlabel('频率(rad/s)', 'FontName', '黑体', 'FontSize', 9);
% ylabel('相位(°)', 'FontName', '黑体', 'FontSize', 9);
% 
% set(gca, ...
%     'FontName', 'Times New Roman', ...
%     'FontSize', 9, ...
%     'LineWidth', 1);
% ylim(ax2, [-200 20]);
% 
% ax1.Position = [0.175,0.58,0.73,0.341162790697675];
% ax2.Position = [0.175,0.17,0.73,0.341162790697674]; %0.11
% % pos1(2) = pos2(2) + pos2(4) + gap;
% % ax1.Position = pos1;
% 
% PlotToFileColorPDF(fig, 'buck_open_f', 7.5, 6);
%----------------------------绘图部分end
%% 4.电压闭环PI控制器
%引入PI控制器后的开环传递函数频域分析(开环幅频特性的过零点基本上在闭环幅频特性带宽附近，因此过零点越大，响应速度越快)
%设计思路为：-20db斜率穿越0线，相位裕度在30-60°左右
kp4 = 0.1;
ki4 = 10000;
% Gpi4 = ki4/s + kp4;
Gpi4 = ki4/s;
Gs4 = Gpi4 * Hs;
% bode(Gs4)
% hold on
% bode(Gs4/(1+Gs4))
% grid on
%% 5电流环+电压前馈
kp5 = 5;
ki5 = 40000;
k=1;
r = 0;
Gpi5 = kp5 + ki5/s;
Gs5 = Gpi5/(L*s+r);     %电压扰动全补偿
Gs5 = Gpi5*(R*C*s+1)/((R*C*s+1)*(L*s+r)+(1-k)*R);
% bode(Gs5);
% hold on
% bode(Gs5/(1+Gs5))
%% 6. 串级控制电压电流环
kpu6=1;
kiu6=3000;       %影响响应速度，较大响应较快，对相位裕度影响不大
Gpi6 = kpu6 + kiu6/s;
G61 = Gpi5 / (L*s+r);
G62 = G61/(1+G61);
G63=G62*R/(R*C*s+1);
G64=G63/(1-G63*(k-1)/Gpi5);
G65=Gpi6*G64;
G66=G65/(1+G65);
% G61;
% G62;
% G65;
bode(G65);
hold on
bode(G66);

%----------------------------绘图部分begin
% fig = figure;
% % [mag, phase, wout] = bode(Hs, w);
% [mag, phase, wout] = bode(G65);
% [GM, PM, Wcg, Wcp] = margin(G65);
% 
% mag = squeeze(mag);
% phase = squeeze(phase);
% 
% % f1 = wout / (2*pi);
% mag_db = 20 * log10(mag);
% 
% fig = figure;
% set(fig, 'Color', 'w');
% 
% ax1=subplot(2,1,1);
% semilogx(wout, mag_db, 'LineWidth', 1.2);
% box on;
% hold on;
% ylabel('幅值(dB)', 'FontName', '黑体', 'FontSize', 9);
% set(gca, ...
%     'FontName', 'Times New Roman', ...
%     'FontSize', 9, ...
%     'LineWidth', 1);
% 
% % 不在上图显示x轴标签
% set(gca, 'XTickLabel', []);
% xlim(ax1, [100 1000000]);
% ylim(ax1, [-60 50]);
% yticks(ax1, [-50 0 50]);
% % 幅值裕度标注：在 Wcg 处，幅值应为 -GM_db
% if isfinite(Wcg) && isfinite(GM) && GM > 0
%     mag_at_Wcg = -GM_db;
% 
%     plot(Wcg, mag_at_Wcg, 'ro', 'MarkerSize', 5, 'LineWidth', 1);
%     line([Wcg Wcg], [ax1.YLim(1) mag_at_Wcg], ...
%         'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
%     line([ax1.XLim(1) Wcg], [mag_at_Wcg mag_at_Wcg], ...
%         'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
% 
%     text(Wcg*1.1, mag_at_Wcg+3, ...
%         sprintf('GM = %.2f dB', GM_db), ...
%         'FontSize', 8, ...
%         'Color', 'r');
% end
% 
% ax2=subplot(2,1,2);
% semilogx(wout, phase, 'LineWidth', 1.2);
% box on;
% hold on;
% 
% xlabel('频率(rad/s)', 'FontName', '黑体', 'FontSize', 9);
% ylabel('相位(°)', 'FontName', '黑体', 'FontSize', 9);
% 
% set(gca, ...
%     'FontName', 'Times New Roman', ...
%     'FontSize', 9, ...
%     'LineWidth', 1);
% ylim(ax2, [-180 0]);
% xlim(ax2, [100 1000000]);
% yticks(ax2, [-180 -135 -90 -45 0]);
% 
% % 相位裕度标注：在 Wcp 处，相位应为 -180 + PM
% if isfinite(Wcp) && isfinite(PM)
%     phase_at_Wcp = -180 + PM;
% 
%     plot(Wcp, phase_at_Wcp, 'ro', 'MarkerSize', 5, 'LineWidth', 1);
%     line([Wcp Wcp], [ax2.YLim(1) phase_at_Wcp], ...
%         'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
%     line([ax2.XLim(1) Wcp], [phase_at_Wcp phase_at_Wcp], ...
%         'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
% 
%     text(Wcp*1.1, phase_at_Wcp+8, ...
%         sprintf('PM = %.2f°', PM), ...
%         'FontSize', 8, ...
%         'Color', 'r');
% end
% 
% ax1.Position = [0.175,0.58,0.73,0.341162790697675];
% ax2.Position = [0.175,0.17,0.73,0.341162790697674]; %0.11
% % pos1(2) = pos2(2) + pos2(4) + gap;
% % ax1.Position = pos1;
% 
% PlotToFileColorPDF(fig, 'buck_close_f', 7.5, 6);
%----------------------------绘图部分end
%% 7. ADRC参数设置
% b_adrc = 80000;
r_adrc = 10000;
% wc_adrc = 200;
% wo_adrc = 800;
f_adrc = 1e5;
f_buck = 1e5;

% 一组较好的参数（一阶能用但是有尖峰，二阶抖很大）
% b_adrc = 35000;
% wc_adrc = 16000;
% wo_adrc = 6000;

% b_adrc = 20000;
% wc_adrc = 3000;
% wo_adrc = 12000;

% b_adrc = 20000;  %一阶较好参数
% wc_adrc = 3100;
% wo_adrc = 12000;

b_adrc = 20000;  %带前馈调节
wc_adrc = 3000;
wo_adrc = 5000;

