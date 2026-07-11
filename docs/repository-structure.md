# リポジトリ構造定義書

> **ステータス:** ドラフト v1.0
> **最終更新:** 2026-06-29

---

## 1. ルート構成

```
claude-lineapp/                        # リポジトリルート
  ├─ android/                          # Android プロジェクト（Flutter生成）
  ├─ ios/                              # iOS プロジェクト（Flutter生成）
  ├─ lib/                              # Dart ソースコード（メイン）
  ├─ test/                             # テストコード
  ├─ assets/                           # 静的アセット
  ├─ docs/                             # 永続的ドキュメント
  ├─ .steering/                        # 作業単位のドキュメント
  ├─ pubspec.yaml                      # パッケージ定義
  ├─ pubspec.lock                      # パッケージロックファイル
  ├─ analysis_options.yaml             # Dartアナライザ設定
  ├─ CLAUDE.md                         # Claude Code 用プロジェクトメモリ
  └─ .gitignore
```

---

## 2. `lib/` ディレクトリ詳細

```
lib/
  ├─ main.dart                         # エントリポイント。Hive初期化・ProviderScope設定
  │
  ├─ models/                           # データモデル（Hive TypeAdapter対応）
  │   ├─ project.dart                  # Project モデル
  │   ├─ project.g.dart                # 自動生成（build_runner）
  │   ├─ scene.dart                    # Scene モデル
  │   ├─ scene.g.dart
  │   ├─ character.dart                # Character モデル
  │   ├─ character.g.dart
  │   ├─ message.dart                  # Message モデル
  │   ├─ message.g.dart
  │   ├─ status_bar_config.dart        # StatusBarConfig モデル
  │   ├─ status_bar_config.g.dart
  │   └─ enums.dart                    # SceneType / DeviceType など共通enum
  │
  ├─ providers/                        # Riverpod プロバイダ・StateNotifier
  │   ├─ hive_providers.dart           # Hive Box を提供するプロバイダ
  │   ├─ project_provider.dart         # ProjectNotifier / projectsProvider
  │   ├─ scene_provider.dart           # SceneNotifier / scenesProvider
  │   ├─ character_provider.dart       # CharacterNotifier / charactersProvider
  │   ├─ message_provider.dart         # MessageNotifier / messagesProvider
  │   ├─ status_bar_provider.dart      # StatusBarNotifier / statusBarProvider
  │   └─ fullscreen_provider.dart      # FullscreenProgressNotifier（進行状態管理）
  │
  ├─ screens/                          # 画面（Screen）
  │   ├─ project_list/
  │   │   ├─ project_list_screen.dart  # S01: プロジェクト一覧
  │   │   └─ widgets/                  # この画面専用ウィジェット
  │   │       └─ project_card.dart
  │   │
  │   ├─ scene_list/
  │   │   ├─ scene_list_screen.dart    # S02: 画面一覧
  │   │   └─ widgets/
  │   │       └─ scene_card.dart
  │   │
  │   ├─ chat_editor/
  │   │   ├─ chat_editor_screen.dart   # S04: LINE風トークエディタ
  │   │   └─ widgets/
  │   │       ├─ message_list.dart
  │   │       └─ message_form.dart
  │   │
  │   ├─ character_editor/
  │   │   ├─ character_editor_screen.dart  # S05: 登場人物エディタ
  │   │   └─ widgets/
  │   │       └─ character_form.dart
  │   │
  │   ├─ status_bar_config/
  │   │   └─ status_bar_config_screen.dart # S06: ステータスバー設定
  │   │
  │   ├─ fullscreen_view/
  │   │   └─ fullscreen_view_screen.dart   # S07: 撮影用フルスクリーン表示
  │   │
  │   └─ lock_screen_preview/
  │       └─ lock_screen_preview_screen.dart # S08: ロック画面/通知プレビュー
  │
  ├─ widgets/                          # 複数画面で共有するウィジェット
  │   ├─ status_bar_widget.dart        # ステータスバー（iPhone/Android切り替え）
  │   ├─ chat_bubble_widget.dart       # 吹き出し（送受信で外観が変わる）
  │   └─ character_avatar_widget.dart  # アイコン画像 or イニシャルアバター
  │
  └─ utils/                            # ユーティリティ
      ├─ image_exporter.dart           # 画像書き出し処理
      └─ constants.dart                # アプリ全体で使う定数
```

