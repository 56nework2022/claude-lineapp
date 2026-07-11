# リリース準備 設計

> **作業ディレクトリ:** `.steering/20260711-release-preparation/`
> **作成日:** 2026-07-11

---

## 1. 実装アプローチ

`requirements.md` の6項目（3-1〜3-6）を、依存関係の順に沿って対応する。

```
3-1 基本情報変更 → 3-2 アイコン作成 → 3-3 署名・リリースビルド → 3-6 実機確認
                                    → 3-4 Play Console/ストア掲載情報（並行）
                                    → 3-5 プライバシーポリシー（並行）
```

3-4・3-5はコード変更を伴わないため、3-3までのビルド作業と並行して進められる。Play Console登録の実行・審査提出はユーザー承認が必要なため、Claudeが担当するのはドラフト作成・技術対応までとする。

---

## 2. 変更するコンポーネント

### 2-1. `applicationId` / パッケージ名変更

`com.example.fake_screen_maker` → `com.56nework.fakescreenmaker`

Flutter/Androidのパッケージ名変更は、単純な文字列置換では不整合が起きやすいため、`rename` パッケージ（`dart pub global activate rename`）または手動での以下手順を使う。

**変更対象ファイル：**
- `android/app/build.gradle.kts` — `namespace`, `defaultConfig.applicationId`
- `android/app/src/main/kotlin/com/example/fake_screen_maker/MainActivity.kt` — パッケージ宣言 + ディレクトリを `com/56nework/fakescreenmaker/` に移動
- `android/app/src/main/AndroidManifest.xml` — `android:label` を「撮影用トーク画面メーカー」に変更（`applicationId` はManifestに直接記載されていないため変更不要）
- iOS側（`ios/Runner.xcodeproj/project.pbxproj` の `PRODUCT_BUNDLE_IDENTIFIER`）は今回スコープ外だが、Flutterプロジェクトとしての一貫性のため、iOS側の bundle id は現状の `com.example.fakeScreenMaker` のまま変更しない（将来iOS対応時に別途決定）

**変更しないもの：**
- `pubspec.yaml` の `name: fake_screen_maker`（Dartパッケージ名。Dartの識別子制約上スネークケース英数字のみで、ストア表示名とは独立の内部名称のため変更不要）

### 2-2. アプリアイコン

- `flutter_launcher_icons` パッケージ（dev_dependencies）を導入し、1枚のマスター画像（1024×1024 PNG）から Android 全解像度（mipmap-mdpi〜xxxhdpi）+ アダプティブアイコン（前景/背景）を自動生成する
- マスター画像はClaudeが指示に基づき生成するのではなく、ユーザー提供 or 別途相談（デザイン案を先に確認）
- 生成対象は`android/app/src/main/res/mipmap-*/ic_launcher.png` の置き換え

### 2-3. 署名・リリースビルド設定

- `android/key.properties`（gitignore対象、リポジトリにコミットしない）を新規作成し、keystoreパス・パスワード・エイリアスを記載
- keystore本体（`.jks`）はプロジェクト外 or `android/`直下（gitignore済み）に生成し、**ユーザー自身で安全な場所にもバックアップしてもらう**（紛失すると同じapplicationIdで二度と更新できなくなるため最重要）
- `android/app/build.gradle.kts` に `signingConfigs { release { ... } }` を追加し、`buildTypes.release.signingConfig` を debug から release 用に変更
- keystore生成コマンド（`keytool -genkey -v -keystore ... -keyalg RSA -keysize 2048 -validity 10000 -alias ...`）はClaudeが提示し、実行はユーザーと一緒に対話的に行う（パスワード入力を伴うため）

### 2-4. Play Console・ストア掲載情報

コード変更なし。以下のテキスト資産をMarkdownドラフトとして `.steering/20260711-release-preparation/store-listing-draft.md` に作成する。

- アプリ名（日本語）
- 簡単な説明（80文字以内）
- 詳細な説明（4000文字以内）
- スクリーンショット用の撮影シーン案（実機の各画面をどう撮るか）
- コンテンツレーティング質問票の回答方針（暴力・不適切表現なし、対象年齢制限なしを想定）
- データセーフティフォームの回答方針（写真ライブラリへのアクセス：ユーザーが選択した画像のみ使用、外部送信なし、Hiveによるローカル保存のみ）

### 2-5. プライバシーポリシー

- `docs/privacy-policy.md`（日本語）を作成し、GitHub Pages（`docs/`をPages公開設定、または別リポジトリ）での公開を想定
- 内容：収集する情報（実質なし。写真ライブラリアクセスはローカル処理のみで外部送信なし）、Hiveによる端末内保存のみである旨、問い合わせ先
- 公開URLの確定・実際のPages有効化はユーザー承認のうえで実施

### 2-6. リリース前チェック

- `flutter analyze` 実行
- `flutter build appbundle --release` でAAB生成確認
- 生成したAABから `bundletool` でAPKを抽出し、Windows側AVDにインストールして実機動作確認（既存の [[wsl2_android_emulator_setup]] の接続方法を流用）

---

## 3. データ構造の変更

なし（Hiveのデータモデル・スキーマに変更は発生しない）。

---

## 4. 影響範囲の分析

| 影響先 | 内容 |
|--------|------|
| `docs/repository-structure.md` | keystore/key.propertiesの配置ルールを追記するか要検討（機密ファイルのため記載は最小限に） |
| `docs/architecture.md` | 「フェーズ2以降」の買い切り課金の項目は今回変更なし。署名・ビルド手順は新規追加が望ましいが、頻繁に変わる情報ではないため本ステアリングのみに留め、`docs/`側は更新不要と判断 |
| 既存の実機確認手順（[[wsl2_android_emulator_setup]]） | リリースビルド確認時にも同じ接続方法を使うため変更不要 |
| GitHubリポジトリ | `key.properties` / `*.jks` は絶対にコミットしない（既にgitignore済みを確認済み） |

---

## 5. 未確定事項（次のtasklist.md作成前に確認したいこと）

1. アプリアイコンのデザイン方向性（誰が用意するか：Claudeが簡易案を生成するか、ユーザーが用意するか）
2. プライバシーポリシーの公開先（GitHub Pages / 他）
3. keystore生成のタイミング（対話的にターミナルで一緒に実行する前提でよいか）
