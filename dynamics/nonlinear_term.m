function f_nl = nonlinear_term(x, p)
%NONLINEAR_TERM Nonlinear term phi(x) of the FJM: motor friction and gravity.

    J_m = p.system.J_m;
    J_l = p.system.J_l;

    if p.sim.ENABLE_FRICTION == 1
        % Motor: Stribeck + Coulomb friction, smoothed with tanh
        v_m = x(2);
        eps_tanh = 1e-2;
        stribeck = (p.plant.F_S_m - p.plant.F_C_m) * exp(-(abs(v_m)/p.plant.v_s_m)^p.plant.p_m);
        tau_m = (p.plant.F_C_m + stribeck) * tanh(v_m/eps_tanh);
    else
        tau_m = 0;
    end
    tau_l = 0; % undamped link

    grav = -p.plant.s * sin(x(3));
    f_nl = [0; -tau_m/J_m; 0; (grav - tau_l)/J_l];
end
