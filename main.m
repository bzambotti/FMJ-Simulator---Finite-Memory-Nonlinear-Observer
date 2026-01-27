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
RUN_MONTE_CARLO = true; % Run statistical analysis 
RUN_TRANSIENT = true;    % Run Theta sensitivity analysis
RUN_BREAKDOWN = true;
% --- General Settings ---
params = get_FJM_config(); % Load system matrices and physics
T_s = params.sim.T_s;
T_sample = T_s;
A = params.plant.A_d;
B = params.plant.B_d;
C = params.plant.C_d;

T_sim = 4;        % Simulation Length (s)
N = floor(T_sim / T_s); % Number of steps
f_bar = 20;       % Dispersion factor of outliers

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
    
    N = floor(T_sim / T_s);
    steps = 0:N-1;
    x0_error = 5 * [1; 0; -1; 0];
    dwell_times = [5, 2];
    
    % Usiamo una cell array per salvare i risultati dei due scenari
    results = cell(1, 2); 

    for i = 1:length(dwell_times)
        Tdwell = dwell_times(i);
        
        % Inizializzazione locale per lo scenario corrente
        res.x_true = zeros(4, N);
        res.x_hat  = zeros(4, N); 
        if i == 2 
            x0_error = 0*x0_error;
            sigma_val = 0*sigma_val;
        end

        res.x_hat(:,1)  = x0_error;
        res.x_stub = zeros(4, N); res.x_stub(:,1) = x0_error;
        
        % Memory Initialization
        sigma_val = max(abs(C * x0_error));
        Sigma_k   = sigma_val * ones(params.stubborn.tau, 1);
        
        % Generazione disturbo specifica per questo Tdwell
        noise = disturbance_generator(f_bar, Tdwell, N, 2);
        
        % Simulation Loop
        for k = 1:N-1
            u_k = 2 * sin(4 * k * T_sample); 
            
            % Plant
            res.x_true(:, k+1) = simulate_FMJ(res.x_true(:, k), u_k, params);
            y_meas_k = C * res.x_true(:, k) + noise(:, k);
            
            % Observers
            res.x_hat(:, k+1) = observer_FMJ(res.x_hat(:, k), u_k, y_meas_k, params);
            [res.x_stub(:, k+1), Sigma_k, ~] = observer_stubborn_finite_memory(...
                res.x_stub(:, k), u_k, y_meas_k, Sigma_k, params);
        end
        
        % Salviamo la struct temporanea nella cell array
        results{i} = res;
    end

    % Chiamata alla funzione usando gli indici della cell array
    figure(2)
    plot_time_domain_comparison(steps, results{1}, results{2}, params)
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

%% =============================================================
% 4. MONTE CARLO ANALYSIS 
% ==============================================================
if RUN_MONTE_CARLO
    fprintf('\n--- Starting Monte Carlo Analysis with Theta Sensitivity ---\n');
    
    % Settings
    N_RUNS = 10; % Reduced for testing (use 1000/10000 for paper)
    theta_test = [0.02, 0.5, 10]; 
    scenarios = struct('dwell', {5, 2}, 'name', {'Condition Validated ($T_d=5$)', 'Condition Violated ($T_d=2$)'});
    
    figure(4); clf;
    set(gcf, 'Color', 'w');
    t = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    for s = 1:length(scenarios)
        dwell = scenarios(s).dwell;
        fprintf('Processing Scenario %d: T_dwell=%d...\n', s, dwell);
        
        % Data Matrix: [Nominal, Stubborn_Th1, Stubborn_Th2, ...]
        num_cols = 1 + length(theta_test);
        results = zeros(N_RUNS, num_cols);
        
        parfor run = 1:N_RUNS
            local_res = zeros(1, num_cols);
            
            % Random Init
            bound = 0.5;
            init_err = (rand(4,1) - 0.5) * 2 * bound; 
            
            % True Trajectory
            x_t = zeros(4, N);
            
            % Noise Generation
            nz = disturbance_generator(20, dwell, N, 2);
            
            % Simulate Plant
            for k = 1:N-1
                u_k = 2 * sin(4 * k * T_s);
                x_t(:, k+1) = simulate_FMJ(x_t(:, k), u_k, params);
            end
            
            % 1. Nominal Observer
            x_h = zeros(4, N); 
            x_h(:,1) = x_t(:,1) - init_err;
            
            for k = 1:N-1
                u_k = 2 * sin(4 * k * T_s);
                y_k = C * x_t(:, k) + nz(:, k);
                x_h(:, k+1) = observer_FMJ(x_h(:, k), u_k, y_k, params);
            end
            local_res(1) = sqrt(mean(vecnorm(x_t - x_h).^2)); 
            
            % 2. Stubborn Variants
            for j = 1:length(theta_test)
                p_v = params;
                p_v.stubborn.Theta = theta_test(j);
                
                x_s = zeros(4, N); 
                x_s(:,1) = x_t(:,1) - init_err;
                Sig_v = max(abs(C * init_err)) * ones(params.stubborn.tau, 1);
                
                for k = 1:N-1
                    u_k = 2 * sin(4 * k * T_s);
                    y_k = C * x_t(:, k) + nz(:, k);
                    [x_s(:, k+1), Sig_v, ~] = observer_stubborn_finite_memory(...
                        x_s(:, k), u_k, y_k, Sig_v, p_v);
                end
                local_res(j+1) = sqrt(mean(vecnorm(x_t - x_s).^2));
            end
            
            results(run, :) = local_res;
        end
        
        % --- PLOTTING BOXPLOTS ---
        nexttile;
        labels = [{'Nominal'}, arrayfun(@(x) sprintf('$\\Theta=%.2g$', x), theta_test, 'UniformOutput', false)];
        h = boxplot(results, 'Labels', labels, 'Widths', 0.6);
        apply_custom_style(h, results, params);

        if s == 1
            ylabel('RMSE', 'Interpreter', 'latex', 'FontSize', 14);
        else
            ylabel(''); set(gca, 'YTickLabel', []);
        end
        yline(median(results(:,1)), 'r:', 'LineWidth', 1.5, 'Alpha', 0.5);
        
        % --- STATISTICAL TEST (Wilcoxon) ---
        % Test Nominal (Col 1) vs Stubborn Optimal (Col 2, i.e., Theta=0.02)
        p_val = signrank(results(:,1), results(:,2), 'tail', 'right');
        fprintf('  -> Wilcoxon Test (Nom vs Stub_Opt): p-value = %.5e\n', p_val);
    end
    
    f = gcf;
    set(f, 'Units', 'centimeters', 'Position', [10 10 19*4/3 9*4/3]);
    set(f, 'PaperPositionMode', 'auto');
    % exportgraphics(f, 'Figure_Boxplots.pdf', 'ContentType', 'vector');
