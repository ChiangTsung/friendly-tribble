tell application "Notes"
	tell account "iCloud"
		try
			set targetNote to note "Twitter日报"
			set currentBody to body of targetNote
			set newContent to "<div><br></div><div><b>## 2026-02-18 23:00</b></div><ul><li><b>AI芯片格局</b>: @iamai_eth 指出随着Blackwell交付和Rubin量产，越来越多的ASIC项目被取消。Nvidia的统治力在加强，定制芯片的生存空间被压缩。</li><li><b>Robotaxi事故</b>: @raines1220 爆料Austin发生了14起Robotaxi事故，配图有点触目惊心。这跟Tesla今天下线第一辆Cybercab形成了鲜明对比，自动驾驶的落地之路注定坎坷。</li><li><b>Bill Ackman加仓</b>: Pershing Square增持了64%的Amazon，并建仓Meta。大佬在拥抱大科技。</li><li><b>Google I/O定档</b>: Sundar Pichai宣布Google I/O将在5月19日举行。</li><li><b>人口崩溃</b>: Elon继续贩卖人口焦虑，称出生率崩盘速度快过任何计算机模型预测，相当于“统计学上的彗星撞地球”。</li></ul>"
			set body of targetNote to currentBody & newContent
		on error errMsg
			return "Error: " & errMsg
		end try
	end tell
end tell