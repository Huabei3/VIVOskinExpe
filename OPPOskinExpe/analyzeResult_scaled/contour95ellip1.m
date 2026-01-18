function contour95ellip1(center, mu, lab_group, rho, output_folder, save_pic_name, color_input, variable, ori_lab_mean)
    % Define D65 white point for LAB to XYZ conversion (standard for sRGB)
    % IMPORTANT: If you have a specific white point from your 'wd65_scaled'
    % in the main script, you should use that instead of this standard one.
    % For example, you might pass it as an argument or define it globally if consistent.
    XYZw_D65 = [95.047, 100.000, 108.883]; % Standard D65 white point
    lab_PMCC = [62.11, 18.96, 19.76];
    lab_PMCC(4) = sqrt(lab_PMCC(2).^2 + lab_PMCC(3).^2); % C* for PMCC
    % Calculate C* for center and ori_lab_mean
    center(4) = sqrt(center(2).^2 + center(3).^2);
    ori_lab_mean(4) = sqrt(ori_lab_mean(2).^2 + ori_lab_mean(3).^2);
    % Convert center LAB to sRGB for plot color
    % The 'center' input to this function is assumed to be in LAB format.
    % We need to convert it to XYZ first, then to sRGB.
    try
        xyz_center = lab2xyz(center(1:3), 'WhitePoint', XYZw_D65);
        rgb_center = xyz2rgb(xyz_center, 'ColorSpace', 'srgb');
        % Ensure RGB values are within [0, 1]
        rgb_center = max(0, min(1, rgb_center));
    catch
        warning('LAB to RGB conversion failed for center point. Using input color.');
        rgb_center = color_input; % Fallback to the original input color if conversion fails
    end
    if size(lab_group, 1) < 3
        % L-a
        h1 = figure(1);
        grid on;
        box on;
        hold on;
        % Only plot ori_lab_mean and center with 'o' marker and calculated RGB color
        plot(center(2), center(3), 'o', 'MarkerSize', 4, ...
             'MarkerFaceColor', rgb_center, 'MarkerEdgeColor', 'k'); % Black edge for visibility
        return
    end
    %% a-b
    h1 = figure(1);
    grid on;
    box on;
    hold on;
    % Plot ori_lab_mean and center with 'o' marker and calculated RGB color
    plot(center(2), center(3), 'o', 'MarkerSize', 5, ...
         'MarkerFaceColor', rgb_center, 'MarkerEdgeColor', 'k'); % Black edge for visibility
    plot(lab_PMCC(2), lab_PMCC(3), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');
    text(center(2), center(3), ...
     strrep(save_pic_name,"Add",""), 'FontSize', 6, ...
    'VerticalAlignment', 'top', 'Color', 'k');
    % Set labels and title
    xlabel('\textit{a*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{b*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    title('\textit{a*-b*}', 'Interpreter', 'latex', 'FontSize', 12*2);

    % --- MODIFIED SECTION FOR AXIS LIMITS AND ANGLE LINES ---
    % Set axis limits
    axis equal;
    % Determine max_lim based on data, ensuring it's at least a certain value
    % and then making it a multiple of 5 for cleaner ticks.
    if strcmp(variable, "makeup")
        max_lim = 30;
    elseif strcmp(variable, "gender")
        max_lim = round(max(lab_group(:,2))) + 10;
        max_lim = ceil(max_lim / 5) * 5; % Round up to nearest multiple of 5
    elseif strcmp(variable, "scene")
        max_lim = 35;
    elseif strcmp(variable, "scene1")||strcmp(variable, "scene_ind")
        max_lim = 25;
    else
        max_val_data = max(max(abs(lab_group(:,2))), max(abs(lab_group(:,3))));
        max_lim = ceil((max_val_data + 15) / 5) * 5; % Round up to nearest multiple of 5, adding some buffer
        if max_lim < 30 % Ensure a minimum practical limit
            max_lim = 30;
        end
    end
    
    xlim([0, max_lim]); % Set lower bound to 0
    ylim([0, max_lim]); % Set lower bound to 0

    interval = 5;
    xticks(0:interval:max_lim);
    yticks(0:interval:max_lim);

    % Plot y=x reference line
    x_axis_line = linspace(0, max_lim, 1000);
    y_axis_line = x_axis_line; % y=x line
    plot(x_axis_line, y_axis_line, 'k--', 'LineWidth', 0.8); % Plot y=x line

    % Plot y = tan(theta) * x lines and annotate angles
    for theta = 0:5:90 % Iterate from 0 to 90 degrees in 5-degree steps
        if theta == 0
            % Plot a horizontal line along x-axis for 0 degrees
            plot([0, max_lim], [0, 0], 'k:', 'LineWidth', 0.5);
            text(max_lim, 0, sprintf('%d°', theta), 'VerticalAlignment', 'bottom', ...
                 'HorizontalAlignment', 'right', 'FontSize', 7, 'Color', 'k');
        elseif theta == 90
            % Plot a vertical line along y-axis for 90 degrees
            plot([0, 0], [0, max_lim], 'k:', 'LineWidth', 0.5);
            text(0, max_lim, sprintf('%d°', theta), 'VerticalAlignment', 'bottom', ...
                 'HorizontalAlignment', 'right', 'FontSize', 7, 'Color', 'k');
        else
            m = tand(theta);
            % Calculate points for the line
            x_line = linspace(0, max_lim, 100);
            y_line = m * x_line;
            % Only plot points within the defined y-limits and x-limits
            valid_line_idx = (y_line >= 0) & (y_line <= max_lim) & (x_line >= 0) & (x_line <= max_lim);
            plot(x_line(valid_line_idx), y_line(valid_line_idx), 'k:', 'LineWidth', 0.5);

            % Add angle label at the edge of the plot
            % Determine where to place the label (either x_max or y_max)
            if m * max_lim <= max_lim
                % Line intersects the right boundary (x = max_lim)
                label_x = max_lim;
                label_y = m * max_lim;
            else
                % Line intersects the top boundary (y = max_lim)
                label_y = max_lim;
                label_x = max_lim / m;
            end
            % Adjust label position slightly if it's very close to the corner
            if label_x == max_lim && label_y == max_lim
                text(label_x - 1, label_y - 1, sprintf('%d°', theta), 'VerticalAlignment', 'top', ...
                     'HorizontalAlignment', 'right', 'FontSize', 7, 'Color', 'k');
            else
                text(label_x, label_y, sprintf('%d°', theta), 'VerticalAlignment', 'bottom', ...
                     'HorizontalAlignment', 'right', 'FontSize', 7, 'Color', 'k');
            end
        end
    end
    % --- END OF MODIFIED SECTION ---

    % Save image
    if strcmp(variable, "adj_D")
        exportgraphics(gcf, fullfile(output_folder, strcat(save_pic_name, 'a_b.jpg')), ...
            'Resolution', 300);
    else
        exportgraphics(gcf, fullfile(output_folder, strcat('a_b.jpg')), ...
            'Resolution', 300);
    end
    %% L-a
    h2 = figure(2);
    hold on;
    grid on;
    box on;
    % Removed contour plot
    % if ~strcmp(variable,"models")
    %     contour(data2, data1, f, [0, rho], 'Linewidth', 1, 'Color', color_input);
    % end
    % Removed scatter plot
    % scatter(ori_lab_mean(2), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
    %    'MarkerEdgeColor',color_input);
    % Plot ori_lab_mean and center with 'o' marker and calculated RGB color
    plot(center(2), center(1), 'o', 'MarkerSize', 4, ...
         'MarkerFaceColor', rgb_center, 'MarkerEdgeColor', 'k'); % Black edge for visibility
    plot(lab_PMCC(2), lab_PMCC(1), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');
    % Set labels and title
    xlabel('\textit{a*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    title('\textit{L*-a*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    % Set axis limits
    axis equal;
    if strcmp(variable, "makeup")
        x_min_lim = round(min(lab_group(:,2))) - 5;
        x_max_lim = round(max(lab_group(:,2))) + 5;
        y_min_lim = round(min(lab_group(:,1))) - 5;
        y_max_lim = round(max(lab_group(:,1))) + 5;
    elseif strcmp(variable, "gender")
        x_min_lim = round(min(lab_group(:,2))) - 10;
        x_max_lim = round(max(lab_group(:,2))) + 10;
        y_min_lim = round(min(lab_group(:,1))) - 10;
        y_max_lim = round(max(lab_group(:,1))) + 10;
    elseif strcmp(variable, "scene")
        x_min_lim = round(min(lab_group(:,2))) - 15;
        x_max_lim = round(max(lab_group(:,2))) + 15;
        y_min_lim = round(min(lab_group(:,1))) - 15;
        y_max_lim = round(max(lab_group(:,1))) + 15;
    elseif strcmp(variable, "compare")
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(lab_group(:,1)) - 5; y_max_lim = max(lab_group(:,1)) + 5;
    else
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(lab_group(:,1)) - 15; y_max_lim = max(lab_group(:,1)) + 15;
    end
    xlim([x_min_lim, x_max_lim]);
    ylim([y_min_lim, y_max_lim]);
    interval = 5;
    xticks(x_min_lim:interval:x_max_lim);
    yticks(y_min_lim:interval:y_max_lim);
    % Save image
    if strcmp(variable, "adj_D")
        exportgraphics(gcf, fullfile(output_folder, strcat(save_pic_name, 'L_a.jpg')), 'Resolution', 300);
    else
        exportgraphics(gcf, fullfile(output_folder, strcat('L_a.jpg')), ...
            'Resolution', 300);
    end
    %% L-b
    h3 = figure(3);
    hold on;
    grid on;
    box on;
    % Removed contour plot
    % if ~strcmp(variable,"models")
    %     contour(data3, data1, f, [0, rho], 'Linewidth', 1, 'Color', color_input);
    % end
    % Removed scatter plot
    % scatter(ori_lab_mean(3), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
    %    'MarkerEdgeColor',color_input);
    % Plot ori_lab_mean and center with 'o' marker and calculated RGB color
    plot(center(3), center(1), 'o', 'MarkerSize', 4, ...
         'MarkerFaceColor', rgb_center, 'MarkerEdgeColor', 'k'); % Black edge for visibility
    plot(lab_PMCC(3), lab_PMCC(1), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');
    % Set labels and title
    xlabel('\textit{b*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    title(['\textit{L*-b* }'], 'Interpreter', 'latex', 'FontSize', 12*2);
    % Set axis limits
    axis equal;
    if strcmp(variable, "makeup")
        x_min_lim = round(min(lab_group(:,3))) - 5;
        x_max_lim = round(max(lab_group(:,3))) + 5;
        y_min_lim = round(min(lab_group(:,1))) - 5;
        y_max_lim = round(max(lab_group(:,1))) + 5;
    elseif strcmp(variable, "gender")
        x_min_lim = round(min(lab_group(:,3))) - 10;
        x_max_lim = round(max(lab_group(:,3))) + 10;
        y_min_lim = round(min(lab_group(:,1))) - 10;
        y_max_lim = round(max(lab_group(:,1))) + 10;
    elseif strcmp(variable, "scene")
        x_min_lim = round(min(lab_group(:,3))) - 15;
        x_max_lim = round(max(lab_group(:,3))) + 15;
        y_min_lim = round(min(lab_group(:,1))) - 15;
        y_max_lim = round(max(lab_group(:,1))) + 15;
    else
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(lab_group(:,1)) - 15; y_max_lim = max(lab_group(:,1)) + 15;
    end
    xlim([x_min_lim, x_max_lim]);
    ylim([y_min_lim, y_max_lim]);
    interval = 5;
    xticks(x_min_lim:interval:x_max_lim);
    yticks(y_min_lim:interval:y_max_lim);
    % Save image
    if strcmp(variable, "adj_D")
        exportgraphics(gcf, fullfile(output_folder, strcat(save_pic_name, 'L_b.jpg')), ...
            'Resolution', 300);
    else
        exportgraphics(gcf, fullfile(output_folder, strcat('L_b.jpg')), ...
            'Resolution', 300);
    end
    %% L-C
    h4 = figure(4);
    hold on;
    grid on;
    box on;
    % Removed scatter plot
    % scatter(ori_lab_mean(4), ori_lab_mean(1), 20, '+', 'LineWidth', 1, ...
    %    'MarkerEdgeColor',color_input);
    % Plot ori_lab_mean and center with 'o' marker and calculated RGB color
    plot(center(4), center(1), 'o', 'MarkerSize', 4, ...
         'MarkerFaceColor', rgb_center, 'MarkerEdgeColor', 'k'); % Black edge for visibility
    plot(lab_PMCC(4), lab_PMCC(1), 's', 'MarkerSize', 5, ...
        'MarkerFaceColor', [1, 0.4, 0.8], 'MarkerEdgeColor', 'm');
    % Set labels and title
    xlabel('\textit{C*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    ylabel('\textit{L*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    title('\textit{L*-C*}', 'Interpreter', 'latex', 'FontSize', 12*2);
    % Set axis limits
    axis equal;
    if strcmp(variable, "makeup")
        x_min_lim = round(min(lab_group(:,4))) - 5; % Assuming C* is stored in 4th col
        x_max_lim = round(max(lab_group(:,4))) + 5;
        y_min_lim = round(min(lab_group(:,1))) - 5;
        y_max_lim = round(max(lab_group(:,1))) + 5;
        interval = 5;
    elseif strcmp(variable, "gender")
        x_min_lim = round(min(lab_group(:,4))) - 10;
        x_max_lim = round(max(lab_group(:,4))) + 10;
        y_min_lim = round(min(lab_group(:,1))) - 10;
        y_max_lim = round(max(lab_group(:,1))) + 10;
        interval = 5;
    elseif strcmp(variable, "scene")
        x_min_lim = 20; x_max_lim = 40;
        y_min_lim = 50; y_max_lim = 70;
        interval = 5;
    elseif strcmp(variable, "compare")
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(lab_group(:,1)) - 5; y_max_lim = max(lab_group(:,1)) + 5;
        interval = 5;
    else
        x_min_lim = 0; x_max_lim = 30;
        y_min_lim = min(lab_group(:,1)) - 15; y_max_lim = max(lab_group(:,1)) + 15;
        interval = 5;
    end
    xlim([x_min_lim, x_max_lim]);
    ylim([y_min_lim, y_max_lim]);
    xticks(x_min_lim:interval:x_max_lim);
    yticks(y_min_lim:interval:y_max_lim);
    % Save image
    if strcmp(variable, "adj_D")
        exportgraphics(gcf, fullfile(output_folder, strcat(save_pic_name, 'L_C.jpg')), 'Resolution', 300);
    else
        exportgraphics(gcf, fullfile(output_folder, strcat('L_C.jpg')), ...
            'Resolution', 300);
    end
end
% Helper function to convert LAB to XYZ
% This is a simplified version; for full robust conversion, use MATLAB's colorspace functions.
% This assumes a D65 white point internally for 'lab2xyz' and 'xyz2rgb'.
function xyz = lab2xyz(lab, varargin)
    p = inputParser;
    addRequired(p, 'lab');
    addParameter(p, 'WhitePoint', [95.047, 100.000, 108.883]); % D65
    parse(p, lab, varargin{:});
    L = p.Results.lab(1);
    a = p.Results.lab(2);
    b = p.Results.lab(3);
    WP = p.Results.WhitePoint;
    fy = (L + 16) / 116;
    fx = a / 500 + fy;
    fz = fy - b / 200;
    epsilon = 216/24389; % (6/29)^3
    kappa = 24389/27; % (29/3)^3
    % Inverse f(t)
    X = WP(1) * (fx^3);
    Y = WP(2) * (fy^3);
    Z = WP(3) * (fz^3);
    % For values less than epsilon, use the linear transformation
    idx = (fx < epsilon); if idx, X = WP(1) * ((116 * fx - 16) / kappa); end
    idx = (fy < epsilon); if idx, Y = WP(2) * ((116 * fy - 16) / kappa); end
    idx = (fz < epsilon); if idx, Z = WP(3) * ((116 * fz - 16) / kappa); end
    xyz = [X, Y, Z];
end
% Helper function to convert XYZ to sRGB
function rgb = xyz2rgb(xyz, varargin)
    p = inputParser;
    addRequired(p, 'xyz');
    addParameter(p, 'ColorSpace', 'srgb'); % Only 'srgb' is supported in this simplified version
    parse(p, xyz, varargin{:});
    X = p.Results.xyz(1) / 100; % Normalize to 0-1 range for typical sRGB conversion matrix
    Y = p.Results.xyz(2) / 100;
    Z = p.Results.xyz(3) / 100;
    % sRGB conversion matrix from XYZ (D65 white point)
    M = [ 3.2404542, -1.5371385, -0.4985314;
         -0.9692660,  1.8760108,  0.0415560;
          0.0556434, -0.2040259,  1.0572252];
    linear_rgb = M * [X; Y; Z];
    % sRGB companding (gamma correction)
    srgb = zeros(3,1);
    for i = 1:3
        val = linear_rgb(i);
        if val > 0.0031308
            srgb(i) = 1.055 * (val^(1/2.4)) - 0.055;
        else
            srgb(i) = 12.92 * val;
        end
    end
    rgb = srgb'; % Return as row vector
end