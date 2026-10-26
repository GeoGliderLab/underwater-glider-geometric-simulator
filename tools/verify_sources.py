"""Verify source hashes without network access; stdlib only."""
from pathlib import Path
import hashlib
import json
import sys

root = Path(__file__).resolve().parents[1]
manifest = json.loads((root / 'sources/manifest.json').read_text(encoding='utf-8'))
failures, private_missing, verified = [], [], 0
for entry in manifest['files']:
    path = root / entry['path']
    if not path.exists():
        (private_missing if entry.get('private') else failures).append(entry['path'])
        continue
    actual = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual != entry['sha256']:
        failures.append(entry['path'])
    else:
        verified += 1
print(json.dumps({'status': 'FAIL' if failures else 'PASS', 'verified': verified,
                  'private_not_distributed': private_missing, 'failures': failures}, indent=2))
sys.exit(bool(failures))
