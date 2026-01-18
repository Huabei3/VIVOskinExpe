function RGB = lut3d_xyz2rgbIpv_bfCashe(XYZ,  datafile, i, i_points)

    LUTdata=load(datafile);

    P_labs=LUTdata.P_labs;
    XYZw1=LUTdata.XYZw;
    rgb=LUTdata.rgb;

    Lab = xyz2lab(XYZ, 'user', XYZw1);


%     % 定义保存文件的名称
%     filename=sprintf('save1_%02d_%02dtime%s.mat', i, i_points, datestr(now, 'mm_dd_HH_MM'));

    % 初始化RGB
    RGB = zeros(size(XYZ, 1), 3);

%     % 检查文件是否存在，存在则加载已计算的RGB值
%     if isfile(filename)
%         load(filename, 'RGB');
%     else
%         RGB = zeros(size(Lab));
%     end
% 
%         % 查找已经计算过的RGB数量
%     start_row = find(all(RGB == 0, 2), 1); % 找到第一个未计算的行
%     if isempty(start_row)
%         start_row = length(Lab) + 1; % 如果没有找到，说明全部计算过
%     end
    % 确保并行池已经启动
    CoreNum = 6;
    if isempty(gcp('nocreate'))
        parpool(CoreNum);
    end
    
    parfor i_row = 1:length(Lab)
        n = length(P_labs(:,1));
        copies = repmat(Lab(i_row,:), n, 1);    
        [de, ~, ~, ~] = cielabde(copies, P_labs);
        [val, mindeidx] = min(de);
        RGB(i_row,:) = rgb(mindeidx,:);

%         % 增量保存当前RGB值到.mat文件k
%         save(filename, 'RGB');

        % 显示进度
        if mod(i_row,10000)==0
            disp([num2str(i_row) '/' num2str(length(Lab))]);
            disp(['Current time: ' datestr(now, 'yyyy-mm-dd HH:MM:SS')]);
        end

    end

    % 限制RGB值的范围
    RGB(RGB < 0 | isnan(RGB) | isinf(RGB)) = 0;
    RGB(RGB >= 0 & isinf(RGB)) = 255;
    RGB(RGB <= 0 & isinf(RGB)) = 0;
    RGB(RGB > 255) = 255;
end