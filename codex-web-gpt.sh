#!/bin/sh
# codex-web-gpt.sh — WSL2 上启动 codex-chatgpt-web 的包装脚本(已实测)
#
# 这个脚本把 WSL2 下所有坑的修复参数集中起来,直接 `codex-web-gpt` 即可启动,
# 不要再直接跑原始 AppImage(否则会黑屏 / 连不上网 / ENOENT)。
#
# 使用前请修改下面两处:
#   1. APPIMAGE 路径(指向你实际安装的 AppImage)
#   2. PROXY(若你不用 127.0.0.1:7897,改成自己的代理;不用代理则删掉那两行)

set -eu

# ====== 你需要改的地方 ======
APPIMAGE="$HOME/.local/lib/codex-web-gpt/2.1.11/Codex Web GPT.AppImage"
PROXY="http://127.0.0.1:7897"
# ============================

# Extract mode 必选:WSL2 没有 FUSE,AppImage 不能以挂载模式运行。
# APPIMAGE_EXTRACT_AND_RUN=1 会解压后就地运行。
export APPIMAGE_EXTRACT_AND_RUN="${APPIMAGE_EXTRACT_AND_RUN:-1}"

# 这两个变量告诉 AppImage 内部的启动器去哪找自己(避免 ENOENT)。
export CODEX_WEB_GPT_LAUNCHER_EXECUTABLE="$APPIMAGE"
export CODEX_WEB_GPT_APPIMAGE="$APPIMAGE"

exec "$APPIMAGE" \
  --no-zygote --no-sandbox \
  --disable-gpu-compositing \
  --use-gl=angle --use-angle=swiftshader --enable-unsafe-swiftshader \
  --proxy-server="$PROXY" \
  --proxy-bypass-list="127.0.0.1;localhost" \
  "$@"
