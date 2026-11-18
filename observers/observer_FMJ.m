function x_hat_next = observer_FMJ(x_hat_k, u_k, y_meas, params)
%OBSERVER_FMJ Nominal observer (102): x+ = A x + B u + Ts*phi(x) + L (y - C x).

    A  = params.plant.A_d;
    B  = params.plant.B_d;
    C  = params.plant.C_d;
    L  = params.observer.L_nom;
    Ts = params.sim.T_s;

    y_hat = C * x_hat_k;
    x_hat_next = A * x_hat_k + B * u_k + Ts * nonlinear_term(x_hat_k, params) ...
                 + L * (y_meas - y_hat);
end
