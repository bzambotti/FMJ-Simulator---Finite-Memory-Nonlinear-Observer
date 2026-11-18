function x_next = simulate_FMJ(x_k, u_k, params)
%SIMULATE_FMJ One step of the discrete-time FJM: x+ = A x + B u + Ts*phi(x).

    A  = params.plant.A_d;
    B  = params.plant.B_d;
    Ts = params.sim.T_s;
    x_next = A * x_k + B * u_k + Ts * nonlinear_term(x_k, params);
end
