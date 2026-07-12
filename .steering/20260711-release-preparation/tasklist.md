# リリース準備 タスクリスト

> **作業ディレクトリ:** `.steering/20260711-release-preparation/`
> **作成日:** 2026-07-11

---

## 決定事項（再掲）

- アイコン: Claudeが簡易案を作成
- プライバシーポリシー公開先: GitHub Pages
- keystore生成: 今すぐ対話的に実行

---

## Task 1: リリース署名用keystore生成

- [x] `keytool -genkey` コマンドをユーザーと対話的に実行し、`upload-keystore.jks` を生成
- [x] `android/key.properties` を作成（storePassword/keyPassword/keyAlias/storeFile）し、gitignore対象であることを確認
- [x] keystoreファイルとパスワードをユーザー自身で安全な場所にバックアップするよう案内

## Task 2: アプリ名・パッケージID変更

- [x] `android/app/build.gradle.kts` の `namespace` / `applicationId` を `com.work56ne.fakescreenmaker` に変更（数字始まりの`56nework`はJava/Kotlinパッケージ名として無効なため`work56ne`に修正）
- [x] `MainActivity.kt` のパッケージ宣言変更＋ディレクトリを `com/work56ne/fakescreenmaker/` に移動
- [x] `AndroidManifest.xml` の `android:label` を「撮影用トーク画面メーカー」に変更
- [x] `flutter analyze` でビルド確認

## Task 3: 署名設定をGradleに反映

- [x] `build.gradle.kts` に `signingConfigs.release` を追加し `key.properties` を読み込む設定にする
- [x] `buildTypes.release.signingConfig` をdebugからreleaseに変更
- [x] `flutter build appbundle --release` でAAB生成確認（署名済み・約41MB）

## Task 4: アプリアイコン作成・適用

- [x] Claudeが簡易案（1024×1024マスター画像）を作成し、アーティファクトでユーザーに確認・承認
- [x] `assets/icon/app_icon.png` に正方形フルブリード版を配置し、`flutter_launcher_icons` でAndroid全解像度に適用

## Task 5: リリースビルド確認

- [x] `flutter build appbundle --release` でAAB生成確認（署名済み・約41MB）
- [x] `flutter build apk --release` で署名済みAPK生成確認（約22.4MB）
- [ ] ~~bundletool でAPK抽出し、Windows側AVDにインストールして実機動作確認~~ → **保留**：devcontainer(WSL2/Docker Desktop)からWindows側AVDへのadb接続が`offline`のまま解消せず（ファイアウォール許可・adbバージョン統一・ポート変更等を試したが未解決）。原因は開発環境側のネットワーク構成の差分と推測（[[wsl2_android_emulator_setup]] 参照、過去は同構成で成功していた）
- [ ] 代替：Play Consoleの内部テストトラックにAABをアップロードし、物理Android端末に配布リンクからインストールして最終確認する（Task 8以降、ユーザー環境で実施）
- [x] `minifyEnabled` 未使用のためdebug/release間の実質差分は署名・Dart AOT程度と判断し、リスクは低いと確認

## Task 6: プライバシーポリシー作成・公開

- [x] `docs/privacy-policy.md` を作成（収集情報なし・写真ライブラリはローカル処理のみ・Hiveによる端末内保存の旨を明記）
- [x] GitHub Pagesを有効化（ユーザー承認のうえリポジトリをPublicに変更しPages公開）し、公開URLを確定：`https://56nework2022.github.io/claude-lineapp/privacy-policy`

## Task 7: ストア掲載情報ドラフト作成

- [x] `store-listing-draft.md` を作成（アプリ名・簡単な説明・詳細な説明・コンテンツレーティング方針・データセーフティ回答方針・スクリーンショット撮影案）

## Task 8: 最終チェック・引き継ぎ

- [x] 受け入れ条件（`requirements.md` §4）を全項目確認 → 5/6完了、残る「実機動作確認」は未達（`requirements.md` §4参照）
- [x] Play Console登録・審査提出はユーザー本人の作業として引き継ぎ事項をまとめる → `handoff.md` 作成済み

---

## 完了条件

`requirements.md` の受け入れ条件をすべて満たし、Play Consoleへの提出に必要な技術的準備（署名済みAAB・アイコン・プライバシーポリシーURL・掲載文ドラフト）が揃っている状態。
