#!/usr/bin/env bash
set -euo pipefail
TS=$(date +%Y%m%d_%H%M%S)
python3 - <<'PY'
import json, os, shutil, tempfile
from pathlib import Path

TS = os.popen('date +%Y%m%d_%H%M%S').read().strip()
home = Path.home()
cron_path = home / '.openclaw/cron/jobs.json'
cfg_path = home / '.openclaw/openclaw.json'

with cron_path.open('r', encoding='utf-8') as f:
    cron = json.load(f)
with cfg_path.open('r', encoding='utf-8') as f:
    cfg = json.load(f)

jobs = cron.get('jobs', []) if isinstance(cron, dict) else cron
updated = 0
for j in jobs:
    if isinstance(j, dict) and j.get('sessionTarget') == 'isolated':
        p = j.get('payload')
        if isinstance(p, dict) and p.get('kind') == 'agentTurn':
            if p.get('model') != 'kimi-coding/k2p5':
                p['model'] = 'kimi-coding/k2p5'
                updated += 1

if updated:
    bp = str(cron_path) + f'.bak.{TS}'
    shutil.copy2(cron_path, bp)
    with tempfile.NamedTemporaryFile('w', encoding='utf-8', dir=str(cron_path.parent), delete=False) as tf:
        json.dump(cron, tf, ensure_ascii=False, indent=2)
        tf.write('\n')
        tmp = tf.name
    os.replace(tmp, cron_path)

default_updated = 'no'
provider_written = 'no'

agents = cfg.setdefault('agents', {})
defaults = agents.setdefault('defaults', {})
model = defaults.setdefault('model', {})
if model.get('primary') != 'kimi-coding/k2p5':
    model['primary'] = 'kimi-coding/k2p5'
    default_updated = 'yes'

models = cfg.setdefault('models', {})
providers = models.setdefault('providers', {})
existing = providers.get('kimi-coding') if isinstance(providers.get('kimi-coding'), dict) else {}
newp = dict(existing)
newp['baseUrl'] = 'https://api.moonshot.ai/v1'
newp['api'] = 'openai-completions'
newp['models'] = [{
    'id': 'k2p5',
    'name': 'Kimi K2.5',
    'reasoning': False,
    'input': ['text', 'image'],
    'contextWindow': 256000,
    'maxTokens': 8192
}]
if existing != newp:
    providers['kimi-coding'] = newp
    provider_written = 'yes'

if default_updated == 'yes' or provider_written == 'yes':
    bp = str(cfg_path) + f'.bak.{TS}'
    shutil.copy2(cfg_path, bp)
    with tempfile.NamedTemporaryFile('w', encoding='utf-8', dir=str(cfg_path.parent), delete=False) as tf:
        json.dump(cfg, tf, ensure_ascii=False, indent=2)
        tf.write('\n')
        tmp = tf.name
    os.replace(tmp, cfg_path)

print(f'isolated_subtasks_updated={updated}')
print(f'default_model_updated={default_updated}')
print(f'kimi_provider_override_written={provider_written}')
PY
