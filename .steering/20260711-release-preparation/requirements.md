# リリース準備 要求内容

> **作業ディレクトリ:** `.steering/20260711-release-preparation/`
> **作成日:** 2026-07-11

---

## 1. 今回の作業概要

フェーズ1（MVP）の実機動作確認が完了した「撮影用トーク画面メーカー」を、Google Play（Android）で正式に公開できる状態に仕上げる。iOS（App Store）対応は今回のスコープ外（macOS/Xcode環境が未整備のため）。

---

## 2. 決定事項

| 項目 | 内容 |
|------|------|
| 正式アプリ名 | 撮影用トーク画面メーカー |
| applicationId（パッケージID） | `com.56nework.fakescreenmaker` |
| 配信方法 | Google Play（Play Console） |
| 対象プラットフォーム | Android のみ（iOS は将来対応） |

---

## 3. 対応対象

### 3-1. アプリ基本情報の変更

- `applicationId` / `namespace` を `com.example.fake_screen_maker` → `com.56nework.fakescreenmaker` に変更
- アプリ表示名（`android:label`）を `fake_screen_maker` → 「撮影用トーク画面メーカー」に変更
- `pubspec.yaml` の `name` / `description` を必要に応じて見直し

### 3-2. アプリアイコン

- 現在Flutterデフォルトアイコンのままのため、正式なアプリアイコンを作成し全解像度（mipmap-*）に反映

### 3-3. リリースビルド・署名

- リリース用keystore（署名鍵）を作成
- `android/app/build.gradle.kts` に署名設定を追加
- リリースAAB（Android App Bundle）のビルド確認

### 3-4. Play Console登録・ストア掲載情報

- Google Play Console アカウント登録（$25、ユーザー側の作業）
- ストア掲載情報：アプリ名、簡単な説明、詳細な説明、スクリーンショット、フィーチャーグラフィック
- コンテンツレーティング質問票への回答
- データセーフティフォーム（フォトライブラリアクセスの申告）

### 3-5. プライバシーポリシー

- アイコン画像選択・画像書き出し機能で端末の写真ライブラリにアクセスするため、Play Store公開には必須
- 公開先（GitHub Pagesなど）を含めて作成

### 3-6. リリース前チェック

- `flutter analyze` クリーン確認（再確認）
- リリースビルドでの実機動作確認（署名済みAPK/AABをエミュレータ or 実機にインストールして確認）
- 内部テスト配信（Play Console の内部テストトラック）での動作確認

---

## 4. 受け入れ条件

- [ ] applicationId・アプリ表示名が正式なものに変更されている
- [ ] 正式なアプリアイコンが全解像度に反映されている
- [ ] リリース用keystoreで署名されたAABがビルドできる
- [ ] プライバシーポリシーが作成され、公開URLが用意されている
- [ ] ストア掲載情報（説明文・スクリーンショット等）の下書きが揃っている
- [ ] リリースビルドを実機（エミュレータ）にインストールし、フェーズ1機能一式が問題なく動作する

---

## 5. 制約事項

- iOS（App Store）対応は今回のスコープ外
- フェーズ2機能（着信・通話・SNSフィード）・買い切り課金の実装は今回のスコープ外
- Play Console登録（アカウント作成・$25の支払い）はユーザー本人が行う
- Google Playの審査・公開自体（実際のリリースボタンを押す操作）はユーザー承認のうえで行う

---

## 6. 関連ドキュメント

- `docs/product-requirements.md` — プロダクト要求定義書
- `docs/architecture.md` — 技術仕様書（買い切り課金・NDK等の記載あり）
- `.steering/20260630-initial-implementation/` — 初回実装のステアリング
