# Full harness 配置(让 ChatGPT Web 访问本地工具)

> 默认安装是 **Browser-only**:ChatGPT Web 能做对话 / web 搜索,但**看不到本地工作区与工具**。
> 本篇配置后,`chatgpt-web` 模型的 Instant–Extra High 档位可通过 `Codex Native2` MCP 连接器访问本地 Codex harness 的文件与工具。

---

## 前提

- 已完成基础安装:登录内嵌浏览器 → 跑通 smoke test → Install into Codex 并重启。
- 你将用到的 OpenAI 账户 = 登录 ChatGPT Web 的同一个账户。

---

## 步骤

### 1. 获取 Tunnel ID 和 API key
在**同一个 OpenAI 账户**上创建(免费,不消耗模型额度):

- **Tunnel ID**:`https://platform.openai.com/settings/organization/tunnels` → 新建 tunnel,复制 `tunnel_...` ID。
- **API key**:`https://platform.openai.com/settings/organization/api-keys` → 新建普通 key(需 Tunnels 的 Read + Use 权限)。

### 2. 在启动器连接 harness
把上一步的:
- `Tunnel ID` → 第一个输入框
- `API key` → 第二个输入框

点 **Connect harness**。

### 3. 在 ChatGPT Web 新建连接器
1. ChatGPT 设置里开启 **Developer Mode**。
2. 进入 Connectors(`https://chatgpt.com/#settings/Connectors`)。
3. 新建 **Tunnel** 类型连接器:
   - **名称必须精确为 `Codex Native2`**(不要叫 `Codex Native`,也不要复用旧的);
   - 选择你刚创建的 tunnel;
   - **Authentication 设为 None**;
   - **Permissions 选 Allow all actions**(选 “Allow low-risk actions” 会在到达 Codex harness 前拦截命令/补丁)。

### 4. 验证
回启动器点 **Verify runtime**。它会精确选择 `Codex Native2`;若只发现旧的 `Codex Native`,会显式失败并提示迁移,而不会接受旧连接器。

---

## 重要提醒

- **不要**动旧的 `Codex Native` 连接器(别重命名、别刷新)。按本篇新建独立的 `Codex Native2`。
- 外层 Codex harness 仍强制执行其沙箱与审批策略。
- 启动器 GUI 必须保持运行(tunnel 客户端随启动器常驻),否则连接器不可用。

---

## 验证失败的常见原因

| 报错 | 原因 / 解法 |
|------|------|
| `no row named "Codex Native2"` | 连接器还没建。先完成步骤 3 再验证 |
| 名称不匹配 | 必须精确 `Codex Native2`(大小写/空格/数字 2) |
| 命令被拦截 | Permissions 改为 Allow all actions |
| 验证时 bridge 不可达 | 确认启动器 GUI 在运行、`127.0.0.1:17841` 可达 |
