#!/usr/bin/env python3
"""
Google AI Studio 聊天记录导出脚本 (macOS调试版)
出错时会记录到 error.log
"""

import json
import time
import traceback
from pathlib import Path

def log_error(e):
    """记录错误到文件"""
    with open("error.log", "a", encoding="utf-8") as f:
        f.write(f"\n{'='*50}\n")
        f.write(f"时间: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"错误: {str(e)}\n")
        f.write(traceback.format_exc())
        f.write(f"\n{'='*50}\n")
    print(f"❌ 出错了！错误已保存到 error.log")
    print(f"   请把 error.log 文件发给我看看")

def main():
    try:
        print("🚀 正在导入 playwright...")
        from playwright.sync_api import sync_playwright
        
        print("🚀 启动浏览器...")
        
        with sync_playwright() as p:
            print("   正在启动 Chromium...")
            browser = p.chromium.launch_persistent_context(
                user_data_dir="./chrome_profile",
                headless=False,
                args=['--disable-blink-features=AutomationControlled']
            )
            
            page = browser.new_page()
            
            print("\n📋 操作步骤：")
            print("1. 浏览器打开后，登录 Google AI Studio")
            print("2. 打开你想导出的聊天")
            print("3. 复制地址栏的 URL")
            print()
            
            url = input("🔗 粘贴聊天 URL: ").strip()
            
            if not url:
                print("❌ 没有输入 URL，退出")
                browser.close()
                return
            
            print(f"\n⏳ 正在打开: {url[:60]}...")
            page.goto(url)
            
            print("   等待页面加载...")
            page.wait_for_load_state('networkidle')
            time.sleep(3)
            
            print("\n⚠️  请在浏览器中：")
            print("   1. 滚动到聊天最顶部（确保历史消息都加载）")
            print("   2. 如果有 '加载更多' 按钮，多点几次")
            print()
            input("✅ 加载完成后，按回车键开始导出...")
            
            print("🔍 正在提取聊天内容...")
            
            # 尝试多种可能的选择器
            selectors = [
                '[role="list"] > div',
                '[role="listitem"]',
                '.conversation-message',
                '[data-message-author]',
                'div[role="main"] > div > div'
            ]
            
            messages = []
            used_selector = None
            
            for selector in selectors:
                try:
                    msgs = page.query_selector_all(selector)
                    if len(msgs) > 5:  # 如果找到足够多的元素
                        messages = msgs
                        used_selector = selector
                        print(f"   ✓ 使用选择器: {selector}")
                        break
                except:
                    continue
            
            if not messages:
                print("⚠️  自动检测失败，尝试通用方法...")
                # 获取页面所有文本块
                messages = page.query_selector_all('div > div')
            
            print(f"   找到 {len(messages)} 个消息块")
            
            chat_data = []
            for i, msg in enumerate(messages):
                try:
                    text = msg.inner_text().strip()
                    # 过滤太短或太长的
                    if text and 10 < len(text) < 2000:
                        # 简单启发：包含"你"或问号的可能是用户
                        is_user = any(kw in text[:50] for kw in ['你', '我', '?', '吗'])
                        chat_data.append({
                            "index": i,
                            "role": "user" if is_user else "assistant",
                            "content": text[:800]  # 限制长度
                        })
                except Exception as e:
                    continue
            
            print(f"   成功提取 {len(chat_data)} 条有效消息")
            
            # 保存
            timestamp = time.strftime("%Y%m%d_%H%M")
            output_file = Path(f"ai_studio_chat_{timestamp}.json")
            
            result = {
                "url": url,
                "export_time": time.strftime("%Y-%m-%d %H:%M:%S"),
                "used_selector": used_selector,
                "total_messages": len(chat_data),
                "messages": chat_data
            }
            
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(result, f, ensure_ascii=False, indent=2)
            
            print(f"\n✅ 导出成功！")
            print(f"📁 文件: {output_file.absolute()}")
            print(f"📊 共 {len(chat_data)} 条消息")
            
            browser.close()
            
            # 等待用户看清
            input("\n按回车键退出...")
            
    except Exception as e:
        log_error(e)
        input("\n按回车键退出...")

if __name__ == "__main__":
    print("="*60)
    print("Google AI Studio 导出工具 - 调试版")
    print("="*60)
    print()
    main()
