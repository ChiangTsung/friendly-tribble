#!/usr/bin/env python3
import json
import time
import traceback
from pathlib import Path

def log_error(e):
    with open("error.log", "a", encoding="utf-8") as f:
        f.write(f"\n{'='*50}\n")
        f.write(f"时间: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"错误: {str(e)}\n")
        f.write(traceback.format_exc())

def main():
    try:
        print("🚀 导入 playwright...")
        from playwright.sync_api import sync_playwright
        
        print("🚀 启动浏览器...")
        with sync_playwright() as p:
            browser = p.chromium.launch_persistent_context(
                user_data_dir="./chrome_profile",
                headless=False,
                slow_mo=100  # 慢一点，更稳定
            )
            page = browser.new_page()
            
            url = input("🔗 粘贴 AI Studio 聊天 URL: ").strip()
            if not url:
                print("❌ 没有输入 URL")
                browser.close()
                return
            
            print(f"⏳ 正在打开页面...")
            print(f"   URL: {url[:60]}...")
            
            # 先去 Google 首页确保网络正常
            page.goto("https://google.com", timeout=60000)
            print("   ✓ Google 连接正常")
            
            # 再去 AI Studio
            print(f"   正在加载 AI Studio...")
            try:
                page.goto(url, timeout=60000)
                # 不等 networkidle，等 5 秒让页面基本渲染
                time.sleep(5)
                print("   ✓ 页面加载完成")
            except Exception as e:
                print(f"   ⚠️  加载超时，但继续尝试...")
                time.sleep(3)
            
            print("\n" + "="*50)
            print("📋 接下来请手动操作：")
            print("   1. 在浏览器里登录 Google（如果需要）")
            print("   2. 确保聊天内容都显示出来了")
            print("   3. 滚动到聊天最顶部，加载所有历史")
            print("="*50)
            
            input("\n✅ 准备好后，按回车键开始提取...")
            
            print("🔍 正在提取聊天内容...")
            
            # 获取页面文本内容（更简单可靠的方法）
            print("   方法1: 提取可见文本...")
            full_text = page.evaluate('''() => {
                // 尝试找到聊天容器
                const containers = [
                    document.querySelector('[role="main"]'),
                    document.querySelector('main'),
                    document.body
                ];
                for (const container of containers) {
                    if (container) return container.innerText;
                }
                return document.body.innerText;
            }''')
            
            # 按换行分割，过滤出有意义的内容
            lines = [line.strip() for line in full_text.split('\n') if line.strip()]
            
            # 尝试区分用户和 AI（根据内容特征）
            chat_data = []
            for i, line in enumerate(lines):
                if len(line) > 10 and len(line) < 2000:
                    # 简单启发：短句+问号可能是用户
                    is_user = len(line) < 200 or '?' in line or '吗' in line or '你' in line[:20]
                    chat_data.append({
                        "index": i,
                        "role": "user" if is_user else "assistant",
                        "content": line[:800]
                    })
            
            print(f"   ✓ 提取到 {len(chat_data)} 条内容")
            
            # 保存
            timestamp = time.strftime("%Y%m%d_%H%M")
            output = Path(f"chat_{timestamp}.json")
            
            result = {
                "url": url,
                "export_time": time.strftime("%Y-%m-%d %H:%M:%S"),
                "total_lines": len(lines),
                "filtered_messages": len(chat_data),
                "messages": chat_data[:100]  # 先存前100条，避免文件太大
            }
            
            with open(output, 'w', encoding='utf-8') as f:
                json.dump(result, f, ensure_ascii=False, indent=2)
            
            print(f"\n✅ 导出成功！")
            print(f"📁 文件: {output.absolute()}")
            print(f"📊 共 {len(chat_data)} 条消息（已保存前100条）")
            
            browser.close()
            input("\n按回车键退出...")
            
    except Exception as e:
        log_error(e)
        print(f"\n❌ 出错了: {e}")
        print("   详细错误已保存到 error.log")
        input("\n按回车键退出...")

if __name__ == "__main__":
    print("="*60)
    print("Google AI Studio 导出工具 - v2")
    print("="*60)
    print()
    main()
