function fig3_theta_transient(params, out_dir)
%FIG3_THETA_TRANSIENT Fig. 3: estimation error norm |e_k| in a noise-free
%   scenario, nominal observer vs finite-memory stubborn observer for
%   several values of Theta (u = 0).

    fprintf('\n--- Fig. 3: Theta transient ---\n');
    N = params.sim.N;
    C = params.plant.C_d;

    Theta_vals = [0.0002, 0.005, 0.01, 0.02, 0.5];
    colors = [0.6350, 0.0780, 0.1840;   % Theta = 0.0002
              0.0000, 0.4470, 0.7410;   % Theta = 0.005
              0.8500, 0.3250, 0.0980;   % Theta = 0.01
              0.4940, 0.1840, 0.5560;   % Theta = 0.02
              0.9290, 0.6940, 0.1250];  % Theta = 0.5
    x0_err = 10 * [2; 0; -1; 0];

    % Plant and nominal observer (clean measurements)
    x_t = zeros(4, N);
    x_h = zeros(4, N); x_h(:,1) = x0_err;
    for k = 1:N-1
        x_t(:, k+1) = simulate_FMJ(x_t(:, k), 0, params);
        x_h(:, k+1) = observer_FMJ(x_h(:, k), 0, C * x_t(:, k), params);
    end
    err_nom = vecnorm(x_t - x_h);

    f = figure(3); clf(f);
    hold on; grid on; box on;
    for i = 1:numel(Theta_vals)
        p_i = params;
        p_i.stubborn.Theta = Theta_vals(i);

        x_s = zeros(4, N); x_s(:,1) = x0_err;
        Sigma = max(abs(C * x0_err)) * ones(p_i.stubborn.tau, 1);
        for k = 1:N-1
            [x_s(:, k+1), Sigma] = observer_stubborn_finite_memory(x_s(:, k), 0, C * x_t(:, k), Sigma, p_i);
        end
        plot(0:N-1, vecnorm(x_t - x_s), 'LineWidth', 2, 'Color', colors(i,:), ...
             'DisplayName', sprintf('$\\Theta = %g$', Theta_vals(i)));
    end
    plot(0:N-1, err_nom, 'k--', 'LineWidth', params.style.lw_stub, 'DisplayName', 'Nominal');

    xlabel('$k$', 'Interpreter', 'latex', 'FontSize', 16);
    ylabel('$|e_k|$', 'Interpreter', 'latex', 'FontSize', 16);
    xlim([0 800]);
    yticks(0:20:100);
    ylim([0 100]);
    set(gca, 'FontSize', 14);
    legend('Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 14);

    export_figure(f, fullfile(out_dir, 'fig3_theta_transient.pdf'), [16, 8]);
end
