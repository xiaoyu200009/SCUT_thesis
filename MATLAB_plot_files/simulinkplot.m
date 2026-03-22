% t = current_simout2.Time;
% y = current_simout2.Data;
% % t2 = power_simout2.Time;
% % y2 = power_simout2.Data;
% 
% 
% x = t * 1e3;   % s -> ms
% % x2 = t2 * 1e3;   % s -> ms
% 
% 
% fig = figure;
% 
% h2=plot(x, y, 'LineWidth', 1.2);
% hold on; box on;
% % h2=plot(x, y, 'LineWidth', 1.2);
% 
% xlabel('时间(ms)', 'FontName', '黑体', 'FontSize', 10);
% ylabel('电流(A)', 'FontName', '黑体', 'FontSize', 10);
% 
% xlim([0,60]);
% ylim([0,0.35]);
% 
% set(gca, ...
%     'FontName', 'Times New Roman', ...
%     'FontSize', 10, ...
%     'LineWidth', 1);
% 
% % lgd = legend({'闭环控制','闭环控制+前馈'}, ...
% %        'FontName','黑体', ...
% %        'FontSize',9, ...
% %        'Location','northeast');
% 
% % 调整图窗背景为白色
% set(fig, 'Color', 'w');
% 
% PlotToFileColorPDF(fig, 'hf_cc', 7.5, 5);
%---------------------------------------------------------------------------
t = current_simout2.Time;
y = current_simout2.Data;
t2 = voltage_simout2.Time;
y2 = voltage_simout2.Data;


x = t * 1e3;   % s -> ms
x2 = t2 * 1e3;   % s -> ms


fig = figure;

yyaxis left;
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';
plot(x2, y2, 'LineWidth', 1.2);
hold on; box on;
% h2=plot(x, y, 'LineWidth', 1.2);
ylim([0 250]);
yl = ylabel('电压(V)','FontName','黑体','FontSize',10);

yyaxis right;
plot(x2, y, 'LineWidth', 1.2);
ylim([0 0.32]);
yr = ylabel('电流(A)','FontName','黑体','FontSize',10);

xlim([0,60]);
xlabel('时间(ms)', 'FontName', '黑体', 'FontSize', 10);


% ylim([0,0.35]);

set(gca, ...
    'FontName', 'Times New Roman', ...
    'FontSize', 10, ...
    'LineWidth', 1);

lgd = legend({'恒电压控制','恒电流控制'}, ...
       'FontName','黑体', ...
       'FontSize',9, ...
       'Location','southeast');

% 调整图窗背景为白色
set(fig, 'Color', 'w');

PlotToFileColorPDF(fig, 'hf_vc_cc', 15.5, 5);






% yticks(-10:10:110);
% plot(x, y1, 'color', [0 114 189]/255,'LineWidth', 1.2);hold on;
% plot(x, y2, 'color', [217, 83, 24]/255,'LineStyle', '-','LineWidth', 1.2);
% yticks([-2 0 4 8 12 16]);
% yticklabels({'','10', '100','1000'});
% ylim([-2 16]);
% yl = ylabel('电压(V)','FontName','黑体','FontSize',10);
% 
% yyaxis right;
% yticks(-2:2:8);
% plot(x, y3, 'color', [236, 176, 32]/255,'LineWidth', 1.2);
% ylim([-2 8]);
% yr = ylabel('电流(A)','FontName','黑体','FontSize',10);






