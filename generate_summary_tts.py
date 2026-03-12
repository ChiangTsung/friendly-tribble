import requests
import json

url = "https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation"
headers = {
    "Authorization": "Bearer sk-8ccbdf1b59e6411aa0844da9c16760e6",
    "Content-Type": "application/json"
}
data = {
    "model": "qwen3-tts-flash",
    "input": {
        "text": "老大，今天咱们聊的内容可硬核了！早上我汇报了经济学顶刊和推特晨报的运行情况。下午到晚上，咱们主要围绕AI商业模式做了一场深度推演。从Agent的Skill层为什么是新的护城河，聊到哪类公司最有机会占据生态位，还探讨了四种Skill的定价模式。后来你提到你在做银行财富管理的AI项目，咱们交流了怎么构建系统壁垒，我也帮你设好了明天的讨论提醒。最后就是现在，咱们成功把语音链路跑通啦！"
    }
}
response = requests.post(url, headers=headers, json=data)
res_json = response.json()
audio_url = res_json.get("output", {}).get("audio", {}).get("url")

if audio_url:
    audio_res = requests.get(audio_url)
    with open("/Users/a1/.openclaw/media/inbound/summary.wav", "wb") as f:
        f.write(audio_res.content)
    print("SUCCESS")
else:
    print("FAILED", response.text)
