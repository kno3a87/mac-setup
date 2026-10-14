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
case "$DOCK_MAGNIFICATION" in true|false|"") ;; *) fail "DOCK_MAGNIFICATION は true/false" ;; esac
[[ -z "$DOCK_LARGE_SIZE" || "$DOCK_LARGE_SIZE" =~ ^[1-9][0-9]*$ ]] || fail "DOCK_LARGE_SIZE は正の整数"
case "$HOT_CORNER_BOTTOM_LEFT" in display-sleep|"") ;; *) fail "HOT_CORNER_BOTTOM_LEFT は display-sleep" ;; esac
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
if [[ -n "$DOCK_MAGNIFICATION" ]]; then
  run defaults write com.apple.dock magnification -bool "$DOCK_MAGNIFICATION"
  dock_changed=true
fi
if [[ -n "$DOCK_LARGE_SIZE" ]]; then
  run defaults write com.apple.dock largesize -int "$DOCK_LARGE_SIZE"
  dock_changed=true
fi
if [[ "$HOT_CORNER_BOTTOM_LEFT" == display-sleep ]]; then
  run defaults write com.apple.dock wvous-bl-corner -int 10
  run defaults write com.apple.dock wvous-bl-modifier -int 0
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
