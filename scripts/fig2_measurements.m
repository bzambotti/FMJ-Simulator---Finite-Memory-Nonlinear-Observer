function fig2_measurements(params, out_dir)
%FIG2_MEASUREMENTS Fig. 2: outlier rejection on y2 for T_dwell = 3 with
%   zero initial conditions. Top: true output, finite-memory estimate and
%   saturation band y_hat +/- Delta_k. Bottom: measured output with outliers.

    fprintf('\n--- Fig. 2: measurements and saturation band ---\n');
    N   = params.sim.N;
    u   = params.sim.input;
    C   = params.plant.C_d;
    tau = params.stubborn.tau;
    ch  = 2;              % output channel shown
    zoom_win = [0, 100];
    dwell = 3;            % T_dwell = tau: exact cancellation (Theorem 2, T2.1)

    x0 = zeros(4, 1);     % e_0 = 0, sigma_0 = 0
    x_true = zeros(4, N);
    x_stub = zeros(4, N); x_stub(:,1) = x0;
    Sigma  = max(abs(C * x0)) * ones(tau, 1);
    noise  = disturbance_generator(params.sim.f_bar, dwell, N, 2);

    y_nom  = zeros(2, N);
    y_meas = zeros(2, N);
    y_hat  = zeros(2, N);
    Delta  = zeros(1, N);

    for k = 1:N-1
        x_true(:, k+1) = simulate_FMJ(x_true(:, k), u(k), params);
        y_nom(:, k)  = C * x_true(:, k);
        y_meas(:, k) = y_nom(:, k) + noise(:, k);
        y_hat(:, k)  = C * x_stub(:, k);
        [x_stub(:, k+1), Sigma, Delta(k)] = observer_stubborn_finite_memory(x_stub(:, k), u(k), y_meas(:, k), Sigma, params);
    end
    y_nom(:,N)  = y_nom(:,N-1);
    y_meas(:,N) = y_meas(:,N-1);
    y_hat(:,N)  = y_hat(:,N-1);
    Delta(N)    = Delta(N-1);

    % Theorem 2 (T2.1): the estimation error must stay identically zero
    fprintf('Check T2.1: max |x - x_stub| = %g (expected 0)\n', max(abs(x_true - x_stub), [], 'all'));

    f = figure(2); clf(f);
    set(f, 'Color', 'w');
    steps = 0:N-1;
    tl = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

    % Top: zoom on band and tracking
    ax1 = nexttile; hold on; grid on; box on
    fill([steps, fliplr(steps)], [y_hat(ch,:) + Delta, fliplr(y_hat(ch,:) - Delta)], ...
         [0.92 0.69 0.125], 'EdgeColor', 'none', 'FaceAlpha', 1, 'DisplayName', '$\hat{y}_k \pm \Delta_k$');
    plot(steps, y_nom(ch,:), 'k--', 'LineWidth', 2.5, 'DisplayName', 'True');
    plot(steps, y_hat(ch,:), '-', 'Color', [1 0 0], 'LineWidth', 2.5, 'DisplayName', 'Observer');
    ylabel(sprintf('$y_{%d}$', ch), 'Interpreter', 'latex', 'FontSize', 20);
    set(gca, 'FontSize', 14, 'TickLabelInterpreter', 'latex');
    legend('Interpreter', 'latex', 'Location', 'northwest', 'NumColumns', 1, 'FontSize', 12);

    % Bottom: full scale with outliers
    ax2 = nexttile; hold on; grid on; box on
    plot(steps, y_meas(ch,:), ':o', 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5, ...
         'MarkerSize', 4, 'MarkerFaceColor', [0 0.4470 0.7410], 'DisplayName', 'Measured');
    plot(steps, y_nom(ch,:), 'k--', 'LineWidth', 2.5, 'DisplayName', 'True');
    ylabel(sprintf('$y_{%d}$', ch), 'Interpreter', 'latex', 'FontSize', 18);
    set(gca, 'FontSize', 14, 'TickLabelInterpreter', 'latex');
    legend('Interpreter', 'latex', 'Location', 'southwest', 'FontSize', 12);

    xlabel(tl, '$k$', 'Interpreter', 'latex', 'FontSize', 18);
    linkaxes([ax1, ax2], 'x');
    xlim(zoom_win);

    export_figure(f, fullfile(out_dir, 'fig2_measurements.pdf'), [16, 12]);
end
