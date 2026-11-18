function results = run_rmse_experiment(params, dwell, theta_list)
%RUN_RMSE_EXPERIMENT One Monte Carlo run for Fig. 4.
%   results = RUN_RMSE_EXPERIMENT(params, dwell, theta_list) draws a random
%   initial error in [-0.5, 0.5]^4 and one outlier realization, then returns
%   [rmse_nominal, rmse_stubborn(theta_list(1)), rmse_stubborn(theta_list(2)), ...].
%   All observers share the same initial error and outlier realization.

    N     = params.sim.N;
    u     = params.sim.input;
    C     = params.plant.C_d;
    bound = 0.5;

    init_err = (rand(4,1) - 0.5) * 2 * bound;
    nz = disturbance_generator(params.sim.f_bar, dwell, N, 2);

    % Plant (x_0 = 0)
    x_t = zeros(4, N);
    for k = 1:N-1
        x_t(:, k+1) = simulate_FMJ(x_t(:, k), u(k), params);
    end

    % Nominal observer
    x_h = zeros(4, N);
    x_h(:,1) = x_t(:,1) - init_err;
    for k = 1:N-1
        y_k = C * x_t(:, k) + nz(:, k);
        x_h(:, k+1) = observer_FMJ(x_h(:, k), u(k), y_k, params);
    end
    rmse_nom = sqrt(mean(vecnorm(x_t - x_h).^2));

    % Finite-memory stubborn observers, one per Theta
    rmse_stub = zeros(1, numel(theta_list));
    for j = 1:numel(theta_list)
        p_j = params;
        p_j.stubborn.Theta = theta_list(j);

        x_s = zeros(4, N);
        x_s(:,1) = x_t(:,1) - init_err;
        Sigma = max(abs(C * init_err)) * ones(params.stubborn.tau, 1);
        for k = 1:N-1
            y_k = C * x_t(:, k) + nz(:, k);
            [x_s(:, k+1), Sigma] = observer_stubborn_finite_memory(x_s(:, k), u(k), y_k, Sigma, p_j);
        end
        rmse_stub(j) = sqrt(mean(vecnorm(x_t - x_s).^2));
    end

    results = [rmse_nom, rmse_stub];
end
