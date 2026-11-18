function fig1_trajectories(params, out_dir)
%FIG1_TRAJECTORIES Fig. 1: state estimates x3, x4 of the nominal (102),
%   finite-memory stubborn (103) and scalar stubborn (104) observers.
%   Left: T_dwell = 3, non-zero initial conditions.
%   Right: T_dwell = 1, zero initial conditions.

    fprintf('\n--- Fig. 1: trajectories ---\n');
    N = params.sim.N;
    u = params.sim.input;
    C = params.plant.C_d;

    dwell_times = [3, 1];
    x0_list     = {5 * [1; 0; -1; 0], zeros(4, 1)};   % observer initial states (x_0 = 0)
    results     = cell(1, 2);

    for i = 1:2
        x0 = x0_list{i};

        res.x_true = zeros(4, N);
        res.x_hat  = zeros(4, N); res.x_hat(:,1)  = x0;
        res.x_stub = zeros(4, N); res.x_stub(:,1) = x0;
        res.x_scal = zeros(4, N); res.x_scal(:,1) = x0;

        sigma0 = max(abs(C * x0));
        Sigma  = sigma0 * ones(params.stubborn.tau, 1);
        s      = sigma0;

        noise = disturbance_generator(params.sim.f_bar, dwell_times(i), N, 2);

        for k = 1:N-1
            res.x_true(:, k+1) = simulate_FMJ(res.x_true(:, k), u(k), params);
            y_k = C * res.x_true(:, k) + noise(:, k);

            res.x_hat(:, k+1) = observer_FMJ(res.x_hat(:, k), u(k), y_k, params);
            [res.x_stub(:, k+1), Sigma] = observer_stubborn_finite_memory(res.x_stub(:, k), u(k), y_k, Sigma, params);
            [res.x_scal(:, k+1), s]     = observer_stubborn_scalar(res.x_scal(:, k), u(k), y_k, s, params);
        end
        results{i} = res;
    end

    f = figure(1); clf(f);
    plot_time_domain_comparison(0:N-1, results{1}, results{2}, params);
    export_figure(f, fullfile(out_dir, 'fig1_trajectories.pdf'), [24.38, 10.05], 'Padding', 'figure');
end
