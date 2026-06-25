clear; close all;

data_path = 'D:\work\secondYearMaster\thesis\人种-性能对比-实验与实景数据.xlsx';
T = readtable(data_path, 'VariableNamingRule', 'preserve');

race_labels  = string(T{:, 1});
data_matrix  = T{:, 2:end};

% 找到"全部场景平均"段
idx_overall = find(contains(race_labels, '全部场景平均'));

% 后4行是四种族数据
overall = data_matrix(idx_overall+1 : idx_overall+4, :);
assert(all(~isnan(overall(:))), '全部场景平均数据含NaN, 请检查Excel');

race_names  = {'亚洲人','高加索人','南亚人','非洲人'};
model_names = {'STIM','ZJU\_SKIN','MANIQA','理论最优'};
colors = {[0.00 0.45 0.74],[0.85 0.33 0.10],[0.93 0.69 0.13],[0.50 0.50 0.50]};

%% ===== 全部场景平均: 横轴=人种, 颜色=模型 =====
figure('Name','全部场景平均','Position',[150 150 650 500]);
b = bar(overall, 'grouped');
for i = 1:4
    b(i).FaceColor = colors{i};
    b(i).EdgeColor = 'k';
    b(i).LineWidth = 0.5;
end
for i = 1:4
    xp = b(i).XEndPoints;
    yp = b(i).YEndPoints;
    text(xp, yp + 0.012, string(round(yp,2)), ...
        'HorizontalAlignment','center','VerticalAlignment','bottom', ...
        'FontSize', 9, 'Color', colors{i});
end
set(gca, 'XTickLabel', race_names, 'FontSize', 12);
ylabel('Pearson r', 'FontSize', 12);
ylim([0.45 1.02]);
grid on; box on;
leg = legend(model_names, 'Location', 'southeast', 'FontSize', 10);
leg.ItemTokenSize = [14, 10];

% 保存
out_dir = 'D:\work\secondYearMaster\thesis\figures';
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
print(gcf, fullfile(out_dir, 'race_comparison_overall.png'), '-dpng', '-r300');
fprintf('已保存至: %s\n', fullfile(out_dir, 'race_comparison_overall.png'));
