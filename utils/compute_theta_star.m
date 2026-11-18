function [Theta_star, c_gamma] = compute_theta_star(params)
%COMPUTE_THETA_STAR Closed-form lower bound Theta*_lin of eq. (41), Remark 7,
%   for a generic memory horizon tau. It uses only the linear part of the
%   dynamics (l_f = ||A||), so it is an indicative, conservative value.

    A   = params.plant.A_d;
    C   = params.plant.C_d;
    L   = params.observer.L_nom;
    tau = params.stubborn.tau;
    n = size(A, 1);
    m = size(C, 1);

    % Lipschitz constants
    l_h  = norm(C);
    l_f  = norm(A);
    l_gy = norm(L);

    % Linear observability modulus from O_tau = [C; CA; ...; CA^(tau-1)]
    O_tau = zeros(m*tau, n);
    for i = 0:tau-1
        O_tau(i*m+1:(i+1)*m, :) = C * A^i;
    end
    c_gamma = min(svd(O_tau));

    % Constants of Lemma 2: kappa_0 = l_gy, kappa_j = l_gy * max(1, l_f^(j-1))
    kappa     = @(j) l_gy * max(1, l_f^(j-1));
    kappa_bar = l_gy + sum(arrayfun(kappa, 1:tau-1));
    b_tau     = 1 / (1 + l_h * kappa_bar);

    Theta_star = (l_h * l_f^tau) / (c_gamma * b_tau) + l_h * kappa(tau);
end
