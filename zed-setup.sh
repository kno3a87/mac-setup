#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MODE=${1:---dry-run}
if [[ $# -gt 1 || ( "$MODE" != --dry-run && "$MODE" != --apply ) ]]; then
  echo "使い方: bash zed-setup.sh [--dry-run|--apply]" >&2
  exit 1
fi

config_dir="$HOME/.config/zed"
settings="$config_dir/settings.json"
backup_dir="$HOME/.config/mac-setup/zed"
backup="$backup_dir/before-setup.json"
echo "Zed 設定: プロジェクトパネルは左、Ayu Light、VSCode キーバインド、UI 14pt・本文 13pt"
echo "Zed 設定: 自動保存とセマンティックトークンを無効化"
echo "Zed 設定: $settings を置き換え、初回反映前の設定は $backup に保存"
if [[ "$MODE" == --dry-run ]]; then exit 0; fi

mkdir -p "$config_dir"
# 最初の反映前の設定を保存し、再実行時もこのバックアップは保持する。
if [[ -f "$settings" && ! -f "$backup" ]]; then
  mkdir -p "$backup_dir"
  cp -p "$settings" "$backup"
fi
cp "$SCRIPT_DIR/zed/settings.json" "$settings"
