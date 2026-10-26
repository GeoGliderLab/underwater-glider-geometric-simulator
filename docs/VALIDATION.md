# Numerical verification

Recorded environment: MATLAB R2026a Update 4, 25 random states, seed 42. Full results are in `results/validation.json` and `results/demo_summary.json`. Reproduce them with `validate_glider` and `run_glider_demo`.

| Check | Evidence |
| --- | --- |
| SE(3) exponential | Comparison with `expm`, including small angles |
| Tree Jacobians | Global-pose differences without the Jacobian recursion |
| Mass matrix | Assembly from independently differentiated Jacobians |
| Solid-body bias | Euler-Poincare/Lagrange with numerical inertia derivatives |
| Gravity and buoyancy | Potential derivatives under SE(3) and joint variations |
| RNEA | Backward recursion against `M*a+b-Q`, including pressure and flux |
| Water | Empty/full fill, inertia derivative, neutral ballast and flux signs |
| Hydrodynamics | Nonpositive power; lift perpendicular to velocity |
| Open-system energy | Directional derivative of E against four power channels |
| Momentum | Fixed ballast, no exterior forces, moving internal joints |
| Integration | Step refinement and rotation preservation in SO(3) |
| Modes | Prescribed and effort-driven trajectories; hybrid/forward round trip |
| Rejected inputs | Invalid step, nonrigid initial pose, out-of-range reference, impossible inertia |

The 80-second demo uses 0.02 s and 0.01 s steps. Position disagreement is approximately 1.31e-5 m and orientation disagreement 9.02e-5 rad. Rotation orthogonality error stays near 1.22e-14. The integrated energy residual falls from about 4.48e-4 to 1.08e-4 J.

In the isolated fixed-ballast momentum test, halving the step reduces the mixed-unit momentum indicator from about 1.184e-6 to 2.962e-7. The energy error falls from 7.678e-9 to 1.920e-9 J. This supports second-order convergence for those tests, not exact finite-step conservation or a universal physical bound.

The benchmark measures warmed serial dynamics evaluations with changing states. Timing is machine dependent. No speedup against a different simulator is claimed without equivalent measurement.

These checks establish internal numerical consistency of the chosen model. They do not experimentally validate geometry, hull/wing coefficients, displacement, flow, motors or prototype trajectories. An energy identity cannot by itself validate the interior-flow closure.

## Continuous checks

The repository workflow checks source hashes, documentation links and required artifacts, and compiles the LaTeX. MATLAB verification was executed locally on the recorded installation; hosted workflow success is not presented as a hosted MATLAB run.
