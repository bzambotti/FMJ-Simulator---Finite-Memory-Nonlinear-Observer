function K = nominal_gainK(params)
%NOMINAL_GAINK Nominal observer gain from the LMI of Theorem 3 in
%   Zemouche & Boutayeb (2006). Requires YALMIP and MOSEK.
%   Returns zeros(n,p) and prints a message if the LMI is infeasible.

    A = params.plant.A_d;
    C = params.plant.C_d;
    gamma = 0.001 * 3.33;   % Lipschitz-type bound on the nonlinearity

    n = size(A, 1);
    p = size(C, 1);
    tol = 1e-6;

    P = sdpvar(n, n, 'symmetric');
    Q = sdpvar(n, n, 'symmetric');
    Y = sdpvar(n, p, 'full');
    beta  = sdpvar(1, 1);
    alpha = sdpvar(1, 1);

    eta   = 1 + gamma^2;
    R_hat = A' * P - C' * Y';
    blk11 = -eta * P + beta * (gamma^2) * eye(n);
    blk22 = eta * P - Q - beta * eye(n);
    blk33 = Q - alpha * eye(n);
    blk44 = -P;

    LMI_Mat = [blk11,      eta*R_hat,  zeros(n),   R_hat;
               eta*R_hat', blk22,      zeros(n),   zeros(n);
               zeros(n),   zeros(n),   blk33,      zeros(n);
               R_hat',     zeros(n),   zeros(n),   blk44];

    Constraints = [LMI_Mat <= -tol * eye(4*n), ...
                   P >= alpha * eye(n), ...
                   Q >= tol * eye(n), ...
                   alpha >= 1e-4, ...
                   beta >= 1e-4];

    options = sdpsettings('solver', 'mosek', 'verbose', 0);
    sol = optimize(Constraints, trace(P), options);

    if sol.problem == 0
        K = value(P) \ value(Y);
        fprintf('LMI feasible.\n');
    else
        K = zeros(n, p);
        fprintf('LMI infeasible (error code %d): %s\n', sol.problem, sol.info);
    end
end
