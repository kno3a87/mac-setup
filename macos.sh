#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MODE=${1:---dry-run}
if [[ $# -gt 1 || ( "$MODE" != --dry-run && "$MODE" != --apply ) ]]; then
  echo "使い方: bash macos.sh [--dry-run|--apply]" >&2
  exit 1
fi
if [[ $(uname -s) != Darwin ]]; then
  echo "macOS 専用のスクリプトです。" >&2
  exit 1
fi

# shellcheck source=macos.conf
source "$SCRIPT_DIR/macos.conf"

fail() { echo "設定エラー: $1" >&2; exit 1; }
case "$DOCK_POSITION" in left|bottom|right|"") ;; *) fail "DOCK_POSITION は left/bottom/right" ;; esac
[[ -z "$DOCK_SIZE" || "$DOCK_SIZE" =~ ^[1-9][0-9]*$ ]] || fail "DOCK_SIZE は正の整数"
case "$DOCK_AUTOHIDE" in true|false|"") ;; *) fail "DOCK_AUTOHIDE は true/false" ;; esac
[[ -z "$TRACKPAD_SPEED" || "$TRACKPAD_SPEED" =~ ^[0-9]+([.][0-9]+)?$ ]] || fail "TRACKPAD_SPEED は 0 以上の数値"

run() {
  printf '%q ' "$@"
  printf '\n'
  if [[ "$MODE" == --apply ]]; then "$@"; fi
}

dock_changed=false
if [[ -n "$DOCK_POSITION" ]]; then
  run defaults write com.apple.dock orientation -string "$DOCK_POSITION"
  dock_changed=true
fi
if [[ -n "$DOCK_SIZE" ]]; then
  run defaults write com.apple.dock tilesize -int "$DOCK_SIZE"
  dock_changed=true
fi
if [[ -n "$DOCK_AUTOHIDE" ]]; then
  run defaults write com.apple.dock autohide -bool "$DOCK_AUTOHIDE"
  dock_changed=true
fi
if [[ -n "$TRACKPAD_SPEED" ]]; then
  run defaults write -g com.apple.trackpad.scaling -float "$TRACKPAD_SPEED"
fi
if [[ "$dock_changed" == true ]]; then
  if [[ "$MODE" == --dry-run ]]; then
    run killall Dock
  elif pgrep -x Dock >/dev/null; then
    run killall Dock
  fi
fi
if [[ "$MODE" == --apply ]]; then
  echo "設定を反映しました。速度が変わらない場合はログアウトして再ログインしてください。"
fi
