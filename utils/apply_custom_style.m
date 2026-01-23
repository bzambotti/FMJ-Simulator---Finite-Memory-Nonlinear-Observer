function apply_custom_style(h, data_nom, data_stub)
    % h: handles del boxplot
    % data_nom: vettore dati nominali
    % data_stub: vettore dati stubborn
    col_blue = [0, 0.4470, 0.7410];
    col_red = [0.8500, 0.3250, 0.0980];
    dataset = {data_nom, data_stub};
    n_groups = size(h, 2);
    for i = 1:n_groups
        % 1. BOX
        set(h(5, i), 'Color', col_blue, 'LineWidth', 2.5);
        % 2. BAFFI
        set(h(1:2, i), 'Color', 'k', 'LineStyle', '--', 'LineWidth', 2);
        % 3. CAPS
        set(h(3:4, i), 'Color', 'k', 'LineStyle', '-', 'LineWidth', 2);
        % 4. OUTLIERS
        set(h(7, i), 'Marker', '*', 'MarkerEdgeColor', col_red, 'MarkerSize', 6);
        % 5. MEDIANA
        set(h(6, i), 'Color', 'r', 'LineWidth', 2, ...
            'Marker', '.', 'MarkerSize', 15, 'MarkerEdgeColor','r', 'MarkerFaceColor','r');
        % 6. MEDIA
        this_data = dataset{i};
        mean_val = mean(this_data, 'omitnan');
        x_data_median = get(h(6, i), 'XData');
        x_center = mean(x_data_median);
        hold on;
        plot(x_center, mean_val, 's', ...
            'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'none', ...
            'MarkerSize', 6);
    end
    grid on; box on;
    ylabel('RMSE', 'Interpreter', 'latex', 'FontSize', 20);
    set(gca, 'FontSize', 20, 'TickLabelInterpreter', 'latex');
    yticks([0 5 10 15 20]);
    ylim([0 20])
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 16);
end
