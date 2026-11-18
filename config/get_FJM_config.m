function params = get_FJM_config()
%GET_FJM_CONFIG Parameters of the flexible joint manipulator (FJM) example.
%   params = GET_FJM_CONFIG() returns a struct with the discretized plant,
%   the friction model, the simulation settings, the observer tuning used
%   in the paper and the plot style.

    % --- Continuous-time linear part (x = [q_m; dq_m; q_l; dq_l]) ---
    Ac = [0 1 0 0; -48.6 -1.25 48.6 0; 0 0 0 1; 19.5 0 -19.5 0];
    Bc = [0; 21.6; 0; 0];
    C  = [1 0 0 0; 0 1 0 0];

    % Inertias and stiffness recovered from the model coefficients
    J_m     = 1 / Bc(2);
    K_stiff = -Ac(2,1) * J_m;
    J_l     = -K_stiff / Ac(4,3);

    % --- Forward-Euler discretization ---
    T_s = 0.005;
    params.sim.T_s   = T_s;
    params.plant.A_d = eye(4) + Ac * T_s;
    params.plant.B_d = Bc * T_s;
    params.plant.C_d = C;

    % --- Nonlinear terms ---
    params.plant.s    = 3.33;   % gravity coefficient m*g*l/J_l
    params.system.J_m = J_m;
    params.system.J_l = J_l;

    % Motor friction (Stribeck + Coulomb); the link is undamped
    params.sim.ENABLE_FRICTION = 1;
    params.plant.F_C_m = 0.1;
    params.plant.F_S_m = 0.08;
    params.plant.v_s_m = 0.01;
    params.plant.p_m   = 2;

    % --- Simulation settings ---
    params.sim.T_sim = 4;                                % horizon (s)
    params.sim.N     = floor(params.sim.T_sim / T_s);    % number of steps
    params.sim.f_bar = 20;                               % outlier dispersion factor
    params.sim.input = @(k) 2 * sin(4 * k * T_s);        % input u_k

    % --- Finite-memory stubborn observer (103) ---
    params.stubborn.tau   = 3;
    params.stubborn.Theta = 0.02;

    % --- Scalar stubborn observer (104), lambda_s = r = 0.5 ---
    params.scalar.lambda = 0.5;
    params.scalar.Theta  = 0.02;

    % --- Plot style ---
    params.style.c_true  = [0 0 0];
    params.style.c_nom   = [0.3, 0.3, 0.75];
    params.style.c_stub  = [1 0.1 0.1];
    params.style.c_scal  = '#16b81b';
    params.style.lw_true = 2.5;
    params.style.lw_nom  = 2.0;
    params.style.lw_stub = 3.2;
end
