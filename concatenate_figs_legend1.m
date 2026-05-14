function concatenate_figs_legend1(save_folder, figFiles, n_col, ...
    legend_file, legen_mode, legend_labels,gapX,label_Y)
    % Concatenate multiple fig files into a main figure, then overlay legend.
    % legen_mode: 'load' (load legend fig) or 'draw' (draw legend by code).

    targetFontSize = 12;

    if nargin < 4 
        legend_file = 'legend.fig';
    end
    if nargin < 5 
        legen_mode = 'load';
    end


    % Resolve legend path (absolute path preferred if provided)
    if isfile(legend_file)
        legend_path = legend_file;
    else
        legend_path = fullfile(save_folder, legend_file);
    end

    numFigs = numel(figFiles);
    n_row = ceil(numFigs / n_col);

    % 1) Read source aspect ratios from primary axes
    origAspectRatios = zeros(1, numFigs);
    for i = 1:numFigs
        if isfield(legend_labels,"dir_figs")
            src_path = fullfile(legend_labels.dir_figs(i).folder, legend_labels.dir_figs(i).name);
        else
            src_path = fullfile(save_folder, figFiles{i});
        end
        tempFig = openfig(src_path, 'invisible');
        tempAx = get_primary_axes(tempFig);

        tempAx.Units = 'normalized';
        origPos = tempAx.Position;
        origAspectRatios(i) = origPos(3) / max(origPos(4), eps);
        close(tempFig);
    end

    % 2) Create main canvas
    % 修改后：让宽度更宽，高度更紧凑（例如将宽度系数改为 700）
    if isfield(legend_labels,"fig_wh_base")
        figWidth = legend_labels.fig_wh_base(1) * n_col;         % 增大每列占用的宽度像素
        figHeight = legend_labels.fig_wh_base(2) * n_row + 120;  % 适当减小每行高度和图例预留空间
    else
        figWidth = 500 * n_col;
        figHeight = 450 * n_row + 150;
    end

    mainFig = figure('Units', 'pixels', 'Position', [100, 100, figWidth, figHeight], 'Color', 'w');

    if isfield(legend_labels,"marginL")
        marginL=legend_labels.marginL;
    else
        marginL=0.08;
    end
    marginR = 0.05;
    marginTop = 0.05;
    legendHeightNorm = 100 / figHeight;
    if isfield(legend_labels,"label_type")&&strcmp(legend_labels.label_type,"skinVIVO")
        legendHeightNorm=legendHeightNorm.*1.5;
    end
    availableH = 1 - marginTop - legendHeightNorm - 0.05;

    baseWidth = (1 - marginL - marginR) / n_col;
    baseHeight = availableH / n_row;
    if isfield(legend_labels,"label_type")&&strcmp(legend_labels.label_type,"hml")
        baseHeight=baseHeight.*0.8;
    end
    % Row gap between sub-figures (default uses baseHeight)
    if isfield(legend_labels, 'row_gap')
        row_gap = legend_labels.row_gap;
    else
        row_gap = 0;  % 0 means use default baseHeight spacing
    end
    % col_gap: 同排子图额外间距（normalized，正值增大间距，负值缩小）
    if isfield(legend_labels, 'col_gap')
        col_gap_extra = legend_labels.col_gap;
    else
        col_gap_extra = 0;
    end
    % posY_bottom: 整体绘图区底部基准（normalized），增大可让整体上移
    if isfield(legend_labels, 'posY_bottom')
        posY_bottom = legend_labels.posY_bottom;
    else
        posY_bottom = legendHeightNorm;
    end
    % gapX = 0.15;

    for i = 1:numFigs
        currRow = ceil(i / n_col);
        currCol = mod(i - 1, n_col) + 1;
        if isfield(legend_labels,"dir_figs")
            temp_path = fullfile(legend_labels.dir_figs(i).folder, legend_labels.dir_figs(i).name);
        else
            temp_path = fullfile(save_folder, figFiles{i});
        end
        tempFig = openfig(temp_path, 'invisible');
        tempAx = get_primary_axes(tempFig);

        currAspectRatio = origAspectRatios(i);
        if isfield(legend_labels,"label_type")
            if strcmp(legend_labels.label_type,"scene")||strcmp(legend_labels.label_type,"obs")
                h_space = baseHeight * 0.7;
            elseif strcmp(legend_labels.label_type,"hml")
                h_space = baseHeight * 0.85;
            elseif strcmp(legend_labels.label_type,"skinVIVO")
                h_space = baseHeight * 1.5;
            else
                h_space = baseHeight * 0.7;
            end
        else
            h_space = baseHeight * 0.85;
        end

        w_space = h_space * currAspectRatio;

        

        if w_space > baseWidth * 0.95
            w_space = baseWidth * 0.95;
            h_space = w_space / max(currAspectRatio, eps);
        end
        if isfield(legend_labels,"label_type")&&strcmp(legend_labels.label_type,"skinVIVO")
            w_space=w_space*1.5;
            h_space=h_space*1.5;
        end

    
        posX = marginL + (currCol - 1) * baseWidth - (currCol - 1) * gapX + (currCol - 1) * col_gap_extra;
        if row_gap == 0
            posY = posY_bottom + (n_row - currRow) * baseHeight + (baseHeight - h_space) / 2;
        else
            posY = posY_bottom + (n_row - currRow) * (baseHeight + row_gap) + (baseHeight - h_space) / 2;
        end
        if isfield(legend_labels,"label_type")&&strcmp(legend_labels.label_type,"skinVIVO")&&i==5
            posX=posX+0.04;
        end
        if isfield(legend_labels,"Y_shift")
            posY=posY+legend_labels.Y_shift;
        end

        subAx = axes('Parent', mainFig, 'Units', 'normalized', 'Position', [posX, posY, w_space, h_space]);

        copyobj(allchild(tempAx), subAx);
        % 1. 查找原图中与当前坐标轴关联的 Colorbar
        origColorbar = findobj(tempFig, 'Type', 'Colorbar');
        
        % 2. 如果存在 Colorbar，则在子图中重建
        if ~isempty(origColorbar)
            % 创建新的 Colorbar 并关联到 subAx
            newCb = colorbar(subAx);
            
            % 同步关键属性（颜色范围、刻度、标签、外观）
            newCb.Limits = origColorbar.Limits;
            newCb.Ticks = origColorbar.Ticks;
            newCb.TickLabels = origColorbar.TickLabels;
            newCb.Label.String = origColorbar.Label.String;
            newCb.Label.Interpreter = origColorbar.Label.Interpreter;
            newCb.Location = origColorbar.Location; % 通常是 'eastoutside'
            
            % 如果有特定的 Colormap，也需要同步给 subAx 所在的 Figure
            % 注意：MATLAB 一个 Figure 默认一套 Colormap，如果不同子图颜色表不同，
            % 需要在 R2020b 及以后版本使用 colormap(subAx, ...)
            colormap(subAx, colormap(tempFig)); 
        end

        newXlabel = copyobj(tempAx.XLabel, subAx);
        newYlabel = copyobj(tempAx.YLabel, subAx);
        newTitle = copyobj(tempAx.Title, subAx);


        subAx.XLim = tempAx.XLim;
        subAx.YLim = tempAx.YLim;
        subAx.XTick = tempAx.XTick;
        subAx.YTick = tempAx.YTick;
        % === 新增：同步刻度标签内容（解决数字变成文字的问题） ===
        subAx.XTickLabel = tempAx.XTickLabel;
        subAx.YTickLabel = tempAx.YTickLabel;
        % 如果原图使用了刻度旋转，也一并同步
        subAx.XTickLabelRotation = tempAx.XTickLabelRotation;
        %==========
        subAx.Box = 'on';
        if ~(isfield(legend_labels, 'label_type') && strcmp(legend_labels.label_type, 'MCDM'))
            subAx.DataAspectRatio = tempAx.DataAspectRatio;
            subAx.PlotBoxAspectRatio = tempAx.PlotBoxAspectRatio;
        end
        if ~isfield(legend_labels, 'preserve_text_fontsize') || ~legend_labels.preserve_text_fontsize        
            if isfield(legend_labels, 'fontSizeScale')
                set(subAx, 'FontSize', legend_labels.fontSizeScale * targetFontSize, ...
                    'LabelFontSizeMultiplier', 1.0, 'TitleFontSizeMultiplier', 1.0);
            else
                set(subAx, 'FontSize', targetFontSize, ...
                    'LabelFontSizeMultiplier', 1.0, 'TitleFontSizeMultiplier', 1.0);
            end
        end
        % === tickFontScale：独立控制 xticks & yticks 字体大小 ===
        if isfield(legend_labels, 'tickFontSize')
            subAx.FontSize = legend_labels.tickFontSize;
        elseif isfield(legend_labels, 'tickFontScale')
            subAx.FontSize = legend_labels.tickFontScale * targetFontSize;
        end
        %==========
        % set([newXlabel, newYlabel, newTitle], 'FontSize', targetFontSize, 'FontWeight', 'normal');
        if isfield(legend_labels, 'fontSizeScale')
            set(newTitle, 'FontSize', legend_labels.fontSizeScale * targetFontSize, 'FontWeight', 'bold');
        else
            set(newTitle, 'FontSize', targetFontSize, 'FontWeight', 'bold');
        end

        if isfield(legend_labels,"label_type")&&strcmp(legend_labels.label_type,"attr")
            set(newXlabel, 'FontSize', targetFontSize, 'FontWeight', 'normal');
            set(newYlabel, 'FontSize', targetFontSize, 'FontWeight', 'normal');
        else
            set(newXlabel, 'FontSize', targetFontSize, 'FontWeight', 'normal');
            set(newYlabel, 'FontSize', targetFontSize, 'FontWeight', 'normal');
        end

        if isfield(legend_labels,"label_fontSize") && ~isfield(legend_labels,"fontSizeScale")
            set(newXlabel, 'FontSize', legend_labels.label_fontSize, 'FontWeight', 'normal');
            set(newYlabel, 'FontSize', legend_labels.label_fontSize, 'FontWeight', 'normal');
        elseif isfield(legend_labels,"fontSizeScale")
            set(newXlabel, 'FontSize', legend_labels.fontSizeScale*targetFontSize, ...
                'FontWeight', 'normal');
            set(newYlabel, 'FontSize', legend_labels.fontSizeScale*targetFontSize, ...
                'FontWeight', 'normal');
        end

        % === label 偏移支持（normalized 单位） ===
        if isfield(legend_labels, 'label_x_offset')
            % label_x_offset: xlabel 垂直偏移，正值向下（远离x轴）
            curPos = newXlabel.Position;
            newXlabel.Position = [curPos(1), curPos(2) + legend_labels.label_x_offset, curPos(3)];
        end
        if isfield(legend_labels, 'label_y_offset')
            % label_y_offset: ylabel 水平偏移，正值向左（远离y轴）
            curPos = newYlabel.Position;
            newYlabel.Position = [curPos(1) + legend_labels.label_y_offset, curPos(2), curPos(3)];
        end
        % 设置Interpreter类型
        if isfield(legend_labels, 'interpreter_type')
            legend_interpreter = legend_labels.interpreter_type;
        else
            legend_interpreter = 'tex';
        end
        set([newXlabel, newYlabel], 'Interpreter', legend_interpreter);
        % axis(subAx, 'tight'); % 自动去掉四周多余空白
        if isfield(legend_labels,"x_data")
            subAx.XLim = [min(legend_labels.x_data)-0.9, max(legend_labels.x_data)+0.08]; % 假设你能拿到数据范围
        end
        if isfield(legend_labels,"y_data")
            subAx.YLim = [min(min(legend_labels.y_data))-0.5, max(max(legend_labels.y_data))+0.5]; % 假设你能拿到数据范围
        end
        % 修正 ylabel 水平位置（防止 XLim/YLim 变化后位置漂移）
        % 计算相对位置：ylabel 在 subplot 的左侧
        % ylabel_offset = 0.5 * (subAx.YLim(2) - subAx.YLim(1));
        % newYlabel.Position = [subAx.XLim(1) - ylabel_offset, mean(subAx.YLim), 0];
        % 
        % % 同样修正 xlabel 位置
        % xlabel_offset = 0.5 * (subAx.XLim(2) - subAx.XLim(1));
        % newXlabel.Position = [mean(subAx.XLim), subAx.YLim(1) - xlabel_offset, 0];
        % === 插入labels ===
        if isfield(legend_labels,"if_label")&&legend_labels.if_label
            if isfield(legend_labels,"labels_lower_right")
                letter_label=legend_labels.labels_lower_right(i);
            else
                letter_label = ['(', char('a' + i - 1), ')'];
            end
            if isfield(legend_labels, 'fontSizeScale')
                text(subAx, 0.95, 0.05, letter_label, 'Units', 'normalized', ...
                    'FontSize', legend_labels.fontSizeScale * targetFontSize, 'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
            else
                text(subAx, 0.95, 0.05, letter_label, 'Units', 'normalized', ...
                    'FontSize', targetFontSize, 'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
            end
        end


            total_content_width = (n_col * baseWidth) - ((n_col - 1) * gapX);
    %------------------
    % 判断是否需要创建 colorbar
    need_colorbar = false;
    if isfield(legend_labels, 'color_limits')
        if isfield(legend_labels, 'colorbar_mode') && strcmp(legend_labels.colorbar_mode, 'cover_rows')
            % cover_rows 模式：在最后一个子图后创建
            need_colorbar = (i == numFigs);
        else
            % 默认模式：每行最后一个子图后创建
            need_colorbar = (mod(i, n_col) == 0) || strcmp(legend_labels.label_type, 'CT');
        end
    end
    
    if need_colorbar
        % 检查 colorbar_mode
        if isfield(legend_labels, 'colorbar_mode') && strcmp(legend_labels.colorbar_mode, 'cover_rows')
            % cover_rows 模式：colorbar 高度覆盖所有 rows + legend
            % 计算包含 legend 在内的总高度
            total_rows_with_legend = n_row * baseHeight;
            % 限制最大值不超过1
            total_rows_with_legend = min(total_rows_with_legend, 1.0);
            % colorbar 位置：从 legend 顶部开始，覆盖所有行和底部 legend
            cb_x_pos = marginL + total_content_width - 0.1;
            cb_y_pos = legendHeightNorm;
            cbAx = axes('Parent', mainFig, 'Units', 'normalized', ...
                'Position', [cb_x_pos, cb_y_pos, 0.02, total_rows_with_legend], ...
                'Visible', 'off');
            
            colormap(cbAx, 'copper');
            if isfield(legend_labels, 'cmap')
                colormap(cbAx, legend_labels.cmap);
            end
            clim(cbAx, legend_labels.color_limits);
            if isfield(legend_labels,"label_fontSize") && ~isfield(legend_labels,"fontSizeScale")
                cb = colorbar(cbAx, 'eastoutside','FontSize', ...
                    legend_labels.label_fontSize*targetFontSize);
            else
                cb = colorbar(cbAx, 'eastoutside','FontSize',targetFontSize);
            end
            
            if strcmp(legend_labels.label_type, 'CT')
                cb.Label.String = 'CCT';
            end
            
            cb.Label.Interpreter = 'tex';
            disp('cover_rows colorbar set');
            cb.Label.FontSize = targetFontSize;
            % cbLabelFontAngle: 'normal' or 'italic'
            if isfield(legend_labels, 'cbLabelFontAngle')
                cb.Label.FontAngle = legend_labels.cbLabelFontAngle;
            else
                cb.Label.FontAngle = 'italic';
            end
            cb.Units = 'normalized';
        else
            % 默认模式：colorbar 在当前行最后一个子图的右边
            % 在主图右侧创建一个不可见的坐标轴用于挂载全局 Colorbar
            % 位置建议在最右侧子图的旁边
            cbAx = axes('Parent', mainFig, 'Units', 'normalized', ...
                'Position', [marginL + total_content_width - 0.05, posY, 0.01, h_space], ...
                'Visible', 'off');
            
            colormap(cbAx, 'copper'); % 明确指定使用 copper 渐变
            if isfield(legend_labels, 'cmap')
                colormap(cbAx, legend_labels.cmap);
            end
            clim(cbAx, legend_labels.color_limits);
            
            cb = colorbar(cbAx, 'eastoutside');
            
            % 设置标签内容
            if strcmp(legend_labels.label_type, 'hml')
                if strcmp(legend_labels.color_type, "lightness")
                    cb.Label.String = 'L^*';
                else
                    cb.Label.String = 'luminance (cd/m^2)';
                end
            elseif strcmp(legend_labels.label_type, 'CT')
                cb.Label.String = 'CCT';
            end
            
            cb.Label.Interpreter = 'tex';
            cb.Label.FontSize = targetFontSize;
            % cbLabelFontAngle: 'normal' or 'italic'
            if isfield(legend_labels, 'cbLabelFontAngle')
                cb.Label.FontAngle = legend_labels.cbLabelFontAngle;
            else
                cb.Label.FontAngle = 'italic';
            end
            
            % 确保 Colorbar 不会因为自动调整而改变主图布局
            cb.Units = 'normalized';
        end
    end
    %--------------------
        close(tempFig);
    end

    output_path = fullfile(save_folder, 'concatenated');
    if ~exist(output_path, 'dir')
        mkdir(output_path);
    end
    savefig(mainFig, fullfile(output_path, 'Combined1.fig'));

    % 3) Overlay legend

    leg_w = min(total_content_width, 0.8);
    leg_h = 0.15;
    if isfield(legend_labels, 'label_type')
        if strcmp(legend_labels.label_type, 'attr')
            leg_x = marginL-0.02;
        elseif strcmp(legend_labels.label_type, 'scene')
            leg_x = marginL+0.05;
        elseif strcmp(legend_labels.label_type, 'obs')
            leg_x = marginL+0.05;
        elseif strcmp(legend_labels.label_type, 'skinVIVO')
            leg_x = marginL+0.1;
        else
            leg_x = marginL - 0.05;
        end
    else
        leg_x = marginL - 0.05;
    end


    if isfield(legend_labels, 'leg_x_shift')
        leg_x = marginL + legend_labels.leg_x_shift;
    end
    % leg_x = marginL + (total_content_width - leg_w) / 2;
    leg_y = 0.02;

    if strcmpi(legen_mode, 'draw')
        draw_legend_overlay(mainFig, [leg_x, leg_y, leg_w, leg_h], targetFontSize, legend_labels,label_Y);
    elseif strcmpi(legen_mode, 'load')
        if isfile(legend_path)
            legFigSource = openfig(legend_path, 'invisible');

            % Force legend source fonts to match main figure font size before export.
            set(findall(legFigSource, 'Type', 'text'), 'FontSize', targetFontSize, 'FontWeight', 'normal');
            set(findall(legFigSource, 'Type', 'legend'), 'FontSize', targetFontSize, 'FontWeight', 'normal');

            [legendRGB, legendAlpha] = render_legend_image(legFigSource);
            close(legFigSource);

            if ~isempty(legendRGB)
                targetAx = axes('Parent', mainFig, 'Units', 'normalized', ...
                    'Position', [leg_x, leg_y, leg_w, leg_h], ...
                    'Color', 'none', 'Visible', 'off');

                hImg = image('Parent', targetAx, 'CData', legendRGB);
                axis(targetAx, 'image');
                axis(targetAx, 'off');
                set(targetAx, 'YDir', 'reverse', 'XDir', 'normal');

                if ~isempty(legendAlpha)
                    hImg.AlphaData = legendAlpha;
                else
                    whiteMask = legendRGB(:, :, 1) > 250 & legendRGB(:, :, 2) > 250 & legendRGB(:, :, 3) > 250;
                    hImg.AlphaData = double(~whiteMask);
                end

                uistack(targetAx, 'top');
            end
        end

    end

    % 4) Save result
    savefig(mainFig, fullfile(output_path, 'Combined_legend1.fig'));
    saveas(mainFig, fullfile(output_path, 'Combined_legend1.png'));
    print(mainFig, fullfile(output_path, 'Combined_legend1.eps'), '-depsc');
    fprintf('Concatenation finished. Output saved to: %s\n', output_path);