---

## 3. `assets/` ディレクトリ

```
assets/
  └─ images/                          # アプリ内静的画像（将来的に必要になった場合）
```

フェーズ1では静的画像アセットは最小限。アイコン画像はユーザーがカメラロールから選択してローカルに保存するため、アセットに含まない。

---

## 4. `test/` ディレクトリ

```
test/
  ├─ models/                          # モデルのユニットテスト
  │   └─ project_test.dart
  ├─ providers/                       # プロバイダのユニットテスト
  │   └─ project_provider_test.dart
  └─ widgets/                         # ウィジェットテスト
      └─ chat_bubble_widget_test.dart
```

フェーズ1では重要なロジック（モデル・プロバイダ）のユニットテストを優先する。

---

## 5. `docs/` ディレクトリ

```
docs/
  ├─ ideas/                           # アイデア段階のドキュメント（参照用）
  │   └─ PRD_撮影用フェイク画面アプリ_1.md
  ├─ product-requirements.md          # プロダクト要求定義書
  ├─ functional-design.md             # 機能設計書
  ├─ architecture.md                  # 技術仕様書
  ├─ repository-structure.md          # 本ドキュメント
  ├─ development-guidelines.md        # 開発ガイドライン
  └─ glossary.md                      # ユビキタス言語定義
```

---

## 6. `.steering/` ディレクトリ

```
.steering/
  └─ 20260629-initial-implementation/ # 初回実装用（作成予定）
      ├─ requirements.md
      ├─ design.md
      └─ tasklist.md
```

作業単位のドキュメント。作業完了後も履歴として保持する。

---

## 7. ファイル配置ルール

### 命名規則

| 対象 | ルール | 例 |
|------|--------|-----|
| Dartファイル | スネークケース | `project_list_screen.dart` |
| クラス名 | パスカルケース | `ProjectListScreen` |
| プロバイダ変数 | キャメルケース + `Provider` | `projectsProvider` |
| Notifier クラス | パスカルケース + `Notifier` | `ProjectNotifier` |
| 自動生成ファイル | 元ファイル名 + `.g.dart` | `project.g.dart` |

### 配置基準

| ファイルの種類 | 配置先 |
|--------------|--------|
| 特定の画面だけで使うウィジェット | `screens/[画面名]/widgets/` |
| 2画面以上で共有するウィジェット | `widgets/` |
| データ取得・変換のロジック | `providers/` |
| 定数・設定値 | `utils/constants.dart` |
| 自動生成ファイル（`.g.dart`） | モデルと同ディレクトリ（コミット対象外）|

### `.gitignore` に含めるもの

```
# Flutter生成物
.dart_tool/
build/
*.g.dart          # build_runner 生成ファイル

# iOS/Android
ios/Pods/
android/.gradle/

# 環境依存
.flutter-plugins
.flutter-plugins-dependencies
```

> **注意:** `*.g.dart` はビルド時に再生成できるためコミットしない。CI環境では `flutter pub run build_runner build` を実行してから `flutter build` する。

---

## 8. `pubspec.yaml` パッケージ構成（予定）

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.x.x
  hive: ^2.x.x
  hive_flutter: ^1.x.x
  uuid: ^4.x.x
  image_picker: ^1.x.x
  screenshot: ^3.x.x
  image_gallery_saver: ^2.x.x
  path_provider: ^2.x.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.x.x
  build_runner: ^2.x.x
  flutter_lints: ^4.x.x
  riverpod_lint: ^2.x.x
  custom_lint: ^0.x.x
```

バージョンは実装開始時に最新安定版を確認して固定する。
