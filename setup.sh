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

while IFS='|' read -r cask app; do
  if [[ -d "/Applications/$app" || -d "$HOME/Applications/$app" ]]; then
    export HOMEBREW_BUNDLE_CASK_SKIP="${HOMEBREW_BUNDLE_CASK_SKIP:-} $cask"
    printf 'スキップ（インストール済み）: %s\n' "$cask"
  fi
done <<'EOF'
google-chrome|Google Chrome.app
1password|1Password.app
gitkraken|GitKraken.app
karabiner-elements|Karabiner-Elements.app
slack|Slack.app
figma|Figma.app
cursor|Cursor.app
codex-app|Codex.app
docker-desktop|Docker.app
zed|Zed.app
EOF

echo "デフォルトブラウザ: Google Chrome"

if [[ "$MODE" == --dry-run ]]; then
  echo "確認のみです。実行するには bash setup.sh --apply を指定してください。"
  exit 0
fi

bash "$SCRIPT_DIR/macos.sh" --apply

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
chrome_app="/Applications/Google Chrome.app"
if [[ ! -d "$chrome_app" ]]; then
  chrome_app="$HOME/Applications/Google Chrome.app"
fi
if [[ ! -d "$chrome_app" ]]; then
  echo "Google Chrome が見つかりません。" >&2
  exit 1
fi
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$chrome_app"
echo "確認画面が出たら「Chrome を使用」を選んでください。"
"$("$BREW" --prefix)/bin/defaultbrowser" chrome
echo "完了しました。README の手動作業を確認してください。"
