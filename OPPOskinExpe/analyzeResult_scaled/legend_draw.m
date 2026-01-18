function create_legend(tables, output_folder,legend_type)
    % 输入参数：
    % tables - 字符串数组，包含图例文本
    % output_folder - 输出文件夹路径

    % 检查输入参数
    if ~isstring(tables)
        error('tables 必须是一个字符串数组');
    end
    if ~isfolder(output_folder)
        error('output_folder 不是一个有效的文件夹路径');
    end

    % 获取颜色数量
    num_colors = length(tables);

    % 创建一个新的图形窗口
    figure('Position', [0 0 1200 200]); % 设置图形窗口大小
    hold on;

    % 设置颜色映射
    if strcmp(legend_type,"scenes")
        H = linspace(0, 1, length(tables) + 1); % 加1是为了避免最后一个值为1（和0重复）
        H = H(1:end-1); % 去掉最后一个值
        S = 0.9 * ones(1, length(tables));
        V = 0.7 * ones(1, length(tables));
        colors = hsv2rgb([H; S; V]');
    elseif strcmp(legend_type,"self")||strcmp(legend_type,"self_ch")
        colors = [[0,0,0];[1,0,0];[0,0,1]];
    elseif strcmp(legend_type,"OPPOskin")
        colors = [[1,0,0];[0,1,0];[0,0,1]];
    elseif strcmp(legend_type,"compare")
        colors = hsv(3);
        colors(:, 2) = 0.5; 
    elseif strcmp(legend_type,"scene_vs_ori")
        colors = [[0.000, 0.447, 0.741];[0.850, 0.325, 0.098]];
    else
        H = linspace(0, 1, num_colors + 1); % 加1是为了避免最后一个值为1（和0重复）
        H = H(1:end-1); % 去掉最后一个值
        S = 0.9 * ones(1, num_colors);
        V = 0.7 * ones(1, num_colors);
        colors = hsv2rgb([H; S; V]');
    end

%% 绘制圆点和文本
    
    for i = 1:num_colors
        % 绘制圆点
        if strcmp(legend_type,"compare")
            scatter(50 + (i - 1) * 500, 50, 100*2, colors(i, :), '^',  'LineWidth', 1);       
        else
            scatter(50 + (i - 1) * 500, 50,100*2,  colors(i, :),'' ,'filled');
        end% 减小圆点大小

        % 添加文本
        text_size=20;
        text(50 + (i - 1) * 500 + 40, 50, tables(i), ... % 增加文本的水平偏移量
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', text_size, ...
            'Color', 'k'); % 设置文本颜色为黑色
    end
    
%% 
    % 绘制圆点
    if ~(strcmp(legend_type,"self")||strcmp(legend_type,"OPPOskin")||startsWith(legend_type,"self"))
        x1=(50 + (num_colors - 1) * 500)/100;
        x2=(50 + (num_colors - 1) * 500)/100*40;
        x3=(50 + (num_colors - 1) * 500)/100*100;
        y_pos=30;
        plot(x1, y_pos, 'o', 'MarkerSize', 10,'MarkerFaceColor', 'k', 'Color', 'k');    
        plot(x2, y_pos, '+', 'MarkerSize', 10 ,'MarkerFaceColor', 'k', 'Color', 'k');
        plot(x3, y_pos, 's', 'MarkerSize', 10,'MarkerFaceColor', 'm', 'Color', 'm');
    
        % 添加文本
        if endsWith(legend_type,"ch")
            text(x1 + 40, y_pos, "喜好中心", ... % 增加文本的水平偏移量
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 15, ...
                'Color', 'k'); % 设置文本颜色为黑色
                % 添加文本
            text(x2 + 40, y_pos, "原图肤色", ... % 增加文本的水平偏移量
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 15, ...
                'Color', 'k'); % 设置文本颜色为黑色
                text(x3 + 40, y_pos, "PMCC", ... % 增加文本的水平偏移量
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 15, ...
                'Color', 'k'); % 设置文本颜色为黑色
        else
            text(x1 + 40, y_pos, "ellipsoid center", ... % 增加文本的水平偏移量
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 15, ...
            'Color', 'k'); % 设置文本颜色为黑色
            % 添加文本
        text(x2 + 40, y_pos, "average original skin color", ... % 增加文本的水平偏移量
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 15, ...
            'Color', 'k'); % 设置文本颜色为黑色
            text(x3 + 40, y_pos, "PMC chart", ... % 增加文本的水平偏移量
            'HorizontalAlignment', 'left', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 15, ...
            'Color', 'k'); % 设置文本颜色为黑色
        end
    end

    axis off; % 关闭坐标轴
    xlim([0,30 + i * 500+80])
    ylim([0,100])
%%
    % 保存为 JPG 文件
    output_file = fullfile(output_folder, strcat("z_",legend_type,'.jpg'));
    % output_file = fullfile(output_folder, 'model.jpg');
    % output_file = fullfile(output_folder, 'obs.jpg');
    % output_file = fullfile(output_folder, 'makeup.jpg');
    % output_file = fullfile(output_folder, 'scene.jpg');
    % output_file = fullfile(output_folder, 'OPPOskin.jpg');
    % output_file = fullfile(output_folder, 'gender.jpg');
    exportgraphics(gcf, output_file, "Resolution", 150);
    close(gcf);
end

% 测试代码

% legend_type="scene_vs_ori";
% legend_type="self";
% legend_type="scenes_ch";
legend_type="self_ch";
% legend_type="makeup_ch";
% legend_type="gender_ch";
% legend_type="OPPOskin";

if strcmp(legend_type,"scenes")
    tables=["in-labortory","indoor","night","outdoor","sunset"];
elseif strcmp(legend_type,"scenes_ch")
    tables=["实验室","室内","夜景","室外","黄昏"];
elseif strcmp(legend_type,"self")
    tables = ["original", "model","strangers"];
elseif strcmp(legend_type,"self_ch")
    tables = ["原图肤色", "模特本人","陌生人"];
    
elseif strcmp(legend_type,"OPPOskin")
    tables=["女性带妆","女性素颜","男性"];
    % tables=["female with makeup","female without makeup","male"];
elseif strcmp(legend_type,"compare")
    tables=["Peng et al.","Cao et al.","Zeng et al."];
elseif strcmp(legend_type,"makeup")
    tables = ["with makeup", "without makeup"];
elseif strcmp(legend_type,"makeup_ch")
    tables = ["带妆", "素颜"];
elseif strcmp(legend_type,"gender")
    tables = ["female", "male"];
elseif strcmp(legend_type,"gender_ch")
    tables = ["女性", "男性"];
elseif strcmp(legend_type,"scene_vs_ori")
    tables = ["fit center", "original picture"];
end
Dtype = "efit_p";
% Dtype = "OPPO_CAT16";
output_folder = fullfile('AnalyseResults', Dtype, 'legend');
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
create_legend(tables, output_folder,legend_type);

disp(output_folder)