end


function draw_legend_overlay(mainFig, legendPos, targetFontSize, legend_labels, label_Y)
    labels_row1 = legend_labels.labels_row1;
    labels_row2 = legend_labels.labels_row2;
    markers_row2 = legend_labels.markers_row2;
    markers_colors = legend_labels.markers_colors;
    markers_face_colors = legend_labels.markers_face_colors;
    colors_row1 = legend_labels.colors_row1;
    
    % 获取缩放后的图例字号
    if isfield(legend_labels, 'fontSizeScale')
        legendFontSize = legend_labels.fontSizeScale * targetFontSize;
    else
        legendFontSize = targetFontSize;
    end
    
    % 获取换行配置
    if isfield(legend_labels,"n_col1")
        n_col1 = legend_labels.n_col1; 
    else
        n_col1=length(labels_row1);
    end
    if isfield(legend_labels,"n_col2")
        n_col2 = legend_labels.n_col2;
    else
        n_col2=length(labels_row2);
    end

    legAx = axes('Parent', mainFig, 'Units', 'normalized', ...
        'Position', legendPos, 'Color', 'none', 'Visible', 'off');
    hold(legAx, 'on'); xlim(legAx, [0, 1]); ylim(legAx, [0, 1]);
    
    figPx = getpixelposition(mainFig);
    legPxW = max(1, figPx(3) * legendPos(3));
    
    % 布局间距参数
    if isfield(legend_labels, 'sidePad')
        sidePad = legend_labels.sidePad;
    else
        sidePad = 0.1;
    end
    if isfield(legend_labels,"colGap1_scale")
        colGap1 = (1 / (n_col1 + 0.5)).*legend_labels.colGap1_scale; 
    else
        colGap1 = 1 / (n_col1 + 0.5); 
    end
    if isfield(legend_labels,"colGap2_scale")
        colGap2 = (1 / (n_col2 + 0.5))*legend_labels.colGap2_scale;
    else
        colGap2 = 1 / (n_col2 + 0.5);
    end
    rowStep = 0.35; % 换行时的垂直间距
    if isfield(legend_labels,"rowStep")
        rowStep = legend_labels.rowStep;
    end
    if isfield(legend_labels,"iconTextGap")
        iconTextGap = legend_labels.iconTextGap;
    else
        iconTextGap = 0.014;
    end

    % --- 绘制第一组 (labels_row1) ---
    
    for k = 1:numel(labels_row1)
        currR = floor((k-1) / n_col1); % 当前行
        currC = mod(k-1, n_col1);      % 当前列
        
        tx = sidePad + currC * colGap1;
        ty = label_Y - currR * rowStep;
        if isfield(legend_labels, 'label_type') && strcmp(legend_labels.label_type, 'attr1')
            text(legAx, tx , ty, num2str(k), ...
                'FontSize', legendFontSize, 'VerticalAlignment', 'middle', ...
                'Interpreter', 'none','Color',colors_row1(k, :),'FontWeight','bold');
        elseif isfield(legend_labels, 'label_type') && strcmp(legend_labels.label_type, 'compare_nation')
            text_char=char(labels_row1{k});
            if isfield(legend_labels, 'text_type') && strcmp(legend_labels.text_type, 'ch')
                i_last_others=length(labels_row1)-4;
                colors_last4=[[0 0 0];[0 0 0];[0 0 0];[0 0 0]];
                colors_last4_face=[[0 0 0];[0 0 0];[1 1 1];[1 1 1]];
            else
                i_last_others=length(labels_row1);
                colors_last4=[[0 0 0];[0 0 0];];
                colors_last4_face=[[1 1 1];[1 1 1]];
                
            end
            % plot(legAx, tx, ty, 'o', ...
            %     'MarkerFaceColor', colors_row1(k, :), ...
            %     'MarkerEdgeColor', 'none', 'MarkerSize', 10, 'Clipping', 'off');

            if k>i_last_others
                plot(legAx, tx, ty, legend_labels.markers_row1_last4{k-i_last_others}, ...
                    'MarkerFaceColor', colors_last4_face(k-i_last_others, :), ...
                    'MarkerEdgeColor', colors_last4(k-i_last_others, :), ...
                    'MarkerSize', 10, 'Clipping', 'off',"LineWidth",1);
            else
                plot(legAx, tx, ty, 'o', ...
                'MarkerFaceColor', colors_row1(k, :), ...
                'MarkerEdgeColor', 'none', 'MarkerSize', 10, 'Clipping', 'off');
                % text(legAx, tx , ty, text_char(1), ...
                %     'FontSize', targetFontSize, 'VerticalAlignment', 'middle', ...
                %     'Interpreter', 'none','Color',colors_row1(k, :),'FontWeight','bold');
            end
            elseif isfield(legend_labels, 'label_type') && strcmp(legend_labels.label_type, 'only_my')
            i_last_others=length(labels_row1)-2;
            if k>i_last_others
                % 最后两个：用 markers_row1_last2，颜色用 colors_row1(k,:) ①
                plot(legAx, tx, ty, legend_labels.markers_row1_last2{k-i_last_others}, ...
                    'MarkerFaceColor', colors_row1(k, :), ...
                    'MarkerEdgeColor', colors_row1(k, :), ...
                    'MarkerSize', 10, 'Clipping', 'off');
            else
                % 其余：画 'x' marker，颜色用 colors_row1(k,:) ①②
                plot(legAx, tx, ty, 'x', ...
                    'MarkerEdgeColor', colors_row1(k, :), ...
                    'LineWidth', 1.5, ...
                    'MarkerSize', 10, 'Clipping', 'off');
            end
        else
            if isfield(legend_labels, 'plot_style_row1')
                plot(legAx, tx, ty, legend_labels.plot_style_row1{k}, 'MarkerFaceColor', colors_row1(k, :), ...
                    'MarkerEdgeColor', 'none', 'MarkerSize', 10, 'Clipping', 'off');
            else
                plot(legAx, tx, ty, 'o', 'MarkerFaceColor', colors_row1(k, :), ...
                    'MarkerEdgeColor', 'none', 'MarkerSize', 10, 'Clipping', 'off');
            end
        end
        % === labels_row1 文字渲染 ===
        if isfield(legend_labels, 'interpreter_type')
            curr_interpreter = char(legend_labels.interpreter_type);
        else
            curr_interpreter = 'none';
        end
        label_str = char(labels_row1{k});  % 确保 char 类型
        text(legAx, tx + iconTextGap, ty, label_str, ...
            'FontSize', legendFontSize, 'VerticalAlignment', 'middle', 'Interpreter', curr_interpreter);
    end
    

    % 计算第二组的起始高度 (紧跟在第一组最后一行之后)
    numRowsRow1 = ceil(numel(labels_row1) / n_col1);
    row2Start_Y = label_Y - numRowsRow1 * rowStep - 0.1; 

    % --- 绘制第二组 (labels_row2) ---
    if ~isempty(labels_row2)
        for k = 1:numel(labels_row2)
            currR = floor((k-1) / n_col2);
            currC = mod(k-1, n_col2);
            
            tx = sidePad + currC * colGap2;
            ty = row2Start_Y - currR * rowStep;
            
            plot(legAx, tx, ty, markers_row2{k}, 'Color', markers_colors(k, :), ...
                'MarkerFaceColor', markers_face_colors(k, :), ...
                'MarkerSize', 10, 'LineWidth', 1.5, 'Clipping', 'off');
            text(legAx, tx + iconTextGap, ty, labels_row2{k}, ...
                'FontSize', legendFontSize, 'VerticalAlignment', 'middle', 'Interpreter', 'none');
        end
    end
    uistack(legAx, 'top');
