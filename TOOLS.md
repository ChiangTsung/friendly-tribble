# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Deep Research 2.4

**Location**: `/Users/a1/.openclaw/workspace/skills/deep-research/`

**Usage**:
```bash
python3 scripts/research.py "研究主题"
```

**Output** (在 `output/` 目录):
- `report_<timestamp>_<topic>.html` - 可视化HTML报告

**⚠️ 重要**：完成后**必须发送文件给用户**！

### 流程
1. 发散扩展 → 3个方向（根据查询类型自动选择）
   - 行情/市场类：价格走势 + 影响因素 + 预测展望
   - 公司事件类：事件脉络 + 各方观点 + 投资影响
   - 技术类：技术原理 + 市场应用 + 竞争格局
   - 通用类：基础认知 + 最新动态 + 深度解读
2. 多维搜索 → Brave Search API + X推文
3. JUDGE评估 → 质量审查（≥70分通过）
4. 深度抓取 → agent-browser提取高质量来源
5. 交叉验证 → 标记矛盾/存疑
6. 智能分析 → 基于正文内容提取价格、观点、风险
7. HTML报告 → 可视化报告，文件名包含主题

### 报告结构
- 📋 执行摘要（研究方法论 + 主要发现）
- 📊 行情概况（价格动态 + 市场观点）
- 🔍 深度分析（按方向组织的核心洞察）
- ⚠️ 风险提示
- 💡 投资洞察
- 📚 参考来源

### 进度通知
- 每60秒自动发送状态消息
- 全程约10-15分钟
- 不怕慢，就怕结果质量差

### 关键特性
- **智能发散**：根据查询类型自动选择最合适的搜索方向
- **JUDGE怀疑精神**：识别软广/情绪/低质内容
- **自动重搜**：质量不达标换词重搜（最多3次）
- **内容分析**：基于抓取正文提取价格、趋势、风险
- **优先browser**：网页抓取用agent-browser，不用fetch
- **Brave搜索**：使用Brave Search API（需要配置API key）

---

## Memory / Retrieval (QMD) - 分层检索架构

**Priority**: HIGH - Always try `qmd` before using built-in `memory_search`.

**Collections**:
- `memory` - 每日摘要 (daily memory files, curated)
- `sessions` - 原始对话 (full conversation transcripts)

**分层检索规则 (Hierarchical Search)**:

### Layer 1: Memory Collection (每日摘要层)
```bash
qmd vsearch "your question here" -c memory
```
- **先搜这个** - 精选的每日复盘、决策记录、重要结论
- 速度快、质量高、人工 curated
- 如果找到相关内容 → 直接返回
- 如果没找到或不够详细 → 进入 Layer 2

### Layer 2: Sessions Collection (原始对话层)
```bash
qmd vsearch "your question here" -c sessions
```
- **后备搜索** - 完整的原始对话记录
- 包含所有细节、推理过程、临时讨论
- 当 memory 层缺失细节时使用

### Layer 3: Deep Retrieval (深度检索)
```bash
qmd query "your question here"
```
- 跨 collections 的深度检索（HyDE + Reranking）
- 当向量搜索返回结果质量不够时使用
- 更慢但更全面

### Layer 4: Exact Match (精确匹配)
```bash
qmd search "keyword"
```
- BM25 关键词搜索
- 找特定术语、代码、日期等精确匹配

### Layer 5: Fallback (最后手段)
```bash
memory_search "your question here"
```
- 仅当 QMD 完全失败或不可用时使用

**Read Context**:
```bash
qmd get "path/to/file:line_number"
```
*(Retrieve content around a specific line found in search results.)*

**Note**: Follow the hierarchy strictly. Don't skip layers. Start with memory, fall back to sessions only when needed.

---

## tmux / Codex 值班工具约定（本机）

### tmux
- 安装路径：`/opt/homebrew/bin/tmux`
- 版本：`tmux 3.6a`
- 新建会话：`tmux new -s <name>`
- 列会话：`tmux ls`
- 进入会话：`tmux attach -t <name>`
- 结束会话：`tmux kill-session -t <name>`

### Codex 启动前环境检查
- API key：`echo $OPENAI_API_KEY`（或对应 provider key）
- 代理：`echo $HTTPS_PROXY && echo $HTTP_PROXY`
- Git 身份：`git config user.name && git config user.email`
- 远端状态：`git remote -v`

### 任务下发模板（给 Codex）
- 任务描述要小而明确
- 验收标准要可执行（包含测试/命令）
- 要求：改完后本地测试 + git commit

---

Add whatever helps you do your job. This is your cheat sheet.
