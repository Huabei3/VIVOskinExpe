function adjust_fig(output_folder, opts)
    % adjust_fig - 批量精修 fig 文件
    % 输入:
    %   output_folder: 包含 .fig 文件的文件夹路径
    %   opts: 包含参数的结构体，需具备以下字段:
    %       opts.lim_min        - 坐标轴最小值
    %       opts.lim_max        - 坐标轴最大值
    %       opts.targetFontSize - 字体大小
    %       opts.margin         - Label 距离轴的偏移量
    
    % 检查输出路径
    fig_list = dir(fullfile(output_folder, "*.fig"));
    fig_list = fig_list(~contains({fig_list.name}, 'adjusted'));
    if isfield(opts, 'dir_figs')
        fig_list=opts.dir_figs;
    end

    for k = 1:length(fig_list)        
        [~, name, ext] = fileparts(fig_list(k).name);
        fig_path = fullfile(output_folder, fig_list(k).name);
        % 1. 以后台模式打开 fig
        tempFig = openfig(fig_path, 'visible');
        ax = gca;
        if isfield(opts, 'label_type') && strcmp(opts.label_type, "MCDM")
            % --- MCDM 模式定制优化 ---            
            % 1. 自动获取当前数据的 X 轴范围，并留出一点边距
            % 不要硬编码 [0, 2.6]，改用自动获取 + 缩放
            all_children = get(ax, 'Children');
            x_data = [];
            for idx = 1:numel(all_children)
                try
                    x_data = [x_data, all_children(idx).XData(:)'];
                catch
                end
            end
            
            if ~isempty(x_data)
                x_min = min(x_data) - 0.5;
                x_max = max(x_data) + 0.5;
                xlim(ax, [x_min, x_max]);
            else
                xlim(ax, [0.5, 4.5]); % 假设有 4 组人种数据的通用保底值
            end

            % 2. 旋转标签
            % set(ax, 'XTickLabelRotation', 45);
            
            % 3. 物理拉宽坐标轴容器
            ax.Units = 'normalized';
            pos = ax.Position;
            
            % 重点：拉宽容器的同时，必须确保 left 留够空间给 Y 轴标签
            % 如果 pos(3) 增加，确保不会超出画布右侧 (pos(1) + pos(3) < 1)
            original_right_edge = pos(1) + pos(3);
            new_width = pos(3) * 1.3; % 宽度拉伸 30%
            
            pos(3) = new_width;
            % 如果拉宽后出界了，整体往左挪
            if (pos(1) + pos(3) > 0.95)
                pos(1) = 0.95 - pos(3); 
            end
            
            % 确保 pos(1) 不小于 margin，否则 Y 轴刻度会消失
            pos(1) = max(pos(1), 0.12); 
            
            ax.Position = pos;
            
            % 4. 强制设置 Y 轴刻度对齐 (建议增加)
            ylim(ax, [1, 3]);
            ax.YTick = 1:0.5:3;
        elseif isfield(opts, 'label_type') && strcmp(opts.label_type, "nation")
            % 2. 调节坐标轴范围和刻度
            xlim(ax, [opts.lim_min, opts.lim_max]);
            ylim(ax, [opts.lim_min, opts.lim_max]);
            ax.XTick = opts.lim_min:10:opts.lim_max;
            ax.YTick = opts.lim_min:10:opts.lim_max;
        end
        if isfield(opts, 'axis_limits')
            xlim(ax, [opts.axis_limits(k,1), opts.axis_limits(k,2)]);
            ylim(ax, [opts.axis_limits(k,3), opts.axis_limits(k,4)]);
        end
        if isfield(opts, 'axis_ticks')
            ax.XTick = opts.axis_limits(k,1):opts.axis_ticks(k):opts.axis_limits(k,2);
            ax.YTick = opts.axis_limits(k,3):opts.axis_ticks(k):opts.axis_limits(k,4);
        end
        % 获取图中所有的条形图对象
        if isfield(opts,"bar_interval")
            hBars = findobj(ax, 'Type', 'Bar');
            if ~isempty(hBars)
                set(hBars, 'BarWidth', opts.bar_interval); 
            end
        end
        

        % 3. 调节字号和标签
        if isfield(opts,"if_rotate")&&opts.if_rotate
            set(ax, 'XTickLabelRotation', 45);
        end


        set(ax, 'FontSize', opts.targetFontSize);
        % xlabel(ax, '$a^*$', 'Interpreter', 'latex', 'FontSize', 1.5*opts.targetFontSize);
        % ylabel(ax, '$b^*$', 'Interpreter', 'latex', 'FontSize', 1.5*opts.targetFontSize);
        
        % 4. 调节 Label 间距
        if isfield(opts, 'margin')&&(isfield(opts, 'margin_type')&& ...
                strcmp(opts.margin_type,"Position"))
            drawnow; 
            xPos = get(ax.XLabel, 'Position');
            set(ax.XLabel, 'Position', [xPos(1), xPos(2) - opts.margin, xPos(3)]);
            yPos = get(ax.YLabel, 'Position');
            set(ax.YLabel, 'Position', [yPos(1) - opts.margin, yPos(2), yPos(3)]);
        end

        if isfield(opts, 'margin')&&~(isfield(opts, 'margin_type')&& ...
                strcmp(opts.margin_type,"Position"))
            set(ax.XLabel, 'Units', 'normalized');
            set(ax.YLabel, 'Units', 'normalized');

            % 调整位置：
            % XLabel: 横向居中(0.5)，纵向在下方(负值，opts.margin 此时应建议设为 0.1 左右)
            ax.XLabel.Position(1) = 0.5; 
            ax.XLabel.Position(2) = -opts.margin; 

            % YLabel: 纵向居中(0.5)，横向在左侧(负值)
            ax.YLabel.Position(1) = -opts.margin; 
            ax.YLabel.Position(2) = 0.5;
        end

        % 5. 确保所有的 Text 对象字号统一（如之前的 (a), (b) 标签）
        % set(findobj(tempFig, 'Type', 'Text'), 'FontSize', opts.targetFontSize);
        
        % 6. 保存并导出
        % 注意：如果是为了之后的拼接，导出高清 jpg 有助于预览，
        % 但真正拼接时是读入这里的 .fig 文件。
        % 构造新的文件名：在原名后加 _adjusted
        new_name = [name, 'adjusted'];
        fig_path_new = fullfile(output_folder, [new_name, '.fig']);
        jpg_path_new = fullfile(output_folder, [new_name, '.jpg']);
        
        % 保存为新的 fig 文件
        savefig(tempFig, fig_path_new);
        % 导出为新的 jpg 文件
        exportgraphics(tempFig, jpg_path_new, 'Resolution', 500);
        
        close(tempFig);
        fprintf('Refined: %s\n', fig_list(k).name);
    end
end