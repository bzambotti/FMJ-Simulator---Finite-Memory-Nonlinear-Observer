% 5. DISTURBANCES
function disturbance_hist = disturbance_generator(f_bar, dist_interval, Tsim, nd)
    sigma_outlier = sqrt(0.5 * f_bar^2);
    disturbance_hist = zeros(nd, Tsim+1);
    for ch = 1:nd
        % 1. RANDOM START
        first_outlier_idx = randi([1, dist_interval]);
        outlier_indices = first_outlier_idx:dist_interval:(Tsim+1);
        % 2. RANDOM AMPLITUDE:
        num_outliers = length(outlier_indices);
        random_values = sigma_outlier * randn(1, num_outliers);
        disturbance_hist(ch, outlier_indices) = random_values;
    end
end
