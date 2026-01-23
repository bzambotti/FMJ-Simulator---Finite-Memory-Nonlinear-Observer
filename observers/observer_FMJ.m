% 3. NOMINAL OBSERVER
function x_hat_next = observer_FMJ(x_hat_k, u_k, y_meas, params)
    A = params.plant.A_d;
    B = params.plant.B_d;
    C = params.plant.C_d;
    L = params.observer.L_nom;
    Ts = params.sim.T_s;
    f_nl = nonlinear_term(x_hat_k, params);
    y_hat = C * x_hat_k;
    x_hat_next = A * x_hat_k + B * u_k + Ts * f_nl + L * (y_meas - y_hat);
end
