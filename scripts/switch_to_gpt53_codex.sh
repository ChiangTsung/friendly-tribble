#!/usr/bin/env bash
# 用途: 将 OpenClaw cron(agentTurn) 与默认模型切换为 openai-codex/gpt-5.3-codex
# 用法: scripts/switch_to_gpt53_codex.sh

set -euo pipefail

TARGET_MODEL="openai-codex/gpt-5.3-codex"
CRON_JOBS_JSON="${HOME}/.openclaw/cron/jobs.json"
OPENCLAW_JSON="${HOME}/.openclaw/openclaw.json"

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: 未找到 python3（请先安装或加入 PATH）" >&2
  exit 127
fi

python3 - "${TARGET_MODEL}" "${CRON_JOBS_JSON}" "${OPENCLAW_JSON}" <<'PY'
import datetime
import json
import os
import shutil
import sys
import tempfile

TARGET_MODEL = sys.argv[1]
CRON_JOBS_JSON = sys.argv[2]
OPENCLAW_JSON = sys.argv[3]

TS = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")


def backup_path(path: str) -> str:
    return f"{path}.bak.{TS}"


def read_json(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def write_json_atomic(path: str, data) -> None:
    directory = os.path.dirname(path) or "."
    with tempfile.NamedTemporaryFile(
        "w",
        encoding="utf-8",
        dir=directory,
        delete=False,
        prefix=os.path.basename(path) + ".tmp.",
    ) as tf:
        tmp_path = tf.name
        json.dump(data, tf, ensure_ascii=False, indent=2)
        tf.write("\n")
    os.replace(tmp_path, path)


def update_agent_turn_models(node):
    changed = 0
    matched = 0
    if isinstance(node, dict):
        payload = node.get("payload")
        if isinstance(payload, dict) and payload.get("kind") == "agentTurn":
            matched += 1
            if payload.get("model") != TARGET_MODEL:
                payload["model"] = TARGET_MODEL
                changed += 1
        for v in node.values():
            c, m = update_agent_turn_models(v)
            changed += c
            matched += m
    elif isinstance(node, list):
        for item in node:
            c, m = update_agent_turn_models(item)
            changed += c
            matched += m
    return changed, matched


cron_changed = 0
cron_matched = 0
default_model_status = "未处理"

if not os.path.exists(CRON_JOBS_JSON):
    print(f"ERROR: 未找到 cron 配置文件：{CRON_JOBS_JSON}", file=sys.stderr)
    sys.exit(2)

try:
    cron_data = read_json(CRON_JOBS_JSON)
except Exception as e:
    print(f"ERROR: 读取/解析失败：{CRON_JOBS_JSON}（{e}）", file=sys.stderr)
    sys.exit(3)

cron_changed, cron_matched = update_agent_turn_models(cron_data)
if cron_changed > 0:
    bp = backup_path(CRON_JOBS_JSON)
    shutil.copy2(CRON_JOBS_JSON, bp)
    try:
        write_json_atomic(CRON_JOBS_JSON, cron_data)
    except Exception as e:
        print(f"ERROR: 写入失败：{CRON_JOBS_JSON}（{e}）", file=sys.stderr)
        sys.exit(4)
    print(f"[cron] 命中 agentTurn: {cron_matched} 个；已修改: {cron_changed} 个（备份：{bp}）")
else:
    print(f"[cron] 命中 agentTurn: {cron_matched} 个；已修改: 0 个")


def update_openclaw_default_model(path: str) -> str:
    if not os.path.exists(path):
        return f"文件不存在，已跳过（{path}）"
    try:
        data = read_json(path)
    except Exception as e:
        return f"读取/解析失败，已跳过（{path}；{e}）"

    keys = ["agents", "defaults", "model", "primary"]
    cur = data
    for k in keys[:-1]:
        if not isinstance(cur, dict) or k not in cur:
            return "路径 agents.defaults.model.primary 不存在，已跳过"
        cur = cur[k]
    last = keys[-1]
    if not isinstance(cur, dict) or last not in cur:
        return "路径 agents.defaults.model.primary 不存在，已跳过"

    old = cur.get(last)
    if old == TARGET_MODEL:
        return "无需修改（已是目标模型）"

    bp = backup_path(path)
    shutil.copy2(path, bp)
    cur[last] = TARGET_MODEL
    try:
        write_json_atomic(path, data)
    except Exception as e:
        return f"写入失败（{path}；{e}）"
    return f"已修改（备份：{bp}）"


default_model_status = update_openclaw_default_model(OPENCLAW_JSON)

print("统计:")
print(f"- cron job 修改数量: {cron_changed}")
print(f"- 默认模型修改状态: {default_model_status}")
PY

