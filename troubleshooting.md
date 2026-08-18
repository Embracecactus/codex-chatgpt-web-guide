# 排错表(Troubleshooting)

> 本章 WSL2 内容均为**实测**。Windows / Linux 的对应现象待社区验证。

## WSL2 实测坑与解法

| 现象 | 根因 | 解法 |
|------|------|------|
| AppImage 直接跑报 “FUSE” / 无法挂载 | WSL2 **没有 FUSE** | 设 `APPIMAGE_EXTRACT_AND_RUN=1`(解压后就地运行),见 `codex-web-gpt.sh` |
| 窗口弹不出,日志 `GPU process isn't usable (error_code=1002)` FATAL | WSL2 下 GPU 进程起不来 | 加 `--disable-gpu-compositing`,并用 SwiftShader 提供软件 WebGL |
| 弹出一个**黑框**(全黑) | GPU/X11 合成层把画面合成成黑帧 | `--disable-gpu-compositing`(UI 走 CPU 合成)+ `--use-gl=angle --use-angle=swiftshader --enable-unsafe-swiftshader` |
| 登录后点 human 验证就黑 | 验证控件需要 WebGL,而 `--disable-gpu` 把 WebGL 也禁了 | 不要 `--disable-gpu`;改用 SwiftShader 软件 WebGL(同上参数) |
| `Zygote cannot be disabled if sandbox is enabled` | `--no-zygote` 必须配 `--no-sandbox` | 两个一起加:`--no-zygote --no-sandbox` |
| 直连 OpenAI 失败,日志 `handshake failed; net_error -100` | Chromium **不继承** `http_proxy`/`https_proxy` 环境变量 | 显式传 `--proxy-server="http://127.0.0.1:7897"`(换成你的代理),并加 `--proxy-bypass-list="127.0.0.1;localhost"` |
| 冒烟测试报错 `ENOENT ... /tmp/appimage_extracted_.../codex-web-gpt-launcher` | AppImage 把启动器解压到 `/tmp`,若该目录被清理,smoke 找不到它 | 保持启动器进程常驻(别 `kill -9` 后清 `/tmp`);重新启动会复用/重建该目录。确保 `CODEX_WEB_GPT_APPIMAGE` 指向正确路径 |
| 启动报 “SingletonLock” / 新实例起不来 | 上次 `kill -9` 残留锁文件 | 删 `~/.config/Codex Web GPT/` 下的 `SingletonLock`/`SingletonCookie`/`SingletonSocket` 后重试 |
| 选了 `chatgpt-web/...` 模型但无响应 | 启动器 GUI 被关掉,bridge(17841)掉了 | 启动器 GUI **必须一直运行**;确认 `127.0.0.1:17841` 可达 |

## 快速自检命令(WSL2)

```bash
# 1) 启动器主进程在不在
pgrep -fa "Codex Web GPT.AppImage"

# 2) bridge 端口通不通(应显示 REACHABLE)
timeout 3 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/17841' && echo REACHABLE || echo DOWN

# 3) 代理端口通不通(应显示 REACHABLE)
timeout 3 bash -c 'cat < /dev/null > /dev/tcp/127.0.0.1/7897' && echo REACHABLE || echo DOWN

# 4) 窗口是否在 X 上(xlsclients 应列出 codex-web-gpt-launcher)
DISPLAY=:0 xlsclients
```

## Full harness 专属

| 现象 | 解法 |
|------|------|
| Verify runtime 报 “no row named Codex Native2” | 你还没在 ChatGPT 里建连接器。先按 `docs/full-harness.md` 建一个名为 **`Codex Native2`** 的 Tunnel 连接器,再验证 |
| 连接器建了仍失败 | 名称必须**精确** `Codex Native2`(大小写、空格、数字 2);Auth=None;Permissions=Allow all actions |
| 命令/补丁被拦截 | Permissions 别选 “Allow low-risk actions”,选 “Allow all actions” |
| 旧的 `Codex Native` 连接器 | 不要重命名/刷新它,新建独立的 `Codex Native2` |

## Full harness 会话内报错(实测)

| 现象 | 根因 | 解法 |
|------|------|------|
| 模型说 "Browser-only mode",无法访问本地工作区 | bridge 在启动器启动时读了旧的 `browser` mode;或当前 Codex 会话是旧任务根,无法迁移 | ① 重启启动器 GUI(让 bridge 重读 `mode:"full"`);② 退出 Codex CLI 开**全新会话**,不要在同会话切模型 |
| 读取被"运行环境的安全检查拦截 / 当前会话没有可用权限访问这个路径" | 连接器权限是 “Allow low-risk actions”,自动拦截本地读写 | ChatGPT Web 里把 `Codex Native2` 权限改为 **Allow all actions** |
| 即使 Allow all actions,读 `~/.codex`、`~/.ssh` 等仍被拒 | 本地 Codex harness 沙箱保护工作区外敏感目录 | 用普通工作区文件路径验证(如项目目录下的文件),避开敏感路径 |
| 重启启动器后 bridge 起不来 / 端口 17841 被旧进程占着 | 只杀了 AppImage 包装名,真正的 `codex-web-gpt-launcher` 进程还活着 | 杀进程匹配 `codex-web-gpt-launcher`(在 `/tmp/appimage_extracted_*/` 下);必要时杀掉占用 17841 的孤儿 bun 进程再重启 |

## Windows / Linux(待验证,记录已知差异)

- **Linux 原生**:有 FUSE,AppImage 直接挂载即可,不需要 `APPIMAGE_EXTRACT_AND_RUN`;若用代理,加 `--proxy-server`(Chromium 同样不读 env 代理)。
- **Windows**:用官方 `.exe`,系统代理自动生效,基本无需命令行参数;若黑屏,先确认显卡驱动/尝试不在远程桌面下运行。
- 如果你在这两个平台踩到新坑,请提 Issue 并附日志,我们补进本表。
