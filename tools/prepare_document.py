"""Copy verified figures and format metrics; no scientific values are hand-entered."""
from pathlib import Path
import json
import shutil

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / 'docs' / 'equations'
DOC.joinpath('images').mkdir(exist_ok=True)
for name in ('glider_preview', 'simulation', 'actuation', 'diagnostics'):
    shutil.copy2(ROOT / 'results' / (name + '.png'), DOC / 'images' / (name + '.png'))
v = json.loads((ROOT / 'results/validation.json').read_text())
d = json.loads((ROOT / 'results/demo_summary.json').read_text())
assert v['status'] == d['status'] == 'PASS'
values = {
    'JacError': v['jacobian_error'], 'MassError': v['mass_error'],
    'RneaError': v['rnea_error'], 'EnergyRateError': v['open_energy_rate_error'],
    'OrthError': d['orthogonality_error'], 'PositionError': d['position_refinement_m'],
    'RotationError': d['rotation_refinement_rad'], 'EnergyError': d['energy_residual_J'],
    'FineEnergyError': d['energy_residual_half_step_J'],
    'MomentumError': v['momentum_error'], 'FineMomentumError': v['momentum_error_half_step'],
    'ClosedEnergyError': v['energy_error'], 'FineClosedEnergyError': v['energy_error_half_step'],
}
lines = ['% Generated from verified MATLAB JSON receipts by tools/prepare_document.py.']
for name, value in values.items():
    mantissa, exponent = f'{value:.3e}'.split('e')
    lines.append('\\newcommand{\\' + name + r'}{\(' + mantissa + r'\times10^{' + str(int(exponent)) + r'}\)}')
for name, value in {
    'DepthMin': d['depth_range_m'][0], 'DepthMax': d['depth_range_m'][1],
    'HorizontalRange': d['horizontal_range_m'], 'TauOne': d['max_joint_efforts'][0],
    'TauTwo': d['max_joint_efforts'][1], 'TauThree': d['max_joint_efforts'][2],
}.items():
    lines.append('\\newcommand{\\' + name + '}{' + f'{value:.4g}' + '}')
(DOC / 'metrics.tex').write_text('\n'.join(lines) + '\n', encoding='utf-8')
print('Prepared four figures and', len(lines)-1, 'metrics from passing receipts.')
