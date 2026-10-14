#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MODE=${1:---dry-run}
if [[ $# -gt 1 || ( "$MODE" != --dry-run && "$MODE" != --apply ) ]]; then
  echo "使い方: bash setup.sh [--dry-run|--apply]" >&2
  exit 1
fi
if [[ $(uname -s) != Darwin ]]; then
  echo "macOS 専用のスクリプトです。" >&2
  exit 1
fi

# アプリのインストール前に、OS 設定の検証と実行予定の表示を行う。
bash "$SCRIPT_DIR/macos.sh" --dry-run
printf '\nインストール対象:\n'
cat "$SCRIPT_DIR/Brewfile"

if [[ "$MODE" == --dry-run ]]; then
  echo "確認のみです。実行するには bash setup.sh --apply を指定してください。"
  exit 0
fi

if command -v brew >/dev/null 2>&1; then
  BREW=$(command -v brew)
elif [[ -x /opt/homebrew/bin/brew ]]; then
  BREW=/opt/homebrew/bin/brew
elif [[ -x /usr/local/bin/brew ]]; then
  BREW=/usr/local/bin/brew
else
  echo "Homebrew が必要です。README の初回セットアップを参照してください。" >&2
  exit 1
fi

"$BREW" bundle install --file="$SCRIPT_DIR/Brewfile" --no-upgrade
bash "$SCRIPT_DIR/macos.sh" --apply
echo "完了しました。README の手動作業を確認してください。"
