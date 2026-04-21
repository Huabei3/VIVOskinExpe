function Iab_1 = XYZ2sUCS(XYZ, XYZw)
% function Iab_1 = XYZ2sUCS(XYZ, XYZw)
% Author: Molin Li
% Date: 2023/12/13
% Reference: M. Li, M. R. Luo, Simple Colour Appearance Model(sCAM) Based on Simple Uniform Colour Space(sUCS), 
%            Optics Express, 32(3) (2024) 3100-3122.
%
% This function converts XYZ tristimulus values to sUCS (Simple Uniform Colour Space) coordinates.
%
% Input:
%   XYZ  - Nx3 matrix of XYZ tristimulus values.
%   XYZw - Nx3 matrix of white point XYZ tristimulus values.
%
% Output:
%   Iab_1 - Nx3 matrix of sUCS coordinates (I, a, b).
%
% Algorithm Steps:
%   1. Normalize XYZ values to D65 illuminant.
%   2. Convert normalized XYZ to LMS cone response.
%   3. Apply a nonlinear transformation to LMS values.
%   4. Transform LMS to intermediate Iab coordinates.
%   5. Convert Cartesian coordinates to polar coordinates.
%   6. Apply a logarithmic compression to chroma (C).
%   7. Convert back to Cartesian coordinates to get final sUCS values.

% Define transformation matrices
RGYB_Matrix = [4.3 -4.7 0.4; 0.49 0.49 -0.98];
Transformer_Matrix = 100 * [[2 1 0.05]/(2+1+0.05); RGYB_Matrix];
LMS_Matrix = [0.4002 0.7075 -0.0807; -0.2280 1.15 0.0612; 0 0 0.9184];
XYZw_D65 = [95.047, 100, 108.883];

% Step 1: Normalize XYZ to D65 illuminant
XYZ_D65 = (XYZ ./ XYZw) .* XYZw_D65 / 100;

% Step 2: Convert normalized XYZ to LMS cone response
LMS = (LMS_Matrix * XYZ_D65')';

% Step 3: Apply nonlinear transformation to LMS values
LMS_TM = (LMS >= 0) .* (LMS.^0.43) + (LMS < 0) .* (-(-LMS).^0.43);

% Step 4: Transform LMS to intermediate Iab coordinates
Iab = (Transformer_Matrix * LMS_TM')';

% Step 5: Convert Cartesian coordinates to polar coordinates
h = cat_to_polar(Iab(:, 2), Iab(:, 3));
C = sqrt(Iab(:, 2).^2 + Iab(:, 3).^2);

% Step 6: Apply logarithmic compression to chroma (C)
I = Iab(:, 1);
C_1 = log(1 + 0.0447 * C) / 0.0252;

% Step 7: Convert back to Cartesian coordinates to get final sUCS values
ab_1 = [C_1 .* cosd(h), C_1 .* sind(h)];
Iab_1 = [I, ab_1];
end

function theta = cat_to_polar(x, y)
% function theta = cat_to_polar(x, y)
% Author: Molin Li
% Date: 2023/12/13
%
% This function converts Cartesian coordinates (x, y) to polar coordinates (theta).
%
% Input:
%   x - Nx1 vector of x-coordinates.
%   y - Nx1 vector of y-coordinates.
%
% Output:
%   theta - Nx1 vector of angles in degrees (0-360).

% Convert Cartesian coordinates to polar coordinates
[theta, ~] = cart2pol(x, y);
theta = rad2deg(theta); % Convert radians to degrees

% Ensure angles are in the range [0, 360)
theta(theta < 0) = theta(theta < 0) + 360;
end