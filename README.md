# mac-setup

Dock に固定するアプリと並び順は `macos.conf` の `DOCK_APPS` に記載する。
セットアップ時にアプリのインストール後、固定アプリをこの一覧で置き換える。
Finder とフォルダ領域はそのまま残し、見つからないアプリは警告してスキップする。
Dock のみ確認・反映する場合は `bash dock.sh` / `bash dock.sh --apply` を使う。

スクリーンショットと画面収録は `~/Pictures` に保存する。
保存先は `macos.conf` の `SCREENSHOT_LOCATION` で変更できる。
ショートカットはこの PC と同じ設定にする（`screenshot-shortcuts.plist`）。
`⌘⇧2` で範囲を選んで保存、`⌘⇧3` で画面全体を保存、`⌘⇧5` で撮影・収録ツールを開く。
`⌃⌘⇧4` で範囲をクリップボードにコピーでき、画面全体のクリップボードコピーは無効にする。
ショートカットが変わらない場合はログアウトして再ログインする。

ghq と peco もインストールする。新しいターミナルを開くと、`Ctrl+G` でリポジトリを
選んで移動でき、`Ctrl+R` で履歴を検索できる。既存の `.zshrc` に設定の読み込み行を追加する。
ghq の保存先は標準の `~/ghq` を使い、既存の `ghq.root` 設定があれば維持する。
リポジトリを追加する時は `ghq get kno3a87/mac-setup` のように実行する。

iTerm2 は `iterm2/com.googlecode.iterm2.plist` に保存した配色・12pt のフォント・
無制限のスクロール履歴を読み込む。Droid Sans Mono Nerd Font もインストールする。
セットアップ時は iTerm2 を終了し、macOS 標準の「ターミナル」等から実行する。
iTerm2 が起動中だった場合は、終了後に `bash iterm-setup.sh --apply` で設定のみ反映する。
設定は `~/.config/mac-setup/iterm2` に配置し、初回反映前の設定は同じ場所の
`before-setup.plist` に保存する。元のプロファイルは保存済みの Default プロファイルに置き換わる。

1. [Homebrew](https://brew.sh/) をインストールし、表示される `Next steps` を実行する。
2. リポジトリを取得する。

   ```sh
   git clone https://github.com/kno3a87/mac-setup.git
   cd mac-setup
   ```

3. 実行予定を確認して、セットアップする。

   ```sh
   bash setup.sh          # 確認
   bash setup.sh --apply  # 実行
   ```

   完了後、新しいターミナルを開いてシェル設定を反映する。
   今の zsh で続ける場合は、完了時に表示される `source` コマンドを実行する
   （通常は `source ~/.zshrc`）。

4. 手動で仕上げる。
   - デフォルトブラウザの確認画面が出たら「Chrome を使用」を選ぶ。
   - Chrome・1Password にログインする。
   - Slack は「環境設定 → アクセシビリティ → 拡大/縮小」で **80%** を選ぶ。
   - 必要な拡張機能・Touch ID・アプリの権限を設定する。
   - HHKB をペアリングモードにして「システム設定 → Bluetooth」で接続する。
   - 「システム設定 → ディスプレイ」で、本体をメインにして外部モニターを真上に配置する。
   - Dock のアイコンにカーソルを載せると拡大し、画面左下にカーソルを移動するとディスプレイがスリープすることを確認する。
   - トラックパッド速度を確認する。速度が反映されなければ、 メニュー →「ログアウト」で入り直すか、Mac を再起動する。
