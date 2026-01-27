function plot_time_domain_comparison(steps, data_dt5, data_dt2, p)
    % data_dt5 e data_dt2 are struct containing
    % x_true, x_hat, x_stub
   
    t = tiledlayout(2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    
    % --- COLUMN 1: Dwell Time = 5 ---
    % State x3 (DT=5)
    nexttile; hold on; grid on; box on;
    plot_state(steps, data_dt5.x_true(3,:), data_dt5.x_stub(3,:), data_dt5.x_hat(3,:), p);
    ylabel('$x_3$', 'Interpreter','latex',  'FontSize', 20);
    legend('True', 'Stubborn', 'Nominal', 'Location', 'southwest', 'Interpreter', 'latex', 'FontSize', 16);
    ylim([-8 8]);

    % State x4 (DT=5)
    nexttile(3); hold on; grid on; box on;
    plot_state(steps, data_dt5.x_true(4,:), data_dt5.x_stub(4,:), data_dt5.x_hat(4,:), p);
    ylabel('$x_4$', 'Interpreter','latex',  'FontSize', 20);
    legend('True', 'Stubborn', 'Nominal', 'Location', 'southwest', 'Interpreter', 'latex', 'FontSize', 16);
    xlabel('$k$', 'Interpreter','latex',  'FontSize', 20);
    ylim([-15 15]);

    % --- COLUMN 2: Dwell Time = 2 ---
    % State x3 (DT=2)
    nexttile(2); hold on; grid on; box on;
    plot_state(steps, data_dt2.x_true(3,:), data_dt2.x_stub(3,:), data_dt2.x_hat(3,:), p);
    legend('True', 'Stubborn', 'Nominal', 'Location', 'southwest', 'Interpreter', 'latex', 'FontSize', 16);
    ylim([-8 8]);

    % State x4 (DT=2)
    nexttile(4); hold on; grid on; box on;
    plot_state(steps, data_dt2.x_true(4,:), data_dt2.x_stub(4,:), data_dt2.x_hat(4,:), p);
    xlabel('$k$', 'Interpreter','latex', 'FontSize', 20);
    legend('True', 'Stubborn', 'Nominal', 'Location', 'southwest', 'Interpreter', 'latex', 'FontSize', 16);
    ylim([-15 15]);

end

function plot_state(steps, x_t, x_s, x_h, p)
    plot(steps, x_t, 'Color', p.style.c_true, 'LineWidth', p.style.lw_true);
    plot(steps, x_s, '--', 'Color', p.style.c_stub, 'LineWidth', p.style.lw_stub);
    plot(steps, x_h, '--', 'Color', p.style.c_nom, 'LineWidth', p.style.lw_nom);
end