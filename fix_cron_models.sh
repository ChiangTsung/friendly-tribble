#!/bin/bash
# 修复所有受影响的 cron 任务：将 kimi-coding/k2p5 替换为 claude-opus-4-6-thinking
# 路径：~/.openclaw/cron/jobs.json

CRON_FILE="$HOME/.openclaw/cron/jobs.json"

if [ ! -f "$CRON_FILE" ]; then
    echo "错误：找不到 cron 配置文件"
    exit 1
fi

# 备份
cp "$CRON_FILE" "${CRON_FILE}.bak.$(date +%s)"

# 替换模型
sed -i '' 's/kimi-coding\/k2p5/claude-opus-4-6-thinking/g' "$CRON_FILE"

echo "✅ 已修复以下任务："
echo "- B站视频监控（5个UID）"
echo "- Twitter晨报/晚报"
echo "- Daily Memory整理"
echo "- QMD索引更新"
echo ""
echo "所有任务已切换至 claude-opus-4-6-thinking"
