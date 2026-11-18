function plot_time_domain_comparison(steps, data_left, data_right, p)
%PLOT_TIME_DOMAIN_COMPARISON 2x2 layout of Fig. 1 (states x3 and x4).
%   data_left / data_right are structs with fields x_true, x_hat, x_stub,
%   x_scal (left: T_dwell = 3, right: T_dwell = 1).

    tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

    % Left column
    nexttile(1); hold on; grid on; box on;
    plot_state(steps, data_left, 3, p);
    ylabel('$x_3$', 'Interpreter', 'latex', 'FontSize', 18);
    legend('True', 'Nominal', 'Scalar', 'Finite Memory', 'Location', 'northeast', ...
           'Interpreter', 'latex', 'FontSize', 12, 'NumColumns', 2);
    ylim([-8 8]);
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');

    nexttile(3); hold on; grid on; box on;
    plot_state(steps, data_left, 4, p);
    ylabel('$x_4$', 'Interpreter', 'latex', 'FontSize', 18);
    xlabel('$k$', 'Interpreter', 'latex', 'FontSize', 18);
    ylim([-15 15]);
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');

    % Right column
    nexttile(2); hold on; grid on; box on;
    plot_state(steps, data_right, 3, p);
    ylim([-8 8]);
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');

    nexttile(4); hold on; grid on; box on;
    plot_state(steps, data_right, 4, p);
    xlabel('$k$', 'Interpreter', 'latex', 'FontSize', 18);
    ylim([-15 15]);
    set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
end

function plot_state(steps, d, i, p)
    plot(steps, d.x_true(i,:), 'Color', p.style.c_true, 'LineWidth', p.style.lw_true);        % true
    plot(steps, d.x_hat(i,:),  ':',  'Color', p.style.c_nom,  'LineWidth', p.style.lw_nom);   % nominal (102)
    plot(steps, d.x_scal(i,:), '-.', 'Color', p.style.c_scal, 'LineWidth', p.style.lw_stub);  % scalar (104)
    plot(steps, d.x_stub(i,:), '--', 'Color', p.style.c_stub, 'LineWidth', p.style.lw_stub);  % finite memory (103)
end