end
function ax = get_primary_axes(figH)
    allAxes = findall(figH, 'Type', 'Axes');
    if isempty(allAxes)
        error('No axes found in source figure.');
    end

    score = zeros(1, numel(allAxes));
    for k = 1:numel(allAxes)
        a = allAxes(k);
        isLegendLike = strcmpi(a.Tag, 'legend') || strcmpi(a.Visible, 'off');
        nChild = numel(allchild(a));
        score(k) = nChild - 1000 * double(isLegendLike);
    end

    [~, idx] = max(score);
    ax = allAxes(idx);
end

function [rgb, alpha] = render_legend_image(legFig)
    rgb = [];
    alpha = [];

    tmp_png = [tempname, '.png'];

    try
        exportgraphics(legFig, tmp_png, 'Resolution', 300, 'BackgroundColor', 'none');
    catch
        saveas(legFig, tmp_png);
    end

    if ~isfile(tmp_png)
        return;
    end

    [img, ~, a] = imread(tmp_png);
    delete(tmp_png);

    if ndims(img) == 2
        img = repmat(img, [1, 1, 3]);
    elseif size(img, 3) > 3
        img = img(:, :, 1:3);
    end

    rgb = img;
    if ~isempty(a)
        alpha = double(a) / 255;
    end
end

