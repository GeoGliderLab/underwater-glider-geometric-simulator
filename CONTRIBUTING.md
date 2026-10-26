# Contributing

## Edit the equations

The complete English document is in `docs/equations/`. Edit `main.tex`, keep figures and supporting sources inside that directory, and rebuild the PDF. [The editing guide](docs/equations/README.md) explains the workflow. Include source and compiled output in a documentation change.

When an equation change affects simulated behavior, update its MATLAB implementation and run the relevant numerical checks. Preserve angular-first twists, moment-first wrenches, upward world z and constant exterior displaced volume. Declare any new closure or parameter assumption.

## Modify the simulator

Physical constants are in `+glider/parameters.m`; integration/reference settings are in `+glider/config.m`. Construct a new checked model after modifying parameters.

```matlab
setup_glider; addpath('tests');
validate_glider;
summary = run_glider_demo();
```

Update affected figures and receipts when behavior changes. Explain new parameter values and include a meaningful independent check for a new physical mechanism.

## Commits

Use concise messages describing the resulting change. Attribute joint work with a blank line and the trailer:

```text
Co-authored-by: Julio <julio.el.idolo@gmail.com>
```

Use coauthorship for actual contributions. Julio's own future commits should use his configured Git identity. Preserve third-party notices and keep private supplied inputs outside Git.
