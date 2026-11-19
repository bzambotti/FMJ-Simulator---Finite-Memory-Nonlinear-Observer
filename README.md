# FMJ Simulator: Finite-Memory Stubborn Observer

MATLAB code for the simulation section (flexible joint manipulator example) of the paper:

B. Zambotti, V. Andrieu, D. Astolfi, L. Bako, M. Nadri, L. Zaccarian, *Exact Outlier Cancellation in Discrete-Time Observers via Stubborn Redesign*. Preprint: https://hal.science/hal-05509568

The code compares the nominal observer (102), the proposed finite-memory stubborn observer (103) and the classical scalar stubborn observer (104) on a single-link flexible joint manipulator with friction, under sporadic measurement outliers.

## Requirements

- MATLAB R2020a or newer (uses `tiledlayout` and `exportgraphics`)
- [YALMIP](https://yalmip.github.io/) (LMI for the nominal observer gain)
- [MOSEK](https://www.mosek.com/) with a valid license (SDP solver called by YALMIP). The license file is personal and is not part of this repository.
- Statistics and Machine Learning Toolbox (`boxplot`, `signrank`, used only for Fig. 4)

YALMIP and MOSEK must be on the MATLAB path.

## How to run

```matlab
cd FMJ-Simulator---Finite-Memory-Nonlinear-Observer
main
```

`main.m` adds the subfolders to the path, fixes the random seed (`rng(1, 'twister')`), computes the nominal gain with YALMIP/MOSEK, checks that `A - L*C` is Schur, prints the bound Theta*_lin of eq. (41) and saves all figures as PDF in `figures/`.

Fig. 4 uses 10^4 Monte Carlo runs per scenario, as in the paper, and is the slowest part. To skip it set `RUN_MONTE_CARLO = false`, or lower `N_RUNS` for a quick test, at the top of `main.m`. The figures are generated in a fixed order after a single seed, so run them through `main.m` to obtain the same outlier realizations every time.

## Which script produces which figure

| Paper figure | Content | Script | Output |
|---|---|---|---|
| Fig. 1 | State estimates x3, x4: nominal vs finite-memory vs scalar stubborn observer. Left: T_dwell = 3, non-zero initial conditions. Right: T_dwell = 1, zero initial conditions | `scripts/fig1_trajectories.m` | `figures/fig1_trajectories.pdf` |
| Fig. 2 | Outlier rejection on y2 (T_dwell = 3, zero initial conditions): saturation band and measured output | `scripts/fig2_measurements.m` | `figures/fig2_measurements.pdf` |
| Fig. 3 | Transient of the estimation error norm for several values of Theta (noise-free) | `scripts/fig3_theta_transient.m` | `figures/fig3_theta_transient.pdf` |
| Fig. 4 | Monte Carlo RMSE boxplots, T_dwell = 3 and T_dwell = 1 | `scripts/fig4_montecarlo_rmse.m` | `figures/fig4_montecarlo_rmse.pdf` |

## Repository structure

```
main.m                    regenerates all figures
config/
  get_FJM_config.m        plant matrices, friction, sampling time, tuning (tau = 3, Theta = 0.02), plot style
dynamics/
  simulate_FMJ.m          discrete-time FJM step  x+ = A x + B u + Ts*phi(x)
  nonlinear_term.m        phi(x): motor friction (Stribeck + Coulomb) and gravity
observers/
  nominal_gainK.m         nominal gain L from the LMI of Zemouche & Boutayeb (2006), YALMIP + MOSEK
  observer_FMJ.m          nominal observer (102)
  observer_stubborn_finite_memory.m   finite-memory stubborn observer (103)
  observer_stubborn_scalar.m          scalar stubborn observer (104)
utils/
  disturbance_generator.m sporadic outliers with dwell time (Definition 1)
  run_rmse_experiment.m   one Monte Carlo run (Fig. 4)
  compute_theta_star.m    closed-form bound Theta*_lin, eq. (41)
  plot_time_domain_comparison.m, apply_custom_style.m, export_figure.m   plotting helpers
scripts/
  fig1_trajectories.m, fig2_measurements.m, fig3_theta_transient.m, fig4_montecarlo_rmse.m
figures/                  output folder (generated PDFs are not tracked)
```

## Citation

```bibtex
@unpublished{zambottii_2026_exact,
  TITLE = {{Exact Outlier Cancellation in Discrete-Time Observers via Stubborn Redesign}},
  AUTHOR = {Zambotti, Beatrice and Andrieu, Vincent and Astolfi, Daniele and Bako, Laurent and Nadri, Madiha and Zaccarian, Luca},
  URL = {https://hal.science/hal-05509568},
  NOTE = {working paper or preprint},
  HAL_LOCAL_REFERENCE = {Rapport LAAS n{\textdegree} 26033},
  YEAR = {2026},
  MONTH = Nov,
  PDF = {https://hal.science/hal-05509568v2/file/TAC2026_Stubborn_observer_for_discrete_time_nonlinear_systems.pdf},
  HAL_ID = {hal-05509568},
  HAL_VERSION = {v2},
}
```
