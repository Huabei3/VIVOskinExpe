function lab = ycbcr2lab(ycbcr, is_255_scale)
% YCBCR2LAB_10DEG  将 YCbCr 色彩空间转换为 CIELAB（10° 标准观察者）
% 输入参数：
%   ycbcr      - 输入的 YCbCr 数据，支持：
%               - 单个像素：[Y, Cb, Cr]（行向量）
%               - 图像：M×N×3 矩阵（M 行、N 列、3 通道）
%   is_255_scale - 逻辑值：true 表示 YCbCr 取值范围为 [0,255]（默认，图像常用）
%                        false 表示 YCbCr 取值范围为 Y∈[0,1], Cb/Cr∈[-0.5,0.5]
% 输出参数：
%   lab        - 转换后的 CIELAB 数据，维度与输入一致
%               - L*∈[0,100]（明度），a*∈[-128,127]（红绿轴），b*∈[-128,127]（黄蓝轴）

%% 1. 初始化参数与输入校验
if nargin < 2
    is_255_scale = true;  % 默认使用 [0,255] 量化范围（图像标准）
end

% 校验输入维度
if ~ismatrix(ycbcr) && ~ismultidim(ycbcr)
    error('输入 YCbCr 数据必须是 [Y,Cb,Cr] 行向量或 M×N×3 图像矩阵');
end

% 保留输入维度信息（用于后续重构图像）
input_size = size(ycbcr);

% 转换为列向量处理（统一单像素和图像的计算逻辑）
ycbcr = reshape(ycbcr, [], 3);
Y = ycbcr(:, 1);
Cb = ycbcr(:, 2);
Cr = ycbcr(:, 3);

%% 2. YCbCr 标准化（转换为无量化的原始值）
if is_255_scale
    % 步骤1：[0,255] 量化值 → 原始 YCbCr（ITU-R BT.601 标准）
    Y = Y / 255;          % Y：[0,1]（亮度，1=白，0=黑）
    Cb = (Cb - 128) / 255;% Cb：[-0.5,0.5]（蓝色色度分量）
    Cr = (Cr - 128) / 255;% Cr：[-0.5,0.5]（红色色度分量）
end

% 校验标准化后的数据范围（避免异常值）
Y(Y < 0) = 0; Y(Y > 1) = 1;
Cb(Cb < -0.5) = -0.5; Cb(Cb > 0.5) = 0.5;
Cr(Cr < -0.5) = -0.5; Cr(Cr > 0.5) = 0.5;

%% 3. YCbCr → RGB 转换（ITU-R BT.601 矩阵，适用于标准数字图像）
% 转换矩阵（BT.601 标准：Y = 0.299R + 0.587G + 0.114B）
rgb = zeros(size(ycbcr));
rgb(:, 1) = Y + 1.402 * Cr;       % R = Y + 1.402Cr
rgb(:, 2) = Y - 0.34414 * Cb - 0.71414 * Cr;  % G = Y - 0.34414Cb - 0.71414Cr
rgb(:, 3) = Y + 1.772 * Cb;       % B = Y + 1.772Cb

% RGB 钳位（确保取值在 [0,1]，避免溢出导致的颜色失真）
rgb(rgb < 0) = 0;
rgb(rgb > 1) = 1;

%% 4. RGB → XYZ 转换（sRGB 色域，CIE 1931 10° 标准观察者）
% 步骤1：sRGB 伽马校正（反向转换：RGB → 线性 RGB）
gamma_mask = rgb > 0.04045;
rgb_linear(gamma_mask) = ((rgb(gamma_mask) + 0.055) / 1.055) .^ 2.4;
rgb_linear(~gamma_mask) = rgb(~gamma_mask) / 12.92;

% 步骤2：线性 RGB → XYZ（sRGB 色域转换矩阵，10° 观察者）
xyz_matrix = [
    0.4124564, 0.3575761, 0.1804375;  % X = 0.4124R + 0.3576G + 0.1805B
    0.2126729, 0.7151522, 0.0721750;  % Y = 0.2127R + 0.7152G + 0.0722B（与输入 Y 无关，XYZ 亮度通道）
    0.0193339, 0.1191920, 0.9503041   % Z = 0.0193R + 0.1192G + 0.9503B
];
xyz = rgb_linear * xyz_matrix';  % 矩阵乘法：每行对应一个像素的 XYZ

%% 5. XYZ → CIELAB 转换（10° 观察者，D65 标准光源）
lab=xyz2lab(xyz.*100,"d65_64");
end