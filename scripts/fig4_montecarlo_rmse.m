function fig4_montecarlo_rmse(params, out_dir, n_runs)
%FIG4_MONTECARLO_RMSE Fig. 4: RMSE boxplots of the nominal and finite-memory
%   stubborn observers over n_runs Monte Carlo runs (10^4 in the paper),
%   for several values of Theta. Left: T_dwell = 3. Right: T_dwell = 1.
%   Each run uses a random initial error and a random outlier realization.
%   Requires the Statistics and Machine Learning Toolbox (boxplot, signrank).

    fprintf('\n--- Fig. 4: Monte Carlo RMSE (%d runs per scenario) ---\n', n_runs);
    theta_test = [0.02, 0.5, 10];
    dwells     = [3, 1];

    f = figure(4); clf(f);
    set(f, 'Color', 'w');
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    for s = 1:numel(dwells)
        fprintf('Scenario %d: T_dwell = %d\n', s, dwells(s));
        results = zeros(n_runs, 1 + numel(theta_test));   % [nominal, stubborn(Theta_1), ...]
        for run = 1:n_runs
            results(run, :) = run_rmse_experiment(params, dwells(s), theta_test);
        end

        nexttile;
        labels = [{'Nominal'}, arrayfun(@(x) sprintf('$\\Theta=%.2g$', x), theta_test, 'UniformOutput', false)];
        h = boxplot(results, 'Labels', labels, 'Widths', 0.6);
        apply_custom_style(h, params);
        if s == 1
            ylabel('RMSE', 'Interpreter', 'latex', 'FontSize', 14);
        else
            ylabel(''); set(gca, 'YTickLabel', []);
        end
        yline(median(results(:,1)), 'r:', 'LineWidth', 1.5, 'Alpha', 0.5);

        % One-sided Wilcoxon signed-rank test: nominal vs stubborn (Theta = 0.02)
        p_val = signrank(results(:,1), results(:,2), 'tail', 'right');
        fprintf('  Wilcoxon (nominal > stubborn, Theta = %g): p = %.5e\n', theta_test(1), p_val);
    end

    export_figure(f, fullfile(out_dir, 'fig4_montecarlo_rmse.pdf'), [19*4/3, 9*4/3]);
end
