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

        if isfield(legend_labels,"h_space_scale")
            h_space=baseHeight*legend_labels.h_space_scale;
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
    
        posX = marginL + (currCol - 1) * baseWidth - (currCol - 1) * gapX;
        posY = legendHeightNorm + (n_row - currRow) * baseHeight + (baseHeight - h_space) / 2;
        if isfield(legend_labels,"label_type")&&strcmp(legend_labels.label_type,"skinVIVO")&&i==5
            posX=posX+0.04;
        end
        subAx = axes('Parent', mainFig, 'Units', 'normalized', 'Position', [posX, posY, w_space, h_space]);
        if isfield(legend_labels,"posY_shift")
            posY=posY+legend_labels.posY_shift;
        end
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

        set(subAx, 'FontSize', targetFontSize, 'LabelFontSizeMultiplier', 1.0, 'TitleFontSizeMultiplier', 1.0);
        % set([newXlabel, newYlabel, newTitle], 'FontSize', targetFontSize, 'FontWeight', 'normal');
        set(newTitle, 'FontSize', targetFontSize, 'FontWeight', 'bold');


        set(newXlabel, 'FontSize', 1.2*targetFontSize, 'FontWeight', 'normal');
        set(newYlabel, 'FontSize', 1.2*targetFontSize, 'FontWeight', 'normal');

        if isfield(legend_labels,"label_fontSize")
            set(newXlabel, 'FontSize', legend_labels.label_fontSize, 'FontWeight', 'normal');
            set(newYlabel, 'FontSize', legend_labels.label_fontSize, 'FontWeight', 'normal');
        end

        set([newXlabel, newYlabel], 'Interpreter', 'latex');
        % axis(subAx, 'tight'); % 自动去掉四周多余空白
        if isfield(legend_labels,"x_data")
            subAx.XLim = [min(legend_labels.x_data)-0.9, max(legend_labels.x_data)+0.08]; % 假设你能拿到数据范围
        end
        if isfield(legend_labels,"y_data")
            subAx.YLim = [min(min(legend_labels.y_data))-0.5, max(max(legend_labels.y_data))+0.5]; % 假设你能拿到数据范围
        end
        % === 插入labels ===
        if isfield(legend_labels,"if_label")&&legend_labels.if_label
            letter_label = ['(', char('a' + i - 1), ')'];
            text(subAx, 0.95, 0.05, letter_label, 'Units', 'normalized', ...
                'FontSize', targetFontSize, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom');
        end


            total_content_width = (n_col * baseWidth) - ((n_col - 1) * gapX);
    %------------------
    if isfield(legend_labels, 'color_limits')&&(mod(i,4)==0||strcmp(legend_labels.label_type, 'CT'))
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
                cb.Label.String = '$L^*$';
            else
                cb.Label.String = 'luminance (cd/m$^2$)';
            end
        elseif strcmp(legend_labels.label_type, 'CT')
            cb.Label.String = 'CCT';
        end
        
        cb.Label.Interpreter = 'latex';
        cb.Label.FontSize = targetFontSize;
        
        % 确保 Colorbar 不会因为自动调整而改变主图布局
        cb.Units = 'normalized';
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
    saveas(mainFig, fullfile(output_path, 'Combined_legend1.png'));
    savefig(mainFig, fullfile(output_path, 'Combined_legend1.fig'));
    fprintf('Concatenation finished. Output saved to: %s\n', output_path);
end


function draw_legend_overlay(mainFig, legendPos, targetFontSize, legend_labels, label_Y)
    labels_row1 = legend_labels.labels_row1;
    labels_row2 = legend_labels.labels_row2;
    markers_row2 = legend_labels.markers_row2;
    markers_colors = legend_labels.markers_colors;
    markers_face_colors = legend_labels.markers_face_colors;
    if isfield(legend_labels,"colors_row1")
    colors_row1 = legend_labels.colors_row1;
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
    colGap1 = 1 / (n_col1 + 0.5); % 根据列数动态调整间距
    if isfield(legend_labels,"colGap2_scale")
        colGap2 = 1 / (n_col2 + 0.5)*legend_labels.colGap2_scale;
    else
        colGap2 = 1 / (n_col2 + 0.5);
    end
    rowStep = 0.35; % 换行时的垂直间距
    if isfield(legend_labels,"rowStep")
        rowStep=legend_labels.rowStep;
    end

    iconTextGap = 0.03;

    % --- 绘制第一组 (labels_row1) ---
    for k = 1:numel(labels_row1)
        currR = floor((k-1) / n_col1); % 当前行
        currC = mod(k-1, n_col1);      % 当前列
        
        tx = sidePad + currC * colGap1;
        ty = label_Y - currR * rowStep;
        if isfield(legend_labels, 'label_type') && strcmp(legend_labels.label_type, 'attr')
            text(legAx, tx , ty, num2str(k), ...
                'FontSize', targetFontSize, 'VerticalAlignment', 'middle', ...
                'Interpreter', 'latex','Color',colors_row1(k, :),'FontWeight','bold');
        elseif isfield(legend_labels, 'label_type') && strcmp(legend_labels.label_type, 'compare_nation')
            text_char=char(labels_row1{k});
            i_last_others=length(labels_row1)-4;
            % colors_last4=[[0 0 0];[0 0 0];[0 0 0];[1 0 1]];
            plot(legAx, tx, ty, 'o', ...
                'MarkerFaceColor', colors_row1(k, :), ...
                'MarkerEdgeColor', 'none', 'MarkerSize', 10, 'Clipping', 'off');

            % if k>i_last_others
            %     plot(legAx, tx, ty, legend_labels.markers_row1_last4{k-i_last_others}, ...
            %         'MarkerFaceColor', colors_last4(k-i_last_others, :), ...
            %         'MarkerEdgeColor', 'none', 'MarkerSize', 10, 'Clipping', 'off');
            % else
            %     text(legAx, tx , ty, text_char(1), ...
            %         'FontSize', targetFontSize, 'VerticalAlignment', 'middle', ...
            %         'Interpreter', 'none','Color',colors_row1(k, :),'FontWeight','bold');
            % end
            elseif isfield(legend_labels, 'label_type') && strcmp(legend_labels.label_type, 'only_my')
            text_char=char(labels_row1{k});
            i_last_others=length(labels_row1)-2;
            colors_last2=[[0 0 0];[0 0 0]];
            if k>i_last_others
                plot(legAx, tx, ty, legend_labels.markers_row1_last2{k-i_last_others}, ...
                    'MarkerFaceColor', colors_last2(k-i_last_others, :), ...
                    'MarkerEdgeColor', 'none', 'MarkerSize', 10, 'Clipping', 'off');
            else
                text(legAx, tx , ty, text_char(1), ...
                    'FontSize', targetFontSize, 'VerticalAlignment', 'middle', ...
                    'Interpreter', 'none','Color',colors_row1(k, :),'FontWeight','bold');
            end    
        else
            plot(legAx, tx, ty, 'o', 'MarkerFaceColor', colors_row1(k, :), ...
                'MarkerEdgeColor', 'none', 'MarkerSize', 10, 'Clipping', 'off');
        end
        text(legAx, tx + iconTextGap, ty, labels_row1{k}, ...
            'FontSize', targetFontSize, 'VerticalAlignment', 'middle', 'Interpreter', 'latex');
    end

    % 计算第二组的起始高度 (紧跟在第一组最后一行之后)
    numRowsRow1 = ceil(numel(labels_row1) / n_col1);
    row2Start_Y = label_Y - numRowsRow1 * rowStep - 0.1; 

    % --- 绘制第二组 (labels_row2) ---
    if ~isempty(labels_row2)
        for k = 1:numel(labels_row2)
            currR = floor((k-1) / n_col2);
            currC = mod(k-1, n_col2);
            if isfield(legend_labels, 'Gap2_scale')
                tx = sidePad + currC * colGap2*legend_labels.Gap2_scale;
            else
                tx = sidePad + currC * colGap2;
            end
            ty = row2Start_Y - currR * rowStep;
            
            plot(legAx, tx, ty, markers_row2{k}, 'Color', markers_colors(k, :), ...
                'MarkerFaceColor', markers_face_colors(k, :), ...
                'MarkerSize', 10, 'LineWidth', 1.5, 'Clipping', 'off');
            text(legAx, tx + iconTextGap, ty, labels_row2{k}, ...
                'FontSize', targetFontSize, 'VerticalAlignment', 'middle', 'Interpreter', 'none');
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