function s = default_legend_labels()
    s.labels_row1 = {'Asian', 'Caucasian', 'South Asian', 'African'};
    s.labels_row2 = {'female', 'male'};
    s.markers_row2 = {'o', 'x'};
    s.markers_colors = [0 0 0; 0 0 0];
    s.colors_row1 = [ ...
        0.85 0.10 0.10; ...
        0.40 0.75 0.15; ...
        0.20 0.75 0.80; ...
        0.45 0.20 0.85];
end

function s = fill_default_legend_labels(s)
    d = default_legend_labels();

    if ~isfield(s, 'labels_row1') || isempty(s.labels_row1)
        s.labels_row1 = d.labels_row1;
    end
    if ~isfield(s, 'labels_row2') || isempty(s.labels_row2)
        s.labels_row2 = d.labels_row2;
    end
    if ~isfield(s, 'markers_row2') || isempty(s.markers_row2)
        s.markers_row2 = d.markers_row2;
    end
    if ~isfield(s, 'markers_colors') || isempty(s.markers_colors)
        s.markers_colors = d.markers_colors;
    end
    if ~isfield(s, 'colors_row1') || isempty(s.colors_row1)
        s.colors_row1 = d.colors_row1;
    end

    n1 = numel(s.labels_row1);
    n2 = numel(s.labels_row2);

    if size(s.colors_row1, 1) < n1
        s.colors_row1 = [s.colors_row1; repmat(s.colors_row1(end, :), n1 - size(s.colors_row1, 1), 1)];
    end
    if size(s.colors_row1, 1) > n1
        s.colors_row1 = s.colors_row1(1:n1, :);
    end

    if numel(s.markers_row2) < n2
        s.markers_row2 = [s.markers_row2, repmat(s.markers_row2(end), 1, n2 - numel(s.markers_row2))];
    end
    if numel(s.markers_row2) > n2
        s.markers_row2 = s.markers_row2(1:n2);
    end

    if size(s.markers_colors, 1) < n2
        s.markers_colors = [s.markers_colors; repmat(s.markers_colors(end, :), n2 - size(s.markers_colors, 1), 1)];
    end
    if size(s.markers_colors, 1) > n2
        s.markers_colors = s.markers_colors(1:n2, :);
    end
end
