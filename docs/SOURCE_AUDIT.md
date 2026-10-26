# Audit of the supplied model

Date: 2026-10-26. The original MATLAB program and 15-page equation PDF were inspected as technical sources. Local byte-preserved copies are in `sources/private/`, excluded from Git. Their hashes are in `sources/manifest.json`.

## Observations and decisions

| Input location | Observed issue | Implemented treatment |
| --- | --- | --- |
| PDF p. 1 | Says base pose does not use an exponential while writing `Hdot=H*hat(V)` | Distinguish the differential equation from exponential step updates |
| PDF pp. 2, 8; code lines 306-309, 346 | Small `ad(S*dq)` blocks are off-diagonal before multiplying A | Diagonal D in the stacked expression; local bias-acceleration recursion |
| PDF p. 9 | Revolute column in body-3 row uses untransformed S2 | Use `X3*S2` |
| PDF p. 10 | Gravity direction changes between definitions; buoyancy sign is inconsistent | One gravity vector `[0;0;-g]`; upward buoyancy on the force side |
| PDF p. 11 | Moves frame 4 to the water center while asserting unchanged Jacobian | Frame 4 stays with the dry piston; water is a separate base-frame distribution |
| PDF p. 12; code lines 17, 49-50, 266-267 | PDF has 58 mm diameter and `h=.1-2*theta4`; code has 65 mm and `h=.1-theta4` | Use the code's .1 m stroke convention consistently |
| PDF p. 13 | `IEm+mEm*Ad'*Ad` is not a spatial-inertia congruence | Use complete `X'*I*X` transformation and COM formula |
| PDF pp. 11, 14-15 | Inertia derivative has opposite signs and is later absent; Idot is subtracted from ad(V) | Positive `Idot*V` on inertial side; momentum flux kept separately |
| Code lines 275-276 | Stored water is a point mass associated with piston twist | Distributed cylinder with explicitly stated negligible-relative-momentum closure |
| Code lines 349-351 | All gravity terms are projected through J1 | Project each solid through its own Ji; give piston a separate hydraulic load |
| Code lines 95, 102-109, 37 | Gravity/inertial masses and COM offsets disagree; axial inertia violates triangle inequality | One mass/COM; provisional admissible cylinder inertia |
| Code lines 56, 69, 47-48 | Original radial motion can reach .13 m in a .1071 m-radius hull | Center the pivot; .04 m initial radial guide and .04 m travel |
| Code lines 84, 49-50 | Piston reaches nominal hull end | Fixed chamber end at -.140 m, piston at -.040-theta4 |
| Code lines 133-143, 835-891 | Hydrodynamic angles depend on branches; no identification data supplied | Lift perpendicular to velocity, dissipative drag, provisional coefficients |
| Code lines 398-428 | Logged post-step pose/velocity coexist with earlier-stage reactions/configuration | Record a consistent evaluation stage |

`sources/audit_numbers.json` calculates the source mass discrepancy, COM implied by the inertia, triangle violation, cylinder volume and radial envelopes. The source inertia's positive matrix eigenvalues alone do not establish physical realizability.

## Open water model

Adding `Idot*V` to closed-system RNEA is not a universal correction for pumping. A model must specify the control volume, port transport velocities and relative interior-fluid momentum. This implementation neglects that relative momentum and retains explicit flux. Its energy check establishes consistency of the closure, not its experimental validity for rapid flow.

## Local reuse and literature

The Panda/Kinova package organization and shared-kinematics approach informed this project. Small Modern Robotics operators are reused with their MIT license. The four-body floating tree and its backward recursion were implemented for the glider; fixed-base serial dynamics were not used as an unchanged glider kernel.

The English equation note cites the official Modern Robotics spatial-dynamics material, Fossen's marine model, and Leonard/Graver glider literature. No vehicle parameters were silently imported from those publications. Original papers are linked rather than bundled.
