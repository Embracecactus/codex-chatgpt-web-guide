# ChatGPT Web 当 Codex 用 · 全平台小白指南

> 用 [codex-chatgpt-web](https://github.com/miuuyy/codex-chatgpt-web) 把 **ChatGPT Web**(免费 / Plus / Pro)当成 **Codex** 的原生模型来用,支持 Windows / Linux / WSL2。

[![WSL2](https://img.shields.io/badge/verified-WSL2-brightgreen)](https://github.com/Embracecactus/codex-chatgpt-web-guide)
[![Linux](https://img.shields.io/badge/status-Linux%20unverified-yellow)](https://github.com/Embracecactus/codex-chatgpt-web-guide)
[![Windows](https://img.shields.io/badge/status-Windows%20unverified-yellow)](https://github.com/Embracecactus/codex-chatgpt-web-guide)

---

## ⚠️ 验证状态(请先读)

| 平台 | 状态 | 说明 |
|------|------|------|
| **WSL2** (Linux on Windows) | ✅ 已实测跑通 | 本指南的“最难子集”,所有坑已解决,启动参数见 `codex-web-gpt.sh` |
| **原生 Linux** | ⚠️ 待验证 | 基于官方文档 + 平台差异推导,多数情况“装上即用”,FUSE/代理差异见下文 |
| **原生 Windows** | ⚠️ 待验证 | 使用官方 `.exe` 安装包,系统代理自动生效,基本无需命令行参数 |

> 本仓库作者只在 **WSL2** 环境端到端验证过。Windows / Linux 章节来自项目官方 README 与已知平台差异推导,**未在本机实测**。如果你在这两个平台跑通或遇到问题,欢迎提 Issue / PR 校正,让小白少踩坑。

---

## 这是什么

`codex-chatgpt-web` 是一个非官方桥接项目:

- 启动一个本地 GUI 启动器,内嵌浏览器登录 ChatGPT Web;
- 启动本地 bridge(默认 `http://127.0.0.1:17841/v1`);
- 改写 Codex 的配置,把 API 请求指向这个 bridge;
- 于是你能在 Codex CLI 里选用 `chatgpt-web/...` 系列模型,用 ChatGPT Web 的额度当 Codex 后端。

两种模式:

| 模式 | 能力 | 配置复杂度 |
|------|------|-----------|
| **Browser-only**(默认) | 对话、web 搜索等 ChatGPT 原生能力;**看不到本地工作区/工具** | 低 |
| **Full harness** | 通过 `Codex Native2` MCP 连接器,让模型访问本地文件与工具 | 中(需 OpenAI tunnel) |

---

## 一、前置要求

| 平台 | 需要 |
|------|------|
| 所有平台 | 一个 ChatGPT 账号(Web 版,免费/Luna/Plus/Pro 均可);已安装 `codex` CLI |
| WSL2 | 一个 X Server(如 VcXsrv / GWSL),`DISPLAY` 已设好;若走代理,记下代理地址(如 `http://127.0.0.1:7897`) |
| Linux | 桌面环境(X11/Wayland);如需代理记下代理地址 |
| Windows | Windows 10/11;系统已设置代理(如有) |

> 安装 `codex` CLI(任选其一):见 [OpenAI Codex 文档](https://github.com/openai/codex)。验证:`codex --version`。

---

## 二、安装

### Windows
1. 到 [codex-chatgpt-web Releases](https://github.com/miuuyy/codex-chatgpt-web/releases) 下载 `Codex Web GPT-*.exe`。
2. 双击安装,按向导完成。
3. 从开始菜单启动 **Codex Web GPT**。

> ⚠️ 待验证:Windows 下 Chromium 会读取系统代理设置,通常无需额外参数。

### Linux(原生,非 WSL)
1. 下载 `Codex Web GPT-*.AppImage`。
2. 加执行权限并运行:
   ```bash
   chmod +x "Codex Web GPT.AppImage"
   ./Codex\ Web\ GPT.AppImage
   ```
3. 若你处在代理后,加上 `--proxy-server`(见排错表):
   ```bash
   ./Codex\ Web\ GPT.AppImage --proxy-server="http://你的代理:端口"
   ```

> ⚠️ 待验证:原生 Linux 有 FUSE,AppImage 可直接挂载运行,不需要 extract 模式。

### WSL2 ✅ 实测
WSL2 **没有 FUSE**,AppImage 不能以挂载模式运行,必须 extract 模式;且 X 合成/代理/zygote 都有坑。直接用我们调好的启动器:

```bash
# 1) 把本仓库的 codex-web-gpt.sh 放到 ~/.local/bin/ 并加可执行权限
cp codex-web-gpt.sh ~/.local/bin/codex-web-gpt
chmod +x ~/.local/bin/codex-web-gpt

# 2) 编辑脚本里 APPIMAGE 路径 / 代理地址为你自己的
# 3) 启动
codex-web-gpt
```

脚本内容见 [`codex-web-gpt.sh`](./codex-web-gpt.sh),关键参数都有注释。

---

## 三、登录与冒烟测试

1. 启动器打开后,在**内嵌浏览器**里登录 ChatGPT(Sign in)。
   ![登录 ChatGPT](images/01-login.png)
2. 登录完成后,点 **Run browser smoke test**。
   - 它会在临时对话里发一条小消息,验证能收到完整流式回复。
   - ✅ 看到 “Smoke test passed” 即可。
   ![冒烟测试通过](images/02-smoke-passed.png)
3. 若冒烟报错 `ENOENT`(找不到 `/tmp/appimage_extracted_.../codex-web-gpt-launcher`):见排错表“ENOENT”。

---

## 四、安装进 Codex

1. 点 **Install into Codex**(把 ChatGPT Web 模型加进 Codex,不替换原生模型目录)。
   ![Install into Codex](images/03-install-into-codex.png)
2. 点 **Restart Codex once to refresh the model picker**(重启 Codex 刷新模型选择器)。
   - 该步骤会改写 `~/.codex/config.toml`,把 `openai_base_url` 指向 `http://127.0.0.1:17841/v1`。
   - 以后想卸载,用 `codex-chatgpt-web uninstall` 可恢复原配置。

> ⚠️ **启动器 GUI 必须一直运行**,否则 17841 端口不可达,ChatGPT Web 模型失效。

---

## 五、使用模型

在 Codex 里切换模型:
- 交互界面输入 `/model` 回车,在列表里选 `chatgpt-web/...` 系列;
  ![模型选择器](images/04-model-picker.png)
- 或重启时指定:`codex -m "chatgpt-web/pro"`。

模型名格式为 `chatgpt-web/<档位> <强度>`:
- 档位(低→高):`instant < light < standard < plus < pro`
- 强度:`low < medium < high`

> 注意:`~/.codex/config.toml` 里的 `model_reasoning_effort` 是给**原生 Codex 模型**用的;对 `chatgpt-web/*`,强度已写进模型名,改这个配置无效——换带不同强度后缀的模型 id 即可。

---

## 六、Full harness(可选,让模型访问本地工具)

默认是 Browser-only(看不到本地文件/工具)。要开本地工具访问:

1. 启动器里打开 **MCP** 页面。
2. 在**将使用连接器的同一个 OpenAI 账户**上创建 Tunnel + 普通 API key:
   - Tunnel:`https://platform.openai.com/settings/organization/tunnels`
   - API key:`https://platform.openai.com/settings/organization/api-keys`
3. 把 **Tunnel ID** 和 **API key** 贴回启动器,点 **Connect harness**。
4. 在 ChatGPT Web 里(Developer Mode 下)新建一个 **Tunnel** 类型连接器:
   - 名称**必须精确为 `Codex Native2`**;
   - 选择你创建的 tunnel;
   - Authentication 设为 **None**;
   - Permissions 选 **Allow all actions**(选 “Allow low-risk actions” 会导致本地读写被安全检查拦截,见 `docs/full-harness.md` 常见坑 ①)。
   ![Codex Native2 连接器](images/05-codex-native2-connector.png)
5. 回启动器点 **Verify runtime**。

详细步骤见 [`docs/full-harness.md`](./docs/full-harness.md)。

---

## 截图清单(贡献者请补充)

本指南的截图占位在 `images/`,欢迎提交真实截图(小白友好度直接拉满):

| 文件 | 应截内容 |
|------|----------|
| `images/01-login.png` | 启动器内嵌浏览器登录 ChatGPT 的页面 |
| `images/02-smoke-passed.png` | 冒烟测试显示 “Smoke test passed” |
| `images/03-install-into-codex.png` | 点 “Install into Codex” 的按钮/完成状态 |
| `images/04-model-picker.png` | Codex 里 `/model` 选择器列出 `chatgpt-web/*` |
| `images/05-codex-native2-connector.png` | ChatGPT 里建好的 `Codex Native2` 连接器 |

> 截图建议:窗口全貌即可,可打码敏感信息(账号、token)。

## 排错

所有 WSL2 实测坑与解法见 [**troubleshooting.md**](./troubleshooting.md)。

---

## 贡献

本指南欢迎 PR / Issue。特别是 **Windows 与 Linux** 平台的实测反馈——把你的步骤和截图补上,就能把 ⚠️ 变成 ✅,帮到更多小白。

## 免责声明

`codex-chatgpt-web` 是非官方项目,使用风险自负。本指南仅记录配置方法,不担保可用性,也不隶属于 OpenAI 或该项目作者。
