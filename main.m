%% FMJ Finite-Memory Stubborn Observer Implementation
% Simulation of a Flexible Joint Manipulator (FJM) under measurement
% outliers. Compares a Nominal Luenberger Observer vs. a Finite-Memory
% Stubborn Observer.
%
% Structure:
% 1. Configuration
% 2. Single Run Simulation (Dwell Time Condition)
% 3. Monte Carlo Analysis (RMSE Boxplots)
% 4. Transient Analysis (Effect of Threshold Theta)

clear; clc; close all; format long;

% Add paths
addpath(genpath('config'));
addpath(genpath('dynamics'));
addpath(genpath('observers'));
addpath(genpath('utils'));

% =============================================================
% 1. CONFIGURATION & SETUP
% =============================================================
% --- Simulation Flags ---
RUN_SINGLE_SIM = true;   % Run standard time-domain simulation
RUN_MONTE_CARLO = false; % Run statistical analysis 
RUN_TRANSIENT = true;    % Run Theta sensitivity analysis

% --- General Settings ---
params = get_FJM_config(); % Load system matrices and physics
T_s = params.sim.T_s;
T_sample = T_s;
A = params.plant.A_d;
B = params.plant.B_d;
C = params.plant.C_d;

T_sim = 4;        % Simulation Length (s)
N = floor(T_sim / T_s); % Number of steps
f_bar = 50;       % Dispersion factor of outliers

% Update params with stubborn and observer settings
params.stubborn.tau = 4;
params.stubborn.Theta = 0.02;
params.observer.L_nom = nominal_gainK(params);

%% 
% =============================================================
% 2. SINGLE RUN SIMULATION (Nominal vs Stubborn)
% =============================================================
if RUN_SINGLE_SIM
    fprintf('\n--- Starting Single Simulation ---\n');
    steps = 0:N-1;

    % SCENARIO A: Tdwell = 5
    Tdwell = 5;
    x0_error = 5 * [1; 0; -1; 0];
    
    x_true = zeros(4, N);
    x_hat = zeros(4, N);
    x_hat(:,1) = x0_error;
    
    x_stub = zeros(4, N);
    x_stub(:,1) = x0_error;
    
    % Memory Initialization
    Delta_k = zeros(1, N);
    sigma_val = max(abs(C * x0_error));
    Sigma_k = sigma_val * ones(params.stubborn.tau, 1);
    
    noise_1 = disturbance_generator(f_bar, Tdwell, N, 2);

    % Simulation Loop
    for k = 1:N-1
        u_k = 2 * sin(4*k * T_sample);
        
        % Plant & Observers
        x_true(:, k+1) = simulate_FMJ(x_true(:, k), u_k, params);
        y_meas_k = C * x_true(:, k) + noise_1(:, k);
        
        x_hat(:, k+1) = observer_FMJ(x_hat(:, k), u_k, y_meas_k, params);
        [x_stub(:, k+1), Sigma_k, Delta_k(k+1)] = observer_stubborn_finite_memory(...
            x_stub(:, k), u_k, y_meas_k, Sigma_k, params);
    end

    % Plotting
    figure(1)
    plot_time_domain(steps, x_true, x_hat, x_stub, params);

    % SCENARIO B: Tdwell = 2
    Tdwell = 2;
    x_true = zeros(4, N);
    x_hat = zeros(4, N);
    x_stub = zeros(4, N);
    
    % Memory Initialization
    Delta_k = zeros(1, N);
    Sigma_k = zeros(params.stubborn.tau, 1);
    
    noise_2 = disturbance_generator(f_bar, Tdwell, N, 2);

    for k = 1:N-1
        u_k = 2 * sin(4*k * T_sample);
        
        % Plant & Observers
        x_true(:, k+1) = simulate_FMJ(x_true(:, k), u_k, params);
        y_meas_k = C * x_true(:, k) + noise_2(:, k) ;
        
        x_hat(:, k+1) = observer_FMJ(x_hat(:, k), u_k, y_meas_k, params);
        [x_stub(:, k+1), Sigma_k, Delta_k(k+1)] = observer_stubborn_finite_memory(...
            x_stub(:, k), u_k, y_meas_k, Sigma_k, params);
    end

    figure(2)
    plot_time_domain(steps, x_true, x_hat, x_stub, params)
end

