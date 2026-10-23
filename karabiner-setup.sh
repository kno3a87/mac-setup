#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MODE=${1:---dry-run}
if [[ $# -gt 1 || ( "$MODE" != --dry-run && "$MODE" != --apply ) ]]; then
  echo "使い方: bash karabiner-setup.sh [--dry-run|--apply]" >&2
  exit 1
fi

echo "Karabiner 設定: 左⌘の単押しで英数、右⌘の単押しでかな"
echo "HHKB 接続中は Mac の内蔵キーボードを無効にします。"
echo "選択中のプロファイルに追加し、既存の設定は保持します。"
if [[ "$MODE" == --dry-run ]]; then exit 0; fi

/usr/bin/ruby - "$SCRIPT_DIR/karabiner/command-eikana.json" "$SCRIPT_DIR/karabiner/devices.json" <<'RUBY'
require 'json'
require 'fileutils'
require 'tempfile'

path = File.expand_path('~/.config/karabiner/karabiner.json')
backup = File.expand_path('~/.config/mac-setup/karabiner/before-setup.json')
rule = JSON.parse(File.read(ARGV.fetch(0)))
config = File.exist?(path) ? JSON.parse(File.read(path)) : {}
profiles = config['profiles'] ||= []
profiles << { 'name' => 'Default profile', 'selected' => true } if profiles.empty?
profile = profiles.find { |p| p['selected'] } || profiles.first
devices = profile['devices'] ||= []
JSON.parse(File.read(ARGV.fetch(1))).each do |setting|
  device = devices.find { |d| d['identifiers'] == setting.fetch('identifiers') }
  if device
    device.merge!(setting)
  else
    devices << setting
  end
end
modifications = profile['complex_modifications'] ||= {}
rules = modifications['rules'] ||= []
# 同じ設定の再実行でルールを重複させない。
rules.reject! { |r| r['description'] == rule.fetch('description') }
rules.unshift(rule)
output = JSON.pretty_generate(config) + "\n"

if File.file?(path) && !File.exist?(backup)
  FileUtils.mkdir_p(File.dirname(backup))
  FileUtils.cp(path, backup, preserve: true)
end
FileUtils.mkdir_p(File.dirname(path))
Tempfile.create(['karabiner-', '.json'], File.dirname(path)) do |file|
  file.write(output)
  file.close
  File.rename(file.path, path)
end
puts "反映しました: #{path}"
RUBY

echo "Karabiner-Elements を開き、初回設定で案内される権限を許可してください。"
