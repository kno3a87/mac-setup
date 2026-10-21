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
[[ -z "$KEY_REPEAT" || "$KEY_REPEAT" =~ ^[0-9]+$ ]] || fail "KEY_REPEAT は 0 以上の整数"
[[ -z "$INITIAL_KEY_REPEAT" || "$INITIAL_KEY_REPEAT" =~ ^[0-9]+$ ]] || fail "INITIAL_KEY_REPEAT は 0 以上の整数"
[[ -z "$SCREENSHOT_LOCATION" || "$SCREENSHOT_LOCATION" == /* ]] || fail "SCREENSHOT_LOCATION は絶対パス"
case "$TEXT_SIZE" in 9|10|11|12|13|14|15|16|17|default|"") ;; *) fail "TEXT_SIZE は 9〜17/default、または空" ;; esac
plutil -lint "$SCRIPT_DIR/screenshot-shortcuts.plist" >/dev/null
# 設定全体を書き換えず、スクリーンショット関連の5項目だけを反映する。
shortcut_values=()
for key in 28 29 30 31 184; do
  shortcut_values+=("$(/usr/libexec/PlistBuddy -x -c "Print :AppleSymbolicHotKeys:$key" "$SCRIPT_DIR/screenshot-shortcuts.plist")")
done

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
if [[ -n "$KEY_REPEAT" ]]; then
  run defaults write -g KeyRepeat -int "$KEY_REPEAT"
fi
if [[ -n "$INITIAL_KEY_REPEAT" ]]; then
  run defaults write -g InitialKeyRepeat -int "$INITIAL_KEY_REPEAT"
fi
# 「アクセシビリティ → ディスプレイ → テキストサイズ」の優先文字サイズ。
# アプリごとの指定は保持し、全体の設定だけを変更する。
if [[ -n "$TEXT_SIZE" ]]; then
  text_size_category=DEFAULT
  if [[ "$TEXT_SIZE" != default ]]; then
    text_size_categories=(XXXS XXS XS S M L XL XXL XXXL)
    text_size_category=${text_size_categories[$((TEXT_SIZE - 9))]}
  fi
  run defaults write com.apple.universalaccess FontSizeCategory -dict-add global "$text_size_category"
fi
# 日本語入力のライブ変換を無効にする。
run defaults write com.apple.inputmethod.Kotoeri JIMPrefLiveConversionKey -bool false
if [[ -n "$SCREENSHOT_LOCATION" ]]; then
  run mkdir -p "$SCREENSHOT_LOCATION"
  for key in location location-last location-screenshot location-screenrecording; do
    run defaults write com.apple.screencapture "$key" -string "$SCREENSHOT_LOCATION"
  done
  for key in target target-screenshot target-screenrecording; do
    run defaults write com.apple.screencapture "$key" -string file
  done
fi
index=0
for key in 28 29 30 31 184; do
  run defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$key" "${shortcut_values[$index]}"
  index=$((index + 1))
done
# 保存したショートカットを現在のログインセッションにも読み込ませる。
activate_settings=/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings
if [[ -x "$activate_settings" ]]; then
  if ! run "$activate_settings" -u; then
    echo "設定の再読み込みに失敗しました。ログアウトして再ログインしてください。" >&2
  fi
else
  echo "設定の再読み込みコマンドがありません。ログアウトして再ログインしてください。" >&2
fi
if [[ "$dock_changed" == true ]]; then
  if [[ "$MODE" == --dry-run ]]; then
    run killall Dock
  elif pgrep -x Dock >/dev/null; then
    run killall Dock
  fi
fi
if [[ "$MODE" == --apply ]]; then
  echo "設定を反映しました。キーリピート・トラックパッド速度・日本語入力のライブ変換・スクリーンショットのショートカットが変わらない場合はログアウトして再ログインしてください。"
fi
