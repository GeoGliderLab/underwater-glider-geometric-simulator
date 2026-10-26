# Third-party notices and source boundaries

## Modern Robotics

`third_party/modern_robotics/` preserves MATLAB operators from the local Franka-Panda-Geometric-Simulator copy, originally from [NxRLab/ModernRobotics](https://github.com/NxRLab/ModernRobotics). Its MIT license and original comments remain included. Hashes are recorded in `sources/manifest.json`.

## Glider implementation

The glider package and branched RNEA were written for this project. Organization and shared-kinematics ideas draw on Johnny's Panda/Kinova simulators. Their robot models, CAD, controllers and fixed-base serial dynamics are not bundled as the glider model.

New code and documentation use the root MIT `LICENSE`. The external library retains its separate notice. No MATLAB distribution or commercial toolbox is included.

## Supplied inputs and literature

Julio's supplied MATLAB program and the earlier equation PDF are private working inputs without an established redistribution license. Their local copies are excluded from Git; hashes and parameter decisions remain traceable. Papers are linked and cited, rather than redistributed. The root license does not relicense those source documents.
