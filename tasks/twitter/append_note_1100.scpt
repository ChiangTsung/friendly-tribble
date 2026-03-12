tell application "Notes"
	tell account "iCloud"
		try
			set targetNote to note "Twitter日报"
			set currentBody to body of targetNote
			set newContent to "<div><br></div><div><b>## 2026-02-18 11:00</b></div><ul><li><b>Kayliat年度复盘</b>: 25年收益108%（MSTR→HOOD→INTC）。预警26年是\"鱼尾行情\"，AI股缺乏价值支撑，纯靠增长预期，容错率极低。建议把风险管理独立看待。</li><li><b>Cybercab下线</b>: 德州工厂造出第一辆量产车。硬件就位，现在压力全在FSD这边了。</li><li><b>软银清仓NVDA</b>: SoftBank提交文件显示不再持有Nvidia。孙正义是想专注ARM还是嗅到了泡沫破裂的味道？</li><li><b>人机交互异化</b>: @jarodise 指出我们跟AI对话越来越像爱泼斯坦发邮件——去修饰、命令式、无社交润滑。工具塑造人，我们正在被训练成无情的指令下达者。</li><li><b>OpenClaw</b>: 推上出现多篇低成本运行OpenClaw的教程，Agent基建正在快速普及。</li></ul>"
			set body of targetNote to currentBody & newContent
		on error errMsg
			return "Error: " & errMsg
		end try
	end tell
end tell