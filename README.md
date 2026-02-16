# Finite-Memory Stubborn Observer for Flexible Joint Manipulator

This repository implements the simulations presented in the manuscript:

Zambotti, B., et al. "Finite-Memory Stubborn Observer for Flexible Joint Manipulator," submitted to IEEE Transactions on Automatic Control, February 2026.Preprint available on HAL: https://hal.science/hal-05509568

We simulate a Flexible Joint Manipulator (FJM) to compare the performance of a Nominal Luenberger Observer against a Finite-Memory Stubborn Observer under measurement outliers.

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
    - `run_rmse_experiment.m` : RMSE calculation.

## Prerequisites

- MATLAB
- Control System Toolbox (for `dlqr` in `nominal_gainK.m`)

## How to Run

1.  Open MATLAB.
2.  Navigate to the `FMJ_Simulation` folder.
3.  Run `main.m`.

## Simulation Modes

Inside `main.m`, you can toggle the following flags to enable/disable specific analyses:

- `RUN_SINGLE_SIM`: Runs a standard time-domain simulation (Single run).
- `RUN_MONTE_CARLO`: Runs a statistical analysis using Monte Carlo simulations (Multiple runs).
- `RUN_TRANSIENT`: Runs a sensitivity analysis on the threshold parameter Theta.


## Citation

If you use this code, please cite:

```bibtex
@unpublished{zambotti:hal-05509568,
  TITLE = {Exact Outlier Cancellation in Discrete-Time Observers via Stubborn Redesign},
  AUTHOR = {Zambotti, Beatrice and Andrieu, Vincent and Astolfi, Daniele and Bako, Laurent and Nadri, Madiha and Zaccarian, Luca},
  URL = {https://hal.science/hal-05509568},
  NOTE = {working paper or preprint},
  YEAR = {2026},
  MONTH = Feb,
  PDF = {https://hal.science/hal-05509568v1/file/TAC26.pdf},
  HAL_ID = {hal-05509568},
  HAL_VERSION = {v1},
}
