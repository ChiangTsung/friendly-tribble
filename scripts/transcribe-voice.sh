#!/bin/bash
# 智能语音转录脚本 - whisper.cpp Metal GPU 加速版
# 速度：~1.3秒（比 CPU 快 6 倍）

AUDIO_FILE="$1"
WHISPER_DIR="/Users/a1/.openclaw/workspace/whisper.cpp"

if [ -z "$AUDIO_FILE" ] || [ ! -f "$AUDIO_FILE" ]; then
    echo "ERROR: 文件不存在"
    exit 1
fi

# 转换为 wav 格式（whisper.cpp 需要）
WAV_FILE="/tmp/whisper_$$.wav"
ffmpeg -i "$AUDIO_FILE" -ar 16000 -ac 1 -c:a pcm_s16le "$WAV_FILE" -y 2>/dev/null

if [ ! -f "$WAV_FILE" ]; then
    echo "ERROR: 音频转换失败"
    exit 1
fi

# 使用 Metal GPU 加速转录
OUTPUT=$("$WHISPER_DIR/build/bin/whisper-cli" \
    -m "$WHISPER_DIR/models/ggml-base.bin" \
    -f "$WAV_FILE" \
    -l zh \
    --no-timestamps 2>/dev/null)

# 提取转录结果（最后一行非空行）
TEXT=$(echo "$OUTPUT" | grep -v '^$' | tail -1)

# 清理
rm -f "$WAV_FILE"

# 输出结果
if [ -n "$TEXT" ]; then
    echo "$TEXT"
else
    echo "ERROR: 转录失败"
    exit 1
fi
