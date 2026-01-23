function plot_time_domain(steps, x_true, x_hat, x_stub, p)
    tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    % State x3
    nexttile;
    hold on; grid on; box on;
    plot(steps, x_true(3,:), 'Color', p.style.c_true, 'LineWidth', p.style.lw_true);
    plot(steps, x_stub(3,:), '--', 'Color', p.style.c_stub, 'LineWidth', p.style.lw_stub);
    plot(steps, x_hat(3,:), '--', 'Color', p.style.c_nom, 'LineWidth', p.style.lw_nom);
    ylabel('$x_3$', 'Interpreter','latex');
    legend('True', 'Stubborn', 'Nominal', 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 16);
    % State x4
    nexttile;
    hold on; grid on; box on;
    plot(steps, x_true(4,:), 'Color', p.style.c_true, 'LineWidth', p.style.lw_true);
    plot(steps, x_stub(4,:), '--', 'Color', p.style.c_stub, 'LineWidth', p.style.lw_stub);
    plot(steps, x_hat(4,:), '--', 'Color', p.style.c_nom, 'LineWidth', p.style.lw_nom);
    ylabel('$x_4$', 'Interpreter','latex');
    xlabel('$k$', 'Interpreter','latex');
    legend('True', 'Stubborn', 'Nominal', 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 16);
    set(groot, 'DefaultAxesFontSize', 20); % Dimensione font per assi
    set(groot, 'DefaultTextFontSize', 14); % Dimensione font per testo
    set(groot, 'DefaultAxesLineWidth', 0.8); % Spessore linee degli assi
end
