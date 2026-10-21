#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MODE=${1:---dry-run}
if [[ $# -gt 1 || ( "$MODE" != --dry-run && "$MODE" != --apply ) ]]; then
  echo "使い方: bash shell-setup.sh [--dry-run|--apply]" >&2
  exit 1
fi

config_dir="$HOME/.config/mac-setup"
zshrc="${ZDOTDIR:-$HOME}/.zshrc"
source_line='source "$HOME/.config/mac-setup/shell.zsh"'
echo "シェル設定: ghq の保存先は標準の ~/ghq（既存の ghq.root 設定があればそちらを使用）"
echo "シェル設定: Ctrl+G でリポジトリ選択、Ctrl+R で履歴検索（peco）"
echo "シェル設定: 履歴・補完候補を薄く表示し、行末で → キーを押すと取り込む"
echo "シェル設定: $config_dir/shell.zsh を配置し、$zshrc に読み込み行を追加"
if [[ "$MODE" == --dry-run ]]; then exit 0; fi

mkdir -p "$config_dir" "$(dirname -- "$zshrc")"
cp "$SCRIPT_DIR/shell.zsh" "$config_dir/shell.zsh"
if [[ ! -f "$zshrc" ]] || ! grep -Fqx "$source_line" "$zshrc"; then
  printf '\n%s\n' "$source_line" >> "$zshrc"
fi
