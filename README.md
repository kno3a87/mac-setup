# mac-setup

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
   - Chrome・1Password にログインする。
   - 必要な拡張機能・Touch ID・アプリの権限を設定する。
   - HHKB をペアリングモードにして「システム設定 → Bluetooth」で接続する。
   - Dock とトラックパッド速度を確認する。速度が反映されなければ、 メニュー →「ログアウト」で入り直すか、Mac を再起動する。
