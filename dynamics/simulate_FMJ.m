% 2.1 Simulation of the entire dynamics
function x_next = simulate_FMJ(x_k, u_k, params)
    A = params.plant.A_d;
    B = params.plant.B_d;
    Ts = params.sim.T_s;
    f_nl = nonlinear_term(x_k, params);
    x_next = A * x_k + B * u_k + Ts * f_nl ;
end
