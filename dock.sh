#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MODE=${1:---dry-run}
if [[ $# -gt 1 || ( "$MODE" != --dry-run && "$MODE" != --apply ) ]]; then
  echo "使い方: bash dock.sh [--dry-run|--apply]" >&2
  exit 1
fi
if [[ $(uname -s) != Darwin ]]; then
  echo "macOS 専用のスクリプトです。" >&2
  exit 1
fi

# shellcheck source=macos.conf
source "$SCRIPT_DIR/macos.conf"
[[ ${#DOCK_APPS[@]} -gt 0 ]] || exit 0
for app in "${DOCK_APPS[@]}"; do
  if [[ "$app" != /*.app ]]; then
    echo "設定エラー: DOCK_APPS は .app の絶対パスで指定してください: $app" >&2
    exit 1
  fi
done

run() {
  printf '%q ' "$@"
  printf '\n'
  if [[ "$MODE" == --apply ]]; then "$@"; fi
}

tiles=()
for app in "${DOCK_APPS[@]}"; do
  # Homebrew のインストール先や Codex のアプリ名が異なる環境にも対応する。
  if [[ "$MODE" == --apply && ! -d "$app" ]]; then
    if [[ "$app" == /Applications/ChatGPT.app && -d /Applications/Codex.app ]]; then
      app=/Applications/Codex.app
    elif [[ "$app" == /Applications/* && -d "$HOME/Applications/${app##*/}" ]]; then
      app="$HOME/Applications/${app##*/}"
    else
      echo "スキップ（アプリが見つかりません）: $app" >&2
      continue
    fi
  fi
  escaped=${app//&/&amp;}
  escaped=${escaped//</&lt;}
  escaped=${escaped//>/&gt;}
  tiles+=("<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$escaped</string><key>_CFURLStringType</key><integer>0</integer></dict></dict><key>tile-type</key><string>file-tile</string></dict>")
done

# 全件見つからない場合は既存の Dock を残す。
[[ ${#tiles[@]} -gt 0 ]] || exit 0
# アプリ領域だけを置き換えるため、フォルダ・ダウンロード等は保持される。
run defaults write com.apple.dock persistent-apps -array "${tiles[@]}"
if [[ "$MODE" == --dry-run ]] || pgrep -x Dock >/dev/null; then
  run killall Dock
fi
