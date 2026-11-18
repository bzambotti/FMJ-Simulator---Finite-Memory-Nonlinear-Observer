function d = disturbance_generator(f_bar, dwell_time, N, nd)
%DISTURBANCE_GENERATOR Sporadic outliers with dwell time (Definition 1).
%   d = DISTURBANCE_GENERATOR(f_bar, dwell_time, N, nd) returns an
%   nd x (N+1) matrix. Outliers occur at the same instants on all nd
%   channels, with k_{i+1} - k_i = dwell_time + 1 and a random first
%   instant; amplitudes are independent N(0, 0.5*f_bar^2) on each channel.

    sigma_outlier = sqrt(0.5 * f_bar^2);
    d = zeros(nd, N+1);
    interval = dwell_time + 1;

    % Outlier instants (common to all channels)
    first_idx = randi([1, interval]);
    idx = first_idx:interval:(N+1);

    % Amplitudes (independent for each channel)
    for ch = 1:nd
        d(ch, idx) = sigma_outlier * randn(1, numel(idx));
    end
end
