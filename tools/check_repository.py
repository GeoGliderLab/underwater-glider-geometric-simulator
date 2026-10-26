"""Portable release checks: artifacts, local Markdown links and saved receipts."""
from pathlib import Path
import json
import re
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]

def main():
    required = [
        'README.md', 'LICENSE', 'AUTHORS.md', 'CONTRIBUTING.md',
        'setup_glider.m', 'run_glider_demo.m', 'docs/SOURCE_AUDIT.md',
        'docs/equations/main.tex', 'docs/equations/metrics.tex',
        'docs/equations/glider_equations.pdf', 'docs/equations/glider_latex_source.zip',
        'results/glider_preview.gif', 'results/glider_demo.mp4',
        'results/glider_preview.png', 'docs/equations/images/glider_preview.png',
        'results/simulation.png', 'results/actuation.png', 'results/diagnostics.png',
        'results/demo.mat', 'results/demo_summary.json', 'results/validation.json',
    ]
    failures = [f'Missing artifact: {p}' for p in required if not (ROOT/p).is_file()]
    paths = [ROOT/'README.md', ROOT/'CONTRIBUTING.md', *sorted((ROOT/'docs').glob('*.md')),
             ROOT/'docs/equations/README.md']
    paths = [p for p in paths if p.name != 'REVIEW_NOTES.md']
    links = 0
    for document in paths:
        for target in re.findall(r'\[[^\]]*\]\(([^)\s]+)\)', document.read_text(encoding='utf-8')):
            if target.startswith(('http:', 'https:', '#', 'mailto:')):
                continue
            links += 1
            if not (document.parent/target.split('#')[0]).exists():
                failures.append(f'Broken link in {document.relative_to(ROOT)}: {target}')
    for receipt in ['validation.json', 'demo_summary.json', 'latex_validation.json']:
        data = json.loads((ROOT/'results'/receipt).read_text(encoding='utf-8-sig'))
        if data.get('status') != 'PASS':
            failures.append(f'Nonpassing saved receipt: {receipt}')
    analysis = json.loads((ROOT/'results/code_analysis.json').read_text(encoding='utf-8-sig'))
    if analysis.get('issues'):
        failures.append('Saved MATLAB code analysis contains issues.')
    archive = ROOT/'docs/equations/glider_latex_source.zip'
    if archive.exists():
        with zipfile.ZipFile(archive) as z:
            if z.testzip() or not {'main.tex', 'metrics.tex', 'images/simulation.png'} <= set(z.namelist()):
                failures.append('Incomplete or corrupt LaTeX source archive.')
    print(json.dumps({'status': 'FAIL' if failures else 'PASS', 'required_artifacts': len(required),
                      'local_links_checked': links, 'failures': failures}, indent=2))
    return bool(failures)

if __name__ == '__main__':
    sys.exit(main())
