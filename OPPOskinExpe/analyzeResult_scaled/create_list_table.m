function list_table = create_list_table(L, par_all,r_all)
    % 输入：
    %   L - 一个列向量，表示 L 值
    %   par_all - 一个矩阵，包含参数数据
    % 输出：
    %   list_table - 一个 table，包含计算后的结果

    % 初始化输出列表
    n_para = size(par_all, 1); % 获取参数数量
    list = zeros(n_para, 9); % 分别是 L、a、b、C、h、A、A/B、theta、coefficients

    % 填充 L、a、b
    list(:, 1) = L; % L 值
    list(:, 2:3) = par_all(:, 4:5); % a 和 b 值

    % 计算 C 和 h
    list(:, 4) = sqrt(par_all(:, 4).^2 + par_all(:, 5).^2); % C = sqrt(a^2 + b^2)
    list(:, 5) = atan2d_360(par_all(:, 5), par_all(:, 4)); % h = atan2d_360(b, a)

    % 计算 A、B、theta
    y_target = 0.5;
    denominator = (log((1 / y_target - 1) ./ par_all(:, 6)).^2);
    lambda00 = par_all(:, 1) ./ denominator;
    lambda01 = par_all(:, 3) ./ denominator / 2;
    lambda10 = par_all(:, 3) ./ denominator / 2;
    lambda11 = par_all(:, 2) ./ denominator;
    theta = 0.5 * atan2d_360(2 * lambda01, (lambda00 - lambda11));

    % 计算 A 和 B
    A = lambda00 .* cosd(theta).^2 - lambda01 .* sind(2 * theta) + lambda11 .* sind(theta).^2;
    B = lambda00 .* sind(theta).^2 + lambda01 .* sind(2 * theta) + lambda11 .* cosd(theta).^2;
    aabb = zeros(n_para, 2);
    aabb(:, 1) = sqrt(1 ./ A);
    aabb(:, 2) = sqrt(1 ./ B);

    % 确保 A >= B，并调整 theta
    for i_para = 1:n_para
        if aabb(i_para, 1) < aabb(i_para, 2)
            temp = aabb(i_para, 1);
            aabb(i_para, 1) = aabb(i_para, 2);
            aabb(i_para, 2) = temp;
            % 调整 theta
            theta(i_para) = theta(i_para) + 90;
            theta(i_para) = convertAngleTo90Interval(theta(i_para));
        end
    end

    % 填充 A、A/B、theta
    list(:, 6) = aabb(:, 1); % A
    list(:, 7) = aabb(:, 1) ./ aabb(:, 2); % A/B
    list(:, 8) = theta; % theta
    list(:, 9) = r_all; % coefficients
    list(end+1,:)=mean(list,1);

    % 转换为 table
    list_table = array2table(list, 'VariableNames', ...
        {'L', 'a', 'b', 'C', 'h', 'A', 'A_over_B', 'theta', 'coefficients'});

end

% 辅助函数：atan2d_360
function degree = atan2d_360(y, x)
    degree = atan2d(y, x);
    if degree < 0
        degree = degree + 360;
    end
end

% 辅助函数：convertAngleTo90Interval
function angle = convertAngleTo90Interval(angle)
    % 将角度转换到 [-180, 180] 区间内
    angle = mod(angle, 360);
    if angle > 180
        angle = angle - 360;
    end
    
    % 将角度转换到 [-90, 90] 区间内
    if angle > 90
        angle = angle - 180;
    elseif angle < -90
        angle = angle + 180;
    end
end