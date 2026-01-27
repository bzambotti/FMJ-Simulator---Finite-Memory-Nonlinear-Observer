# Finite-Memory Stubborn Observer for Flexible Joint Manipulator

This project implements a simulation of a Flexible Joint Manipulator (FJM) to compare the performance of a Nominal Luenberger Observer against a Finite-Memory Stubborn Observer under measurement outliers.

## Project Structure

- `main.m`: The main entry point for the simulation. It configures the system, runs simulations, and generates plots.
- `config/`: Contains configuration files.
    - `get_FJM_config.m`: Defines system matrices, physical parameters, and simulation settings.
- `dynamics/`: Contains system dynamics models.
    - `simulate_FMJ.m`: Simulates the FJM state update.
    - `nonlinear_term.m`: Computes nonlinear terms (friction, gravity).
- `observers/`: Contains observer implementations.
    - `observer_FMJ.m`: Nominal Luenberger Observer.
    - `observer_stubborn_finite_memory.m`: Finite-Memory Stubborn Observer.
    - `nominal_gainK.m`: Computes the nominal observer gain (requires Control System Toolbox).
- `utils/`: Utility functions.
    - `disturbance_generator.m`: Generates measurement noise and outliers.
    - `plot_time_domain_comparison.m`: Plotting function for time-domain results.
    - `apply_custom_style.m`: Styling function for boxplots.
    - 'run_rmse_experiment.m' : RMSE calculation.

## Prerequisites

- MATLAB
- Control System Toolbox (for `dlqr` in `nominal_gainK.m`)
- Parallel Computing Toolbox (optional, for `parfor` in Monte Carlo analysis)

## How to Run

1.  Open MATLAB.
2.  Navigate to the `FMJ_Simulation` folder.
3.  Run `main.m`.

## Simulation Modes

Inside `main.m`, you can toggle the following flags to enable/disable specific analyses:

- `RUN_SINGLE_SIM`: Runs a standard time-domain simulation (Single run).
- `RUN_MONTE_CARLO`: Runs a statistical analysis using Monte Carlo simulations (Multiple runs).
- `RUN_TRANSIENT`: Runs a sensitivity analysis on the threshold parameter Theta.
