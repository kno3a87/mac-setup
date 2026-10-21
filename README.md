# mac-setup

Karabiner-Elements で、左⌘の単押しを英数、右⌘の単押しをかなにする。
⌘を他のキーと組み合わせるショートカットもそのまま使える。
設定は `karabiner/command-eikana.json` で管理し、選択中のプロファイルへ追加する。
既存の他の設定は保持し、初回反映前の設定は
`~/.config/mac-setup/karabiner/before-setup.json` に保存する。
設定のみ確認・反映する場合は `bash karabiner-setup.sh` / `bash karabiner-setup.sh --apply` を使う。
初回は Karabiner-Elements を開き、案内される権限を許可する。
macOS の入力ソースには日本語を追加しておく。
日本語入力のライブ変換（リアルタイム変換）はセットアップ時に無効にする。
反映されない場合はログアウトして再ログインする。

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

Delete などを長押ししたときのキーリピートを速くし、連続入力が始まるまでの待ち時間も短くする。
`macos.conf` の `KEY_REPEAT=2` と `INITIAL_KEY_REPEAT=15` で管理する。
値を空にすると、その項目の既存設定を維持する。
`bash macos.sh` で Dock などを含む macOS 設定の適用予定を確認し、
`bash macos.sh --apply` で反映する。
適用時はショートカットを再読み込みする。動作が変わらなければ、ログアウトして再ログインする。

文字サイズは `macos.conf` の `TEXT_SIZE=10` で 10pt にする。
macOS の「アクセシビリティ → ディスプレイ → テキストサイズ」に対応する設定で、
対応アプリに適用する。独自の文字サイズを使うアプリやメニューバーには適用されない。
9〜17pt を指定でき、`default` で標準に戻す。空にすると既存の設定を維持する。
`bash macos.sh --apply` で保存し、表示に反映されなければ対象アプリを再起動する。

`FontSizeCategory` は macOS の内部設定のため、反映は OS・アプリに依存する。
書き込みや表示への反映ができない場合は、上記のシステム設定から指定する。

ghq と peco もインストールする。新しいターミナルを開くと、`Ctrl+G` でリポジトリを
選んで移動でき、`Ctrl+R` で履歴を検索できる。既存の `.zshrc` に設定の読み込み行を追加する。
ghq の保存先は標準の `~/ghq` を使い、既存の `ghq.root` 設定があれば維持する。
リポジトリを追加する時は `ghq get kno3a87/mac-setup` のように実行する。

`zsh-autosuggestions` で、入力中にコマンドの続きを薄いグレーで表示する。
履歴を優先し、一致する履歴がなければ zsh の補完候補から提案する。
行末で `→` キーを押すと候補を取り込み、Enter で実行する。
既存の環境にこの設定だけ追加する場合は、次を実行して新しいターミナルを開く。

```sh
brew install zsh-autosuggestions
bash shell-setup.sh --apply
```

Zed の設定は `zed/settings.json` で管理する。プロジェクトパネルを左に配置し、
テーマは Ayu Light、キーバインドは VSCode、フォントサイズは UI 14pt・本文 13pt にする。
自動保存とセマンティックトークンは無効にする。
セットアップ時に `~/.config/zed/settings.json` をこのファイルで置き換える。
初回反映前の設定は `~/.config/mac-setup/zed/before-setup.json` に保存する。
Zed の設定のみ確認・反映する場合は `bash zed-setup.sh` / `bash zed-setup.sh --apply` を使う。

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

   実行中に GitHub のログイン案内が表示されたら、表示されるコードとブラウザの案内に従う。
   認証済みの場合はログインをスキップし、Git の HTTPS 認証設定と状態確認を行う。

4. 手動で仕上げる。
   - 下記の「GitHub の初期設定」を参照して、Git の名前・メールアドレスを設定する。
   - デフォルトブラウザの確認画面が出たら「Chrome を使用」を選ぶ。
   - Chrome・1Password にログインする。
   - Slack は「環境設定 → アクセシビリティ → 拡大/縮小」で **80%** を選ぶ。
   - 必要な拡張機能・Touch ID・アプリの権限を設定する。
   - HHKB をペアリングモードにして「システム設定 → Bluetooth」で接続する。
   - 「システム設定 → ディスプレイ」で、本体をメインにして外部モニターを真上に配置する。
   - Dock のアイコンにカーソルを載せると拡大し、画面左下にカーソルを移動するとディスプレイがスリープすることを確認する。
   - トラックパッド速度を確認する。速度が反映されなければ、 メニュー →「ログアウト」で入り直すか、Mac を再起動する。

## GitHub の初期設定

GitHub CLI（`gh`）はセットアップでインストールする。
Git は HTTPS を使うため、SSH 鍵の作成・登録は不要。
セットアップ中にブラウザでのログイン、Git の HTTPS 認証設定、状態確認まで行う。
ログイン操作は本人が行う。後から認証をやり直す場合は、次を実行する。

```sh
gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git --hostname github.com
gh auth status --hostname github.com
```

コミットに使う名前・メールアドレスも設定する。以下の値は自分のものに置き換える。
メールアドレスは GitHub に登録済みのもの、または
[GitHub のメール設定](https://github.com/settings/emails)に表示される `noreply` アドレスを使う。
既に設定済みの場合は、現在の値を確認して必要な場合のみ変更する。

```sh
git config --global --get user.name
git config --global --get user.email
git config --global user.name "自分の名前"
git config --global user.email "自分のメールアドレス"
```

認証手順の詳細は [gh auth login](https://cli.github.com/manual/gh_auth_login) と
[gh auth setup-git](https://cli.github.com/manual/gh_auth_setup-git) を参照。
