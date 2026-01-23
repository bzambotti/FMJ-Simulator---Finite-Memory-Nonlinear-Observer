% 4. FINITE MEMORY STUBBORN OBSERVER
function [x_hat_next, Sigma_next, Delta_k] = observer_stubborn_finite_memory(x_hat_k, u_k, y_meas, Sigma_k, params)
    A = params.plant.A_d;
    B = params.plant.B_d;
    C = params.plant.C_d;
    L = params.observer.L_nom;
    Ts = params.sim.T_s;
    Theta = params.stubborn.Theta;
    % Output error (tilde_y_k)
    y_hat = C * x_hat_k;
    tilde_y = y_meas - y_hat;
    abs_y_err = norm(tilde_y, 2);
    % Saturation Treshold (Delta_k)
    % Delta_k = Theta * ||Sigma_k||_1
    Delta_k = Theta * sum(Sigma_k);
    % Error Saturation
    sat_tilde_y = zeros(size(tilde_y));
    for i = 1:length(tilde_y)
        val = tilde_y(i);
        if abs(val) > Delta_k
            sat_tilde_y(i) = sign(val) * Delta_k;
        else
            sat_tilde_y(i) = val;
        end
    end
    % Observer Update
    f_nl = nonlinear_term(x_hat_k, params);
    x_hat_next = A * x_hat_k + B * u_k + Ts * f_nl + L * sat_tilde_y;
    % Threshold Update
    tau = params.stubborn.tau;
    S = diag(ones(tau-1, 1), -1);
    G = zeros(tau, 1);
    G(1) = 1;
    Sigma_next = S * Sigma_k + G * abs_y_err;
end
