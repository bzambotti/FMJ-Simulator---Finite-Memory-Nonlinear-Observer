function apply_custom_style(h, p)
%APPLY_CUSTOM_STYLE Style of the RMSE boxplots of Fig. 4.
%   h: handles returned by boxplot; column 1 is the nominal observer,
%   the other columns are stubborn observers.

    col_outlier = [0.8500, 0.3250, 0.0980];

    for i = 1:size(h, 2)
        if i == 1
            col = p.style.c_nom;
        else
            col = p.style.c_stub;
        end
        set(h(5, i),   'Color', col, 'LineWidth', 2.5);                        % box
        set(h(1:2, i), 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);    % whiskers
        set(h(3:4, i), 'Color', 'k', 'LineStyle', '-',  'LineWidth', 1.5);    % caps
        set(h(7, i),   'Marker', '*', 'MarkerEdgeColor', col_outlier, 'MarkerSize', 5); % outliers
        set(h(6, i),   'Color', col, 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 12);   % median
    end

    grid on; box on;
    ylabel('RMSE', 'Interpreter', 'latex', 'FontSize', 20);
    set(gca, 'FontSize', 20, 'TickLabelInterpreter', 'latex');
    yticks([0 5 10 15 20]);
    ylim([0 20]);
end
