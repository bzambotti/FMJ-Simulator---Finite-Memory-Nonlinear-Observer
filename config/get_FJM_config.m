function params = get_FJM_config()
    % 1. ORIGINAL SYSTEM
    Ac = [0 1 0 0; -48.6 -1.25 48.6 0; 0 0 0 1; 19.5 0 -19.5 0];
    Bc = [0; 21.6; 0; 0];
    C = [1 0 0 0; 0 1 0 0];
    Jm_calc = 1 / Bc(2);
    K_stiff = -Ac(2,1) * Jm_calc;
    Jl_calc = -K_stiff / Ac(4,3);
    T_sample = 0.005;
    A = eye(4) + Ac * T_sample;
    B = Bc * T_sample;
    params.sim.T_s = T_sample;
    params.plant.A_d = A;
    params.plant.B_d = B;
    params.plant.C_d = C;
    params.plant.s = 3.33; % mgl/Jl
    params.system.J_m = Jm_calc;
    params.system.J_l = Jl_calc;
    % Parametri Attrito (Stribeck)
    params.sim.ENABLE_FRICTION = 1; % Motore
    params.plant.F_C_m = 0.1;
    params.plant.F_S_m = 0.08;
    params.plant.v_s_m = 0.01;
    params.plant.p_m = 2; % Link
    params.plant.F_C_l = 0.1;
    params.plant.F_S_l = 0.08;
    params.plant.v_s_l = 0.01;
    params.plant.p_l = 2;
    % Style Plots
    params.style.c_true = [0 0 0];
    params.style.c_nom = [0.3, 0.3, 0.75];
    params.style.c_stub = [1 0.1 0.1];
    params.style.lw_true = 2.5;
    params.style.lw_nom = 2.0;
    params.style.lw_stub = 3.2;
end
