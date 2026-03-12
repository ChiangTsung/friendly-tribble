#!/bin/bash
# 智能语音转录脚本 - 返回转录结果和置信度
# 用法: transcribe-voice-smart.sh <音频文件路径>

AUDIO_FILE="$1"

if [ -z "$AUDIO_FILE" ] || [ ! -f "$AUDIO_FILE" ]; then
    echo "ERROR: 文件不存在"
    exit 1
fi

# 使用 base 模型转录，同时输出详细结果
OUTPUT=$(whisper "$AUDIO_FILE" --model base --language zh --output_format json --output_dir /tmp 2>/dev/null)

# 获取 JSON 文件路径
JSON_FILE="/tmp/$(basename "$AUDIO_FILE" .ogg).json"
TXT_FILE="/tmp/$(basename "$AUDIO_FILE" .ogg).txt"

if [ -f "$JSON_FILE" ]; then
    # 提取文本
    TEXT=$(cat "$JSON_FILE" | python3 -c "import json,sys; print(json.load(sys.stdin)['text'].strip())" 2>/dev/null)
    
    # 提取平均置信度（如果有的话）
    AVG_CONF=$(cat "$JSON_FILE" | python3 -c "
import json,sys
try:
    data = json.load(sys.stdin)
    segments = data.get('segments', [])
    if segments:
        avg = sum(s.get('avg_logprob', -1) for s in segments) / len(segments)
        print(f'{avg:.2f}')
    else:
        print('0')
except:
    print('0')
" 2>/dev/null)
    
    # 清理临时文件
    rm -f "$JSON_FILE" "$TXT_FILE"
    
    # 输出格式：文本|置信度
    echo "$TEXT|$AVG_CONF"
else
    echo "ERROR: 转录失败|0"
fi
