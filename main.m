%% Exact outlier cancellation: FJM simulations
% Regenerates all the figures of the simulation section of the paper
% "Exact Outlier Cancellation in Discrete-Time Observers via Stubborn
% Redesign" (flexible joint manipulator example).
%
%   Fig. 1  scripts/fig1_trajectories.m     -> figures/fig1_trajectories.pdf
%   Fig. 2  scripts/fig2_measurements.m     -> figures/fig2_measurements.pdf
%   Fig. 3  scripts/fig3_theta_transient.m  -> figures/fig3_theta_transient.pdf
%   Fig. 4  scripts/fig4_montecarlo_rmse.m  -> figures/fig4_montecarlo_rmse.pdf
%
% The seed is fixed once here and the figures are generated in this order,
% so the random outlier realizations are the same at every run.
% Requirements: MATLAB (R2020a or newer), YALMIP, MOSEK,
% Statistics and Machine Learning Toolbox (Fig. 4 only).

clear; clc; close all;

% --- Options ---
RUN_MONTE_CARLO = true;   % Fig. 4 (slow with 10^4 runs; it is generated last)
N_RUNS          = 1e4;    % Monte Carlo runs per scenario (10^4 in the paper)
SEED            = 1;

% --- Paths (relative to this file) ---
% mfilename is empty when the code is run by sections or pasted in the
% Command Window: in that case the current folder must be the repository.
root_dir = fileparts(mfilename('fullpath'));
if isempty(root_dir)
    root_dir = pwd;
end
assert(isfile(fullfile(root_dir, 'utils', 'compute_theta_star.m')), ...
    'Repository folder not found: cd to the folder that contains main.m and run "main".');
for d = {'config', 'dynamics', 'observers', 'utils', 'scripts'}
    addpath(fullfile(root_dir, d{1}));
end
out_dir = fullfile(root_dir, 'figures');
if ~exist(out_dir, 'dir'), mkdir(out_dir); end

rng(SEED, 'twister');

% --- Model and nominal gain ---
params = get_FJM_config();
A = params.plant.A_d;
C = params.plant.C_d;
params.observer.L_nom = nominal_gainK(params);

rho_L = max(abs(eig(A - params.observer.L_nom * C)));
fprintf('max |eig(A - L*C)| = %.4f\n', rho_L);
assert(rho_L < 1, 'The nominal gain does not stabilize A - L*C: check YALMIP/MOSEK.');

% --- Theoretical bound Theta*_lin, eq. (41) (reported in the text) ---
[Theta_star, c_gamma] = compute_theta_star(params);
fprintf('tau = %d, c_gamma = %e, Theta*_lin = %e\n', params.stubborn.tau, c_gamma, Theta_star);

% --- Figures (keep this order: it fixes the random draws of each figure) ---
fig1_trajectories(params, out_dir);
fig2_measurements(params, out_dir);
fig3_theta_transient(params, out_dir);
if RUN_MONTE_CARLO
    fig4_montecarlo_rmse(params, out_dir, N_RUNS);
end
