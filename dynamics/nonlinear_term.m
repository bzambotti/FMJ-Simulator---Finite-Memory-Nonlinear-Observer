% 2.2 Simulation of the nonlinear dynamics
function f_nonlinear = nonlinear_term(x, p)
    % Parameters extraction
    J_m = p.system.J_m;
    J_l = p.system.J_l;
    if p.sim.ENABLE_FRICTION == 1
        % --- MOTOR (Stribeck + Coulomb) ---
        v_m = x(2);
        eps = 1e-2;
        str_m = (p.plant.F_S_m - p.plant.F_C_m) * exp(-(abs(v_m)/p.plant.v_s_m)^p.plant.p_m);
        tau_m = (p.plant.F_C_m + str_m) * tanh(v_m/eps);
        % --- LINK (Undamped / Senza Attrito) ---
        tau_l = 0;
    else
        tau_m = 0;
        tau_l = 0;
    end
    % Gravity
    grav = -p.plant.s * sin(x(3));
    f_nonlinear = [0; -tau_m/J_m; 0; (grav - tau_l)/J_l];
end
