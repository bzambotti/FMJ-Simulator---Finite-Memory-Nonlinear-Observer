function apply_custom_style(h, dataset, p)
    % h: handlesboxplot
    % dataset: matrice dei dati [N_RUNS x N_COLONNE]
    % p: struct dei parametri  (params)

    n_groups = size(h, 2);
    base_stub = p.style.c_stub; 
    col_nom   = p.style.c_nom;
    col_outlier = [0.8500, 0.3250, 0.0980]; 

    for i = 1:n_groups
        % Logica del colore: Nominale vs Stubborn varianti
        if i == 1
            current_col = col_nom;
        else
            current_col = base_stub;
        end

        % 1. BOX (Corpo principale)
        set(h(5, i), 'Color', current_col, 'LineWidth', 2.5);

        % 2. BAFFI (Whiskers)
        set(h(1:2, i), 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);

        % 3. CAPS (Linee terminali dei baffi)
        set(h(3:4, i), 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);

        % 4. OUTLIERS (Dati fuori range)
        set(h(7, i), 'Marker', '*', 'MarkerEdgeColor', col_outlier, 'MarkerSize', 5);

        % 5. MEDIANA (Linea centrale)
        set(h(6, i), 'Color', current_col, 'LineWidth', 2, ...
            'Marker', '.', 'MarkerSize', 12);

        % % 6. MEDIA (Quadrato nero come nel tuo stile)
        % % Accediamo alla colonna i-esima della matrice dataset
        % this_data_col = dataset(:, i); 
        % mean_val = mean(this_data_col, 'omitnan');
        % 
        % x_data_median = get(h(6, i), 'XData');
        % x_center = mean(x_data_median);

        
    end

    grid on; box on;
    ylabel('RMSE', 'Interpreter', 'latex', 'FontSize', 20);
    set(gca, 'FontSize', 20, 'TickLabelInterpreter', 'latex');

    % Applichiamo i limiti che avevi impostato
    yticks([0 5 10 15 20]);
    ylim([0 20]);
end
