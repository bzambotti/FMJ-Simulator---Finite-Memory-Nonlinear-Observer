function [x_hat_next, Sigma_next, Delta_k] = observer_stubborn_finite_memory(x_hat_k, u_k, y_meas, Sigma_k, params)
%OBSERVER_STUBBORN_FINITE_MEMORY Finite-memory stubborn observer (103).
%
%   x+     = A x + B u + Ts*phi(x) + L sat_Delta(y_tilde)
%   Sigma+ = S Sigma + G |y_tilde|
%   Delta  = Theta * |Sigma|_1
%
%   Sigma_k is the tau x 1 memory buffer; the saturation is componentwise.

    A     = params.plant.A_d;
    B     = params.plant.B_d;
    C     = params.plant.C_d;
    L     = params.observer.L_nom;
    Ts    = params.sim.T_s;
    Theta = params.stubborn.Theta;
    tau   = params.stubborn.tau;

    % Output error and dynamic saturation threshold
    y_tilde = y_meas - C * x_hat_k;
    Delta_k = Theta * sum(Sigma_k);
    y_sat   = max(min(y_tilde, Delta_k), -Delta_k);

    % Observer update
    x_hat_next = A * x_hat_k + B * u_k + Ts * nonlinear_term(x_hat_k, params) + L * y_sat;

    % Memory (shift register) update
    S = diag(ones(tau-1, 1), -1);
    G = [1; zeros(tau-1, 1)];
    Sigma_next = S * Sigma_k + G * norm(y_tilde, 2);
end
