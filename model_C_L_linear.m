% Linear C_L model: C = a1 * L + a2
function [r_val, a_val, RMSE] = model_C_L_linear(output_folder, L_data, C_data, attribute_serial, nation_color, line_style, Dtype, iOr, i_nation)
    r_val = NaN;
    a_val = NaN(1, 2);
    RMSE = NaN;

    valid_indices = ~isnan(L_data) & ~isnan(C_data);
    L_valid = L_data(valid_indices);
    C_valid = C_data(valid_indices);

    if length(L_valid) > 1
        a = polyfit(L_valid, C_valid, 1);
        y = polyval(a, L_valid);

        r_val = corr(y, C_valid);
        RMSE = sqrt(mean((C_valid - y).^2))./mean(C_valid);
        a_val = a;

        h = figure(100 + i_nation);
        set(h, 'Name', ['C_L Linear - ' char(attribute_serial) ' - ' num2str(i_nation)], 'NumberTitle', 'off');
        hold on;
        set(gcf, 'Color', 'white');

        x_plot = min(L_valid):0.1:max(L_valid);
        y_plot = polyval(a, x_plot);
        plot(y_plot, x_plot, 'Color', nation_color, 'LineWidth', 1, 'LineStyle', line_style);
        scatter(C_valid, L_valid, 20, nation_color, 'filled', 'MarkerEdgeColor', 'k', 'LineWidth', 0.5);

        ylabel('L_{ab}^*', 'FontSize', 12, 'FontAngle', 'italic');
        xlabel('C^*', 'FontSize', 12, 'FontAngle', 'italic');
        title(['C^* - L^*'], 'FontSize', 14);
        grid on;
        axis equal;
        interval = 10;
        xticks(0:interval:35);
        yticks(0:interval:80);
        ylim([0, 80]);
        xlim([0, 35]);

        exportgraphics(h, fullfile(output_folder, strcat(attribute_serial, '_nation_', num2str(i_nation), '.jpg')), 'Resolution', 300);
        close(h);
    end
end
