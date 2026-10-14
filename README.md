# mac-setup

Dock に固定するアプリと並び順は `macos.conf` の `DOCK_APPS` に記載する。
セットアップ時にアプリのインストール後、固定アプリをこの一覧で置き換える。
Finder とフォルダ領域はそのまま残し、見つからないアプリは警告してスキップする。
Device Hub は Xcode Beta 内のパスなので、Xcode のバージョンに合わせて変更する。
Dock のみ確認・反映する場合は `bash dock.sh` / `bash dock.sh --apply` を使う。

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

4. 手動で仕上げる。
   - デフォルトブラウザの確認画面が出たら「Chrome を使用」を選ぶ。
   - Chrome・1Password にログインする。
   - Slack は「環境設定 → アクセシビリティ → 拡大/縮小」で **80%** を選ぶ。
   - 必要な拡張機能・Touch ID・アプリの権限を設定する。
   - HHKB をペアリングモードにして「システム設定 → Bluetooth」で接続する。
   - 「システム設定 → ディスプレイ」で、本体をメインにして外部モニターを真上に配置する。
   - Dock のアイコンにカーソルを載せると拡大し、画面左下にカーソルを移動するとディスプレイがスリープすることを確認する。
   - トラックパッド速度を確認する。速度が反映されなければ、 メニュー →「ログアウト」で入り直すか、Mac を再起動する。
