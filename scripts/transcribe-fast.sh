#!/bin/bash
# 智能语音转录脚本 - Metal GPU + turbo 模型（最准确）
AUDIO_FILE="$1"
WHISPER_DIR="/Users/a1/.openclaw/workspace/whisper.cpp"

if [ -z "$AUDIO_FILE" ] || [ ! -f "$AUDIO_FILE" ]; then
    echo "ERROR: 文件不存在"
    exit 1
fi

WAV_FILE="/tmp/whisper_$$.wav"
ffmpeg -i "$AUDIO_FILE" -ar 16000 -ac 1 -c:a pcm_s16le "$WAV_FILE" -y 2>/dev/null

if [ ! -f "$WAV_FILE" ]; then
    echo "ERROR: 音频转换失败"
    exit 1
fi

# 使用 turbo 模型（1.5GB，最准确）
OUTPUT=$("$WHISPER_DIR/build/bin/whisper-cli" \
    -m "$WHISPER_DIR/models/ggml-large-v3-turbo.bin" \
    -f "$WAV_FILE" \
    -l zh \
    --no-timestamps 2>/dev/null)

TEXT=$(echo "$OUTPUT" | grep -v '^$' | tail -1)
rm -f "$WAV_FILE"

if [ -n "$TEXT" ]; then
    echo "$TEXT"
else
    echo "ERROR: 转录失败"
    exit 1
fi