%% =============================================================
% ----------------------- MONTE CARLO --------------------------
% ==============================================================
if RUN_MONTE_CARLO
    fprintf('\n--- Starting Monte Carlo Analysis ---\n');
    N_RUNS = 10; % Reduced for quick testing, set to 10000 for paper

    % Scenarios to test
    scenarios = struct('dwell', {5, 2}, 'name', {'Tdwell Condition Validated', 'Tdwell Condition not Validated'});
    
    figure(3);
    t = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    for s = 1:length(scenarios)
        dwell = scenarios(s).dwell;
        fprintf('Processing Scenario %d: %s (T_dwell=%d)...\n', s, scenarios(s).name, dwell);
        
        RMSE_nom = zeros(N_RUNS, 1);
        RMSE_stub = zeros(N_RUNS, 1);
        
        % Parallel loop (requires Parallel Computing Toolbox)
        parfor run = 1:N_RUNS
            % Random Init
            x_t = zeros(4, N);
            x_h = zeros(4, N);
            x_s = zeros(4, N);
            init_err = 0.1 * randn(4,1);
            
            x_h(:,1) = init_err;
            x_s(:,1) = init_err;
            
            % Init Memory
            sig_v = max(abs(C * init_err));
            Sig_k = sig_v * ones(params.stubborn.tau, 1);
            
            % Noise
            nz = disturbance_generator(20, dwell, N, 2);
            
            for k = 1:N-1
                u = 2 * sin(4 * k * T_s);
                x_t(:, k+1) = simulate_FMJ(x_t(:, k), u, params);
                y = C * x_t(:, k) + nz(:, k);
                
                x_h(:, k+1) = observer_FMJ(x_h(:, k), u, y, params);
                [x_s(:, k+1), Sig_k, ~] = observer_stubborn_finite_memory(...
                    x_s(:, k), u, y, Sig_k, params);
            end
            
            % Compute RMSE
            RMSE_nom(run) = sqrt(mean(vecnorm(x_t - x_h).^2));
            RMSE_stub(run) = sqrt(mean(vecnorm(x_t - x_s).^2));
        end

        % Boxplot
        nexttile;
        data = [RMSE_nom; RMSE_stub];
        groups = [repmat({'Nominal'}, N_RUNS, 1); repmat({'Stubborn'}, N_RUNS, 1)];
        
        h = boxplot(data, groups, 'Widths', 0.5);
        apply_custom_style(h, RMSE_nom, RMSE_stub);
        ylabel('RMSE', 'Interpreter', 'latex');
        ylim([0 20]);
    end
end

%% =============================================================
% ----------------------- TRANSIENT --------------------------
% ==============================================================
if RUN_TRANSIENT
    fprintf('\n--- Starting Theta Sensitivity Analysis ---\n');
    Theta_vals = [0.005, 0.01, 0.02, 0.5];
    x0_err = 10 * [2; 0; -1; 0];
    colors = [
        0.0000, 0.4470, 0.7410; % Blu (Theta 0.005)
        0.8500, 0.3250, 0.0980; % Rosso (Theta 0.01)
        0.4940, 0.1840, 0.5560; % Viola (Theta 0.02 )
        0.9290, 0.6940, 0.1250  % Giallo (Theta 0.5)
    ];

    % Baseline Nominal
    x_t = zeros(4, N);
    x_h = zeros(4, N);
    x_h(:,1) = x0_err;
    
    for k = 1:N-1
        x_t(:, k+1) = simulate_FMJ(x_t(:, k), 0, params);
        y = C * x_t(:, k);
        x_h(:, k+1) = observer_FMJ(x_h(:, k), 0, y, params);
    end
    err_nom = vecnorm(x_t - x_h);
    
    figure();
    hold on; grid on;
    for i = 1:length(Theta_vals)
        p_sens = params;
        p_sens.stubborn.Theta = Theta_vals(i);
        
        x_s = zeros(4, N);
        x_s(:,1) = x0_err;
        Sig = max(abs(C*x0_err)) * ones(p_sens.stubborn.tau, 1);
        
        for k = 1:N-1
            y = C * x_t(:, k); % Clean measurement
            [x_s(:, k+1), Sig, ~] = observer_stubborn_finite_memory(...
                x_s(:, k), 0, y, Sig, p_sens);
        end
        err_stub = vecnorm(x_t - x_s);
        
        plot(0:N-1, err_stub, 'LineWidth', params.style.lw_stub, 'Color', colors(i,:), ...
            'DisplayName', sprintf('$\\Theta = %.3f$', Theta_vals(i)));
    end
    
    plot(0:N-1, err_nom, 'k--', 'LineWidth', params.style.lw_stub, 'DisplayName', 'Nominal');
    
    xlabel('$k$', 'Interpreter', 'latex', 'FontSize', 16);
    ylabel('$|e_k|$', 'Interpreter', 'latex', 'FontSize', 16);
    xlim([0 500]);
    yticks(0:20:80);
    ylim([0 85]);
    set(gca, 'FontSize', 14);
    lgd = legend;
    set(lgd, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 14);
    
    % f = gcf;
    % set(f, 'Units', 'centimeters');
    % set(f, 'Position', [0 0 16 10]);
    % exportgraphics(f, 'Figure_Transient.pdf', 'ContentType', 'vector');
end
