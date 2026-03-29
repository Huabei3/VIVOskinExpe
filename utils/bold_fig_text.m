function bold_fig_text(fig_path, opts)
    % 功能：读取fig文件，将所有text对象设为粗体，支持opts结构体配置保存/导出行为
    % 输入：
    %   fig_path: 必选，fig文件完整路径（如'D:\test.fig'）
    %   opts: 可选，结构体，支持字段：
    %       - save_fig_flag: 逻辑值，是否保存粗体后的fig，默认true
    %       - export_png_flag: 逻辑值，是否导出无白边PNG，默认true
    %       - png_resolution: 数值，PNG导出分辨率，默认300
    % 示例调用：
    %   1. 仅传路径（使用所有默认值）：bold_fig_text('D:\bigImg.fig');
    %   2. 自定义参数：
    %      opts.save_fig_flag = false; 
    %      opts.export_png_flag = true;
    %      opts.png_resolution = 600;
    %      bold_fig_text('D:\bigImg.fig', opts);

    % ---------------------- 1. 参数初始化（处理默认值） ----------------------
    % 初始化默认opts结构体
    default_opts.save_fig_flag = true;
    default_opts.export_png_flag = true;
    default_opts.png_resolution = 600; % PNG默认分辨率300dpi

    % 合并输入opts和默认opts（无输入则用默认值）
    if nargin < 2 || isempty(opts)
        opts = default_opts;
    else
        % 检查并补充缺失的字段（保证结构体完整性）
        if ~isfield(opts, 'save_fig_flag'), opts.save_fig_flag = default_opts.save_fig_flag; end
        if ~isfield(opts, 'export_png_flag'), opts.export_png_flag = default_opts.export_png_flag; end
        if ~isfield(opts, 'png_resolution'), opts.png_resolution = default_opts.png_resolution; end
    end

    % ---------------------- 2. 打开fig文件（隐藏窗口） ----------------------
    if ~exist(fig_path, 'file')
        error('未找到fig文件：%s', fig_path);
    end
    fig = openfig(fig_path, 'invisible'); % 隐藏打开，避免弹窗

    % ---------------------- 3. 遍历并修改所有text为粗体 ----------------------
    text_handles = findall(fig, 'Type', 'text'); % 递归查找所有文字对象
    if ~isempty(text_handles)
        for i = 1:length(text_handles)
            set(text_handles(i), 'FontWeight', 'bold'); % 核心：设置粗体
        end
        fprintf('✅ 已将fig中 %d 个文字对象设为粗体\n', length(text_handles));
    else
        warning('⚠️ fig文件中未找到任何text对象');
    end

    % ---------------------- 4. 保存粗体后的fig文件（可选） ----------------------
    if opts.save_fig_flag
        [fig_dir, fig_name, ~] = fileparts(fig_path);
        new_fig_name = strcat(fig_name ,'_bold.fig');
        new_fig_path = fullfile(fig_dir, new_fig_name);
        savefig(fig, new_fig_path); % 保存修改后的fig
        fprintf('💾 粗体版fig已保存至：%s\n', new_fig_path);
    end

    % ---------------------- 5. 导出无白边PNG（可选） ----------------------
    if opts.export_png_flag
        [fig_dir, fig_name, ~] = fileparts(fig_path);
        png_name = strcat(fig_name ,'_bold.png');
        png_path = fullfile(fig_dir, png_name);
        

        exportgraphics(fig, png_path, ...
            'Resolution', opts.png_resolution); % 自动裁剪白边

        fprintf('🖼️ 无白边PNG已导出至：%s\n', png_path);
    end

    % ---------------------- 6. 清理资源 ----------------------
    close(fig); % 关闭隐藏的fig窗口
end