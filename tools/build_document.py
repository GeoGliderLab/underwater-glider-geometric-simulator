"""Build the self-contained English LaTeX project; Python stdlib + pdflatex."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / 'docs/equations'

def main():
    executable = shutil.which('pdflatex')
    if not executable:
        raise SystemExit('pdflatex is required; install a LaTeX distribution first.')
    for attempt in range(1, 4):
        result = subprocess.run([executable, '-interaction=nonstopmode', '-halt-on-error',
                                 '-jobname=glider_equations', 'main.tex'], cwd=DOC,
                                capture_output=True, text=True, encoding='utf-8', errors='replace')
        (DOC / f'compile-{attempt}.txt').write_text(result.stdout + result.stderr, encoding='utf-8')
        if result.returncode:
            raise SystemExit(f'LaTeX failed; inspect docs/equations/compile-{attempt}.txt')
    log_path = DOC / 'glider_equations.log'
    log = log_path.read_text(encoding='utf-8', errors='replace')
    problems = re.findall(r'^.*(?:Overfull|undefined|Rerun to get|LaTeX Error|Emergency stop).*$', log, re.M)
    pages = re.search(r'Output written on .*?\((\d+) pages?', log)
    if problems or not pages:
        raise SystemExit('LaTeX diagnostics require review:\n' + '\n'.join(problems))
    report = {
        'status': 'PASS', 'compiler_exit_code': 0, 'pages': int(pages.group(1)),
        'log_path': log_path.relative_to(ROOT).as_posix(),
        'log_sha256': hashlib.sha256(log_path.read_bytes()).hexdigest(),
        'source_sha256': hashlib.sha256((DOC / 'main.tex').read_bytes()).hexdigest(),
        'undefined_reference_or_citation_count': 0, 'overfull_hbox_count': 0,
        'underfull_hbox_count': len(re.findall('Underfull', log)), 'rerun_warning_count': 0,
    }
    (ROOT / 'results/latex_validation.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
    archive = DOC / 'glider_latex_source.zip'
    with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED) as target:
        for source in [DOC/'main.tex', DOC/'metrics.tex', DOC/'README.md', *sorted((DOC/'images').glob('*.png'))]:
            target.write(source, source.relative_to(DOC).as_posix())
    print(json.dumps({'status': 'PASS', 'pages': report['pages'],
                      'pdf': 'docs/equations/glider_equations.pdf',
                      'editable_archive': 'docs/equations/glider_latex_source.zip'}, indent=2))

if __name__ == '__main__':
    main()
