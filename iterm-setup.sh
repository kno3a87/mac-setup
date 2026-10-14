#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MODE=${1:---dry-run}
if [[ $# -gt 1 || ( "$MODE" != --dry-run && "$MODE" != --apply ) ]]; then
  echo "使い方: bash iterm-setup.sh [--dry-run|--apply]" >&2
  exit 1
fi
if [[ $(uname -s) != Darwin ]]; then
  echo "macOS 専用のスクリプトです。" >&2
  exit 1
fi

config_dir="$HOME/.config/mac-setup/iterm2"
plist="$SCRIPT_DIR/iterm2/com.googlecode.iterm2.plist"
plutil -lint "$plist" >/dev/null
echo "iTerm2 設定: この PC の配色、Droid Sans Mono Nerd Font 12pt、無制限のスクロール履歴"
echo "iTerm2 設定: $config_dir から設定を読み込む"
if [[ "$MODE" == --dry-run ]]; then exit 0; fi

if pgrep -x iTerm2 >/dev/null; then
  echo "iTerm2 設定は未反映です。iTerm2 を終了し、別のターミナルから bash iterm-setup.sh --apply を実行してください。" >&2
  exit 0
fi
if [[ ! -f "$HOME/Library/Fonts/DroidSansMNerdFont-Regular.otf" && ! -f /Library/Fonts/DroidSansMNerdFont-Regular.otf ]]; then
  echo "Droid Sans Mono Nerd Font がありません。先に bash setup.sh --apply でインストールしてください。" >&2
  exit 1
fi

mkdir -p "$config_dir"
# 最初の反映前の設定を保存し、再実行時もこのバックアップは保持する。
backup="$config_dir/before-setup.plist"
if [[ ! -f "$backup" ]] && defaults read com.googlecode.iterm2 >/dev/null 2>&1; then
  defaults export com.googlecode.iterm2 "$backup"
fi
cp "$plist" "$config_dir/com.googlecode.iterm2.plist"
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$config_dir"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
echo "iTerm2 の次回起動から設定を読み込みます。"