end

%% =============================================================
% 5. BREAKDOWN ANALYSIS (Finding Max Theta) - NEW SECTION
% ==============================================================
if RUN_BREAKDOWN
    fprintf('\n--- Starting Breakdown Analysis (Finding Theta_max) ---\n');
    
    % Sweep parameters
    theta_sweep = logspace(log10(4), log10(5), 10); % 20 points from 0.01 to 5
    p_values_sweep = zeros(size(theta_sweep));
    N_TEST_RUNS = 1000; % Reduced for speed (increase for precision)
    
    % Use T_dwell = 5 (Standard valid condition)
    Tdwell_BD = 5;
    
    % Pre-calculate Nominal Baseline once (it doesn't change with Theta)
    fprintf('  Calculating baseline...\n');
    rmse_nom_base = zeros(N_TEST_RUNS, 1);
    
    % We need to store seeds or re-generate same noise for paired test?
    % For Breakdown analysis, we re-run loop cleanly.
    
    parfor run = 1:N_TEST_RUNS
        % Setup run (same logic as MC)
        bound = 0.5;
        init_err = (rand(4,1) - 0.5) * 2 * bound; 
        nz = disturbance_generator(20, Tdwell_BD, N, 2);
        
        % Plant
        x_t = zeros(4, N);
        for k=1:N-1, x_t(:,k+1)=simulate_FMJ(x_t(:,k), 2*sin(4*k*T_s), params); end
        
        % Nominal Observer
        x_h = zeros(4, N); x_h(:,1)=x_t(:,1)-init_err;
        for k=1:N-1
             u=2*sin(4*k*T_s); y=C*x_t(:,k)+nz(:,k);
             x_h(:,k+1)=observer_FMJ(x_h(:,k),u,y,params);
        end
        rmse_nom_base(run) = sqrt(mean(vecnorm(x_t-x_h).^2));
    end

    % Loop over Theta values
    for i = 1:length(theta_sweep)
        th_curr = theta_sweep(i);
        rmse_stub_curr = zeros(N_TEST_RUNS, 1);
        
        % We must re-generate SIMILAR statistical conditions.
        % Ideally, we should reuse the exact same noise matrix, but for 
        % statistical breakdown across 200 runs, independent sampling is ok 
        % IF we use 'ranksum' (unpaired) or if we are careful.
        % Let's use simplified re-generation for speed/clarity here.
        
        parfor run = 1:N_TEST_RUNS
            % Re-gen (Statistically identical conditions)
            bound = 0.5;
            init_err = (rand(4,1) - 0.5) * 2 * bound; 
            nz = disturbance_generator(20, Tdwell_BD, N, 2);
            
            % Plant
            x_t = zeros(4, N);
            for k=1:N-1, x_t(:,k+1)=simulate_FMJ(x_t(:,k), 2*sin(4*k*T_s), params); end
            
            % Stubborn Observer
            p_v = params; p_v.stubborn.Theta = th_curr;
            x_s = zeros(4, N); x_s(:,1)=x_t(:,1)-init_err;
            Sig = max(abs(C*init_err))*ones(4,1);
            
            for k=1:N-1
                u=2*sin(4*k*T_s); y=C*x_t(:,k)+nz(:,k);
                [x_s(:,k+1), Sig] = observer_stubborn_finite_memory(x_s(:,k),u,y,Sig,p_v);
            end
            rmse_stub_curr(run) = sqrt(mean(vecnorm(x_t-x_s).^2));
        end
        
        % Wilcoxon Rank Sum Test (Mann-Whitney) since runs are not strictly paired step-by-step here
        % 'tail','right' -> checks if Median(Nominal) > Median(Stubborn)
        p_val = ranksum(rmse_nom_base, rmse_stub_curr, 'tail', 'right');
        p_values_sweep(i) = p_val;
        
        fprintf('  Theta: %.3f -> p-value: %.5f\n', th_curr, p_val);
    end
end

