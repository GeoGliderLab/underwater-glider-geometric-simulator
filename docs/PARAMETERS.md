# Parameters and modeling decisions

Edit `+glider/parameters.m`, then construct a new model with `m=glider.model(p)`. Model constants remain fixed during an integration.

| Group | Source | Status |
| --- | --- | --- |
| Density 1000 kg/m3; gravity 9.8 m/s2 | Supplied code | Retained; not necessarily seawater conditions |
| Diameter .2142 m; length .300 m | Supplied code | Nominal dimensions; cylindrical visual hull |
| Dry masses 10.780, .50003, .50003, .150 kg | Supplied code | Retained |
| Effective volume .012096 m3 | Supplied `m_buoy/rho` | Different from nominal cylinder; measure complete displacement and CB |
| Central inertias of bodies 2, 3 and piston | Supplied diagonals | Retained and physically admissible |
| Dry hull COM [0;0;-.0225] m | Supplied gravity offset | Used consistently in inertia and gravity |
| Central hull inertia | Equivalent solid cylinder | Provisional replacement of inadmissible source tensor |
| R axis z; P axis local x; piston axis -z | Supplied code | Retained |
| Mount and chamber placement | Proposed | Enclosed demonstration layout; replace with CAD |
| Syringe radius .0325 m; stroke .1 m | Supplied code | Retained; old PDF uses another convention |
| Added-fluid inertia | Proposed diagonal | Unidentified |
| Drag 30.1376; lift 121.54; lateral 9.042 | Scales inspired by source code | New law; not identified coefficients for that law |
| Induced drag 15; linear angular damping | Proposed | Unidentified |
| Quadratic angular damping [1.7;10.347;.43] | Scales inspired by code | Different law and corresponding units; provisional |
| Wing span .44 m; chord .1 m; yz plane | Proposed visual geometry | No identified section or manufacturer CAD |
| Effective port at fixed chamber end | Proposed | Still inflow/comoving outflow; no directed jet |
| Constant rear pressure 101325 Pa | Proposed | Replace by chamber law or measurement; sealed gas pressure is generally variable |

`water.enabled=false` removes stored-water contributions. `pump.enabled=false` independently removes piston pressure/friction loading. `hydro.enabled=false` removes dissipative/lift forces; `added_mass` is independent. Unforced tests use zero gravity and explicitly selected hydrodynamic settings.

The water closure requires a piston axis of -z, identity chamber orientation, limits `[0,stroke]`, and `home4=tip+stroke*ez`. The constructor rejects inconsistencies. An inclined syringe requires coordinated changes to `water` and `pump_load`.

The proposed layout leaves 9.1 mm radial clearance for the visual mass sphere at maximum travel. This is an envelope check, not full collision detection. The nominal cylinder volume is about .0108106 m3, while effective displacement is .012096 m3; they are independently declared quantities.

Prototype calibration requires measured axes and masses, COM inertias, center of buoyancy, displacement, hydrodynamic coefficients, pressure/flow curves, rear pressure, losses, actuator limits and efficiency.
