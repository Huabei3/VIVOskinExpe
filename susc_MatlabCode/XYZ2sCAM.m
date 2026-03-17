function [J, Q, C_1, M, h, H] = XYZ2sCAM(XYZ, XYZw, Yb, La, Surround)
% function [J, Q, C_1, M, h, H] = XYZ2sCAM(XYZ, XYZw, Yb, La, Surround)
% Author: Molin Li
% Date: 2023/12/13
% Reference: M. Li, M. R. Luo, Simple Colour Appearance Model(sCAM) Based on Simple Uniform Colour Space(sUCS), 
%            Optics Express, 32(3) (2024) 3100-3122.
%
% This function converts XYZ tristimulus values to sCAM (Simple Colour Appearance Model) coordinates.
%
% Input:
%   XYZ      - Nx3 matrix of XYZ tristimulus values.
%   XYZw     - Nx3 matrix of white point XYZ tristimulus values.
%   Yb       - Background luminance factor.
%   La       - Adapting luminance.
%   Surround - Surround condition ('avg', 'dim', or 'dark').
%
% Output:
%   J   - Lightness.
%   Q   - Brightness.
%   C_1 - Chroma.
%   M   - Colourfulness.
%   h   - Hue angle.
%   H   - Hue composition.

%% Step 1: Set surround parameters
switch Surround
    case 'avg'
        F = 1;
        c = 0.52;
        Fm = 1;
    case 'dim'
        F = 0.9;
        c = 0.5;
        Fm = 0.95;
    case 'dark'
        F = 0.8;
        c = 0.39;
        Fm = 0.85;
end

%% Step 2: Calculate intermediate parameters
n = Yb / XYZw(:, 2);
z = 1.48 + sqrt(n);
hue = [16.5987, 80.2763, 157.779, 219.7174, 376.5987];
hue1 = [0, 100, 200, 300, 400];
ei = [0.7, 0.6, 1.2, 0.9, 0.7];
RGYB_Matrix = [4.3 -4.7 0.4; 0.49 0.49 -0.98];
Transformer_Matrix = 100 * [[2 1 0.05] / (2 + 1 + 0.05); RGYB_Matrix];
LMS_Matrix = [0.4002 0.7075 -0.0807; -0.2280 1.15 0.0612; 0 0 0.9184];
XYZw_D65 = [95.047, 100, 108.883];

%% Step 3: Normalize XYZ to D65 illuminant
Lw = La * 100 / Yb;
XYZ_D65 = CAT16(XYZ, XYZw, XYZw_D65 .* (Lw / 100), La, F) / 100;

%% Step 4: Convert XYZ_D65 to LMS cone response
LMS = (LMS_Matrix * XYZ_D65')';
LMS_TM = (LMS >= 0) .* (LMS .^ 0.43) + (LMS < 0) .* (-(-LMS) .^ 0.43);

%% Step 5: Transform LMS to intermediate Iab coordinates
Iab = (Transformer_Matrix * LMS_TM')';
C = sqrt(Iab(:, 2).^2 + Iab(:, 3).^2);
C_1 = log(1 + 0.0447 * C) / 0.0252;

%% Step 6: Calculate lightness (J)
L = 100 * (Iab(:, 1) / 100) .^ (c * z);
J = L;

%% Step 7: Calculate hue angle (h)
h = cart_to_polar(Iab(:, 2), Iab(:, 3));
FL = 0.1710 * (La .^ (1 / 3)) .* (1 ./ (1 - 0.4934 * exp(-0.9934 * La)));
et = 1 + 0.06 * cosd(110 + h);

%% Step 8: Calculate hue composition (H)
h = (h < hue(1)) .* (h + 360) + (h >= hue(1)) .* (h);
H = zeros(size(h, 1), 1);
for i = 1:size(h, 1)
    index = find_interval(hue, h(i, 1));
    temp = (h(i, 1) - hue(index)) / ei(index);
    temp1 = (hue(index + 1) - h(i, 1)) / ei(index + 1);
    H(i, 1) = hue1(index) + 100 * temp / (temp + temp1);
end

%% Step 9: Calculate colourfulness (M) and brightness (Q)
M = (C_1 .* (FL) .^ 0.1 ./ J .^ 0.27 .* et) * Fm;
Q = (2 / c) .* L .* FL .^ 0.46;
end


function theta = cart_to_polar(x, y)

[theta, ~] = cart2pol(x, y);
theta = rad2deg(theta); % 将弧度转换为角度
theta(theta < 0) = theta(theta < 0) + 360; % 将负角度转换为正角度
end

function index = find_interval(array,target)
    
    a1 = (array - target)>0;
    ans1 = [a1(2:end),a1(1)];
    index = find((a1~=ans1) == true,1,'first');
end

function XYZt= CAT16(XYZ, XYZw, XYZwt, La, F)

%%% XYZ is test XYZ [nx3]
%%% XYZw is test white  [1x3]
%%% XYZwr is reference white [1x3]
%%% La is adaptive luminance; La should be calculated as (Lw*Yb)/Yw, where Lw is the luminance of reference white in cd/m2 unit, Yb is the luminance factor of the background and  Yw is the luminance factor of the reference white.
%%% F is the factor of degree of adaptation; F equals 1.0, 0.9, and 0.8 for average, dim, and dark surround viewing conditions, respectively.

%%% XYZr is the computed xyz under reference source


M_CAT02 = [0.401288 0.650173 -0.051461; -0.250268 1.204414 0.045854; -0.002079 0.048952 0.953127];
Inv_M_CAT02 =  M_CAT02^-1;

% step 1
RGB   = M_CAT02*XYZ';
RGBw  = M_CAT02*XYZw';
RGBwr = M_CAT02*XYZwt';
% step 2
D_pre =  F * (1- (1/3.6)*exp((-La-42)/92));
if D_pre<0
    D = 0;
elseif D_pre>1
    D = 1;
else
    D = D_pre;
end
alpha = D*XYZw(2)/XYZwt(2);

% step 3

RGBc(1,:) = (alpha*(RGBwr(1)/RGBw(1)) + 1 - D)*RGB(1,:);
RGBc(2,:) = (alpha*(RGBwr(2)/RGBw(2)) + 1 - D)*RGB(2,:);
RGBc(3,:) = (alpha*(RGBwr(3)/RGBw(3)) + 1 - D)*RGB(3,:);

% step 4
XYZt = (Inv_M_CAT02*RGBc)';
end
