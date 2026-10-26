# Editable equation document

**Main source:** [main.tex](main.tex)

**Compiled document:** [glider_equations.pdf](glider_equations.pdf)

**One-file source download:** [glider_latex_source.zip](glider_latex_source.zip)

This directory is a self-contained LaTeX project: `main.tex`, generated `metrics.tex`, and every referenced figure in `images/`. Clone/download it, or upload the directory to Overleaf and select `main.tex`. The committed files compile without MATLAB or Python.

## Edit and compile

Edit `main.tex` to correct, extend or reorganize the derivation. Keep supporting files inside this folder, reference them relatively, and define new symbols when first used.

With `pdflatex`, from this directory:

```sh
pdflatex -interaction=nonstopmode -halt-on-error -jobname=glider_equations main.tex
pdflatex -interaction=nonstopmode -halt-on-error -jobname=glider_equations main.tex
pdflatex -interaction=nonstopmode -halt-on-error -jobname=glider_equations main.tex
```

Or, from the repository root:

```sh
python tools/build_document.py
```

The helper rejects fatal errors, unresolved citations/references, overfull boxes and rerun requirements. Inspect the rendered PDF too: compilation alone cannot establish correct equations or layout.

## Refresh numerical values

`metrics.tex` is generated from MATLAB JSON receipts. Rerun the experiment when changing reported values:

```matlab
setup_glider; addpath('tests');
validate_glider;
run_glider_demo;
```

Then run from the repository root:

```sh
python tools/prepare_document.py
python tools/build_document.py
```

Preparation updates `metrics.tex` and copies the four result figures into `images/`. Preserve provenance when modifying the model. Commit the LaTeX, supporting files and regenerated PDF together.
