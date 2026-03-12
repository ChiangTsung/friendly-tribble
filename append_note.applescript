tell application "Notes"
    set theNote to note "Twitter日报" of folder "Notes"
    set currentBody to body of theNote
    set appendText to "<div><br></div>=== 下午 Twitter 摘要（17:00）===<br>【推荐】<br>- @kayliatyyy: 2025年投资复盘（108%收益）。强调风险管理是独立项，thesis改变必须止损（如MSTR/HOOD）。预警2026年是“鱼尾行情”，AI股全是growth based，财报出问题下跌会很快。<br>- @elonmusk: 称赞 Grok 4.20 “基于事实（BASED）”，对比其他AI在敏感问题上的表现。<br>- @xicilion (响马): 警告 Opus 4.6 fast 价格大幅上涨至 30x。<br>- @taresky: 认为豆包对老年人的反诈/帮助贡献巨大。<br>- @Tsla99T: 指出宇树机器人的强力对手其实是字节跳动的 Seedance。<br><br>【关注】<br>- @openclaw: 发布 2026.2.17 更新：Sonnet 4.6 支持、1M 上下文、iOS 分享插件、子代理功能。<br>- @RayDalio: 以爵士乐比喻团队创意协作，强调在适当时机退后或领头的即兴能力。<br>- @Ariston_Macro: 引用易经艮卦谈“止”的智慧，强调笃实、厚重与适时收手。<br>- @kayliatyyy: 转发宏观快讯，伊朗将在两周内就核/外交差距提出详细建议。<br>- @AgustinLebron3: 幽默吐槽弱类型语言开发者的痛苦；认为模型谄媚（sycophancy）是目前最好的对齐工具（冷幽默）。"
    set body of theNote to currentBody & appendText
end tell