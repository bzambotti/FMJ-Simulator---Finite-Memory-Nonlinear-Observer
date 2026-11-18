function [x_next, s_next, Delta] = observer_stubborn_scalar(x_curr, u, y_meas, s_curr, params)
%OBSERVER_STUBBORN_SCALAR Classical scalar stubborn observer (104), refs. [31], [32].
%
%   s+    = lambda s + (1 - lambda) |y_tilde|
%   Delta = Theta * s
%   The innovation is saturated in norm (radial saturation).

    x_pred  = params.plant.A_d * x_curr + params.plant.B_d * u;
    y_tilde = y_meas - params.plant.C_d * x_curr;

    % Scalar memory (first-order low-pass filter)
    lam    = params.scalar.lambda;
    s_next = lam * s_curr + (1 - lam) * norm(y_tilde);

    % Threshold and saturation
    Delta = params.scalar.Theta * s_curr;
    if norm(y_tilde) > Delta && Delta > 0
        y_tilde_sat = Delta * (y_tilde / norm(y_tilde));
    else
        y_tilde_sat = y_tilde;
    end

    x_next = x_pred + params.observer.L_nom * y_tilde_sat;
end
