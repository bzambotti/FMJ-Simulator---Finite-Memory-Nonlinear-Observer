function results = run_rmse_experiment(params, N, T_s, f_bar, dwell, theta_list)
    % Inputs:
    %   params: system parameters struct
    %   N: number of simulation steps
    %   T_s: sampling time
    %   f_bar: outlier dispersion factor
    %   dwell: disturbance dwell time
    %   theta_list: vector of Theta values to test for Stubborn Observer
    %
    % Outputs:
    %   results: vector [rmse_nom, rmse_stub_1, rmse_stub_2, ...]

    % Random Initialization
    bound = 0.5;
    init_err = (rand(4,1) - 0.5) * 2 * bound;

    % Generate Disturbance
    % nd = 2 (as used in main.m)
    nz = disturbance_generator(f_bar, dwell, N, 2);

    % Plant Simulation
    x_t = zeros(4, N);
    % x_t(:,1) is implicitly 0 (zeros)
    
    for k = 1:N-1
        u_k = 2 * sin(4 * k * T_s);
        x_t(:, k+1) = simulate_FMJ(x_t(:, k), u_k, params);
    end

    C = params.plant.C_d;

    % 1. Nominal Observer
    x_h = zeros(4, N);
    x_h(:,1) = x_t(:,1) - init_err;

    for k = 1:N-1
        u_k = 2 * sin(4 * k * T_s);
        y_k = C * x_t(:, k) + nz(:, k);
        x_h(:, k+1) = observer_FMJ(x_h(:, k), u_k, y_k, params);
    end
    rmse_nom = sqrt(mean(vecnorm(x_t - x_h).^2));

    % 2. Stubborn Observers
    num_thetas = length(theta_list);
    rmse_stub_list = zeros(1, num_thetas);

    for j = 1:num_thetas
        p_v = params;
        p_v.stubborn.Theta = theta_list(j);

        x_s = zeros(4, N);
        x_s(:,1) = x_t(:,1) - init_err;
        Sig_v = max(abs(C * init_err)) * ones(params.stubborn.tau, 1);

        for k = 1:N-1
            u_k = 2 * sin(4 * k * T_s);
            y_k = C * x_t(:, k) + nz(:, k);
            [x_s(:, k+1), Sig_v, ~] = observer_stubborn_finite_memory(...
                x_s(:, k), u_k, y_k, Sig_v, p_v);
        end
        rmse_stub_list(j) = sqrt(mean(vecnorm(x_t - x_s).^2));
    end

    results = [rmse_nom, rmse_stub_list];
end
