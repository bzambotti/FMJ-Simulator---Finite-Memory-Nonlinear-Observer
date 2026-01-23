function K = nominal_gainK(params)
    % NOMINAL_GAINK
    % Theorem 3 - Zemouche & Boutayeb (2006).

    A = params.plant.A_d; 
    C= params.plant.C_d; 
    Ts = params.sim.T_s;
    gamma = 0.001*3.33;

    n = size(A, 1);
    p = size(C, 1);
    
    tol = 1e-6; 
    P = sdpvar(n, n, 'symmetric');
    Q = sdpvar(n, n, 'symmetric');
    Y = sdpvar(n, p, 'full'); 
    
    beta  = sdpvar(1, 1);
    alpha = sdpvar(1, 1); 
    
    
    eta = 1 + gamma^2;
    R_hat = A' * P - C' * Y'; 
    blk11 = -eta * P + beta * (gamma^2) * eye(n);
    blk22 = eta * P - Q - beta * eye(n);
    blk33 = Q - alpha * eye(n);
    blk44 = -P;
    
    LMI_Mat = [blk11,      eta*R_hat,  zeros(n),   R_hat;
               eta*R_hat', blk22,      zeros(n),   zeros(n);
               zeros(n),   zeros(n),   blk33,      zeros(n);
               R_hat',     zeros(n),   zeros(n),   blk44];

    Constraints = [LMI_Mat <= -tol * eye(4*n)];
    Constraints = [Constraints, P >= alpha * eye(n)]; 
    Constraints = [Constraints, Q >= tol * eye(n)];
    Constraints = [Constraints, alpha >= 1e-4];
    Constraints = [Constraints, beta >= 1e-4];
 
    options = sdpsettings('solver', 'mosek', 'verbose', 0); 
    
    sol = optimize(Constraints, trace(P), options);
    
    if sol.problem == 0
        P_val = value(P);
        Y_val = value(Y);
       
        K = P_val \ Y_val;
        
        fprintf('*** LMI FEASIBLE *** ');
        
    else
        K = zeros(n, p);
        fprintf('!!! LMI INFEASIBLE !!! (Error Code: %d)\n', sol.problem);
        disp(sol.info);
    end
end