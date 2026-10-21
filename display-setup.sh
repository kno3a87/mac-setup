#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MODE=${1:---dry-run}
if [[ $# -gt 1 || ( "$MODE" != --dry-run && "$MODE" != --apply && "$MODE" != --list ) ]]; then
  echo "使い方: bash display-setup.sh [--dry-run|--apply|--list]" >&2
  exit 1
fi
if [[ $(uname -s) != Darwin ]]; then
  echo "macOS 専用のスクリプトです。" >&2
  exit 1
fi

# shellcheck source=macos.conf
source "$SCRIPT_DIR/macos.conf"

DISPLAYPLACER=$(command -v displayplacer || true)
if [[ -z "$DISPLAYPLACER" ]]; then
  for candidate in /opt/homebrew/bin/displayplacer /usr/local/bin/displayplacer; do
    if [[ -x "$candidate" ]]; then
      DISPLAYPLACER=$candidate
      break
    fi
  done
fi

require_displayplacer() {
  if [[ -z "$DISPLAYPLACER" ]]; then
    echo "displayplacer が必要です。brew install displayplacer を実行してください。" >&2
    exit 1
  fi
}

if [[ "$MODE" == --list ]]; then
  require_displayplacer
  exec "$DISPLAYPLACER" list
fi

if [[ ${#DISPLAY_CONFIGS[@]} -eq 0 ]]; then
  echo "ディスプレイ: DISPLAY_CONFIGS が空のため、現在の表示設定を維持します。"
  exit 0
fi
for config in "${DISPLAY_CONFIGS[@]}"; do
  if [[ "$config" != id:?* ]]; then
    echo "設定エラー: DISPLAY_CONFIGS は id: で始まる画面ごとの引数を指定してください。" >&2
    exit 1
  fi
done

if [[ "$MODE" == --apply ]]; then
  require_displayplacer
fi
printf '%q ' "${DISPLAYPLACER:-displayplacer}" "${DISPLAY_CONFIGS[@]}"
printf '\n'
if [[ "$MODE" == --apply ]]; then
  "$DISPLAYPLACER" "${DISPLAY_CONFIGS[@]}"
fi
