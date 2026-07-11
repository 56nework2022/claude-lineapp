# 技術仕様書

> **ステータス:** ドラフト v1.0
> **最終更新:** 2026-06-29

---

## 1. テクノロジースタック

### コア

| 区分 | 技術 | バージョン | 選定理由 |
|------|------|-----------|---------|
| フレームワーク | Flutter | 最新安定版 | iOS/Android 両対応を単一コードベースで実現。UI描画の自由度が高く、フルスクリーン制御も容易 |
| 言語 | Dart | Flutter同梱 | Flutter の標準言語 |

### 主要パッケージ

| パッケージ | 用途 | 選定理由 |
|-----------|------|---------|
| `flutter_riverpod` | 状態管理 | テスタビリティが高く、コード生成との相性が良い。ひとり開発でも見通しを保ちやすい |
| `hive` / `hive_flutter` | ローカルデータ保存 | スキーマレスで軽量。Flutterとの相性が良く、オフライン専用アプリに適している |
| `hive_generator` / `build_runner` | Hiveアダプタの自動生成 | モデルクラスからアダプタを自動生成し、ボイラープレートを削減 |
| `screenshot` | 画面のウィジェットをPNG画像として取得 | ウィジェットツリーを画像化する標準的なアプローチ |
| `image_gallery_saver` | 画像をカメラロールに保存 | iOS/Android 両対応の保存処理を抽象化 |
| `image_picker` | カメラロールから画像を選択 | 登場人物アイコンの設定に使用 |
| `uuid` | ID生成 | Project / Scene / Character / Message の一意なIDを生成 |
| `path_provider` | ローカルファイルパスの取得 | アイコン画像のローカル保存先パスに使用 |

### 開発補助

| パッケージ | 用途 |
|-----------|------|
| `flutter_lints` | コード品質チェック |
| `riverpod_lint` | Riverpod 固有のlintルール |
| `custom_lint` | riverpod_lint の実行基盤 |

---

## 2. アプリケーション構成

### レイヤー構成

```
lib/
  ├─ main.dart                    # エントリポイント
  │
  ├─ models/                      # データモデル（Hive対応）
  │   ├─ project.dart
  │   ├─ scene.dart
  │   ├─ character.dart
  │   ├─ message.dart
  │   └─ status_bar_config.dart
  │
  ├─ providers/                   # Riverpod プロバイダ
  │   ├─ project_provider.dart
  │   ├─ scene_provider.dart
  │   └─ ...
  │
  ├─ screens/                     # 画面
  │   ├─ project_list/
  │   ├─ scene_list/
  │   ├─ chat_editor/
  │   ├─ character_editor/
  │   ├─ status_bar_config/
  │   ├─ fullscreen_view/
  │   └─ lock_screen_preview/
  │
  ├─ widgets/                     # 共通ウィジェット
  │   ├─ status_bar_widget.dart
  │   ├─ chat_bubble_widget.dart
  │   └─ character_avatar_widget.dart
  │
  └─ utils/                       # ユーティリティ
      ├─ image_exporter.dart
      └─ constants.dart
```

---

## 3. 状態管理設計

Riverpod の `StateNotifier` + `AsyncNotifier` パターンを採用。

```
ProjectNotifier (StateNotifier<List<Project>>)
  └─ Hive Box<Project> を参照
  └─ 操作: create / delete / rename

SceneNotifier (StateNotifier<List<Scene>>)
  └─ Hive Box<Scene> を参照（projectId でフィルタ）
  └─ 操作: create / delete / rename / reorder

MessageNotifier (StateNotifier<List<Message>>)
  └─ Hive Box<Message> を参照（sceneId でフィルタ）
  └─ 操作: add / edit / delete / reorder

FullscreenProgressNotifier (StateNotifier<int>)
  └─ フルスクリーン表示中に「何番目のメッセージまで表示済みか」を管理
  └─ タップごとにインクリメント
```

---

## 4. データ永続化設計

### Hive ボックス構成

```
hive_boxes/
  ├─ projects        # Box<Project>
  ├─ scenes          # Box<Scene>
  ├─ characters      # Box<Character>
  ├─ messages        # Box<Message>
  └─ status_configs  # Box<StatusBarConfig>
```

### TypeAdapter 割り当て

| モデル | typeId |
|--------|--------|
| Project | 0 |
| Scene | 1 |
| Character | 2 |
| Message | 3 |
| StatusBarConfig | 4 |
| SceneType | 5 |
| DeviceType | 6 |

### ファイル保存（アイコン画像）

- 登場人物アイコンはカメラロールから選択後、アプリのドキュメントディレクトリにコピーして保存
- `path_provider` の `getApplicationDocumentsDirectory()` を使用
- `Character.iconPath` にローカルパスを保存

---

## 5. フルスクリーン制御

撮影本番中、OS のシステムUIを完全に排除する。

```dart
// フルスクリーン表示に入るとき
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

// エディタに戻るとき
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
```

- `immersiveSticky`: ステータスバー・ナビゲーションバーを完全に非表示。端からスワイプで一時表示されるがすぐに消える
- アプリ側でステータスバー領域を描画することで、撮影映像に本物のステータスバーが映る

---

## 6. 画像書き出し設計

```
FullscreenView（ウィジェットツリー）
  └─ RepaintBoundary（key: _screenshotKey）
      └─ 撮影画面全体（ステータスバー含む）

書き出し処理:
  1. _screenshotKey.currentContext から RenderRepaintBoundary を取得
  2. toImage(pixelRatio: 3.0) で高解像度PNG化
  3. image_gallery_saver でカメラロールに保存
  4. 権限が未取得の場合はパーミッションリクエストを先行して実行
```

---

## 7. デバイス対応

### iOS / Android 表示切り替え

`StatusBarConfig.deviceType` に応じて `StatusBarWidget` が内部的に表示を切り替える。

```
iPhone風:
  - 時刻: 左上（Dynamic Island / ノッチを考慮したパディング）
  - 右上: 電波・WiFi・電池（塗りつぶし型アイコン）

Android風:
  - 時刻: 左上
  - 右上: 電波・電池（アウトライン型アイコン）
```

フェーズ1では代表的な1パターンずつ実装し、フェーズ2以降で機種別の細かい作り分けに対応する。

---

## 8. パフォーマンス要件

| 項目 | 目標 |
|------|------|
| アプリ起動時間 | コールドスタートで3秒以内 |
| フルスクリーン切り替え | タップから表示まで体感上の遅延なし（< 100ms） |
| メッセージ進行アニメーション | 60fps を維持 |
| 画像書き出し | 3秒以内に完了（通常の画面サイズで） |
| データ保存 | 操作後即時（Hive の同期書き込み） |

---

## 9. 権限要件

| 権限 | 用途 | タイミング |
|------|------|-----------|
| `NSPhotoLibraryAddUsageDescription`（iOS） | 画像書き出しでカメラロールへ保存 | 初回書き出し時にリクエスト |
| `NSPhotoLibraryUsageDescription`（iOS） | アイコン画像の選択 | 初回アイコン設定時にリクエスト |
| `READ_EXTERNAL_STORAGE`（Android API ≤ 32） | アイコン画像の選択 | 初回アイコン設定時にリクエスト |
| `WRITE_EXTERNAL_STORAGE`（Android API ≤ 28） | 画像書き出し | 初回書き出し時にリクエスト |

権限はユーザーが実際にその機能を使うタイミングで初めてリクエストする（起動時にまとめてリクエストしない）。

---

## 10. 技術的制約

- **クラウド不使用:** データは端末ローカルのみ。バックアップ・同期機能は提供しない（フェーズ1）
- **ネットワーク不使用:** オフライン完結。インターネット接続は不要
- **アカウント不要:** 認証処理は実装しない
- **最低対応OSバージョン:** TBD（Flutter の最新安定版がサポートする範囲に準拠）
- **買い切り課金:** フェーズ2以降で `in_app_purchase` パッケージを導入予定。フェーズ1は課金処理なし

---

## 11. 開発環境

| ツール | 用途 |
|--------|------|
| Flutter SDK（最新安定版） | ビルド・実行 |
| Dart SDK | Flutter同梱 |
| VS Code / Android Studio | IDE |
| Claude Code | コーディング支援 |
| iOS Simulator / Android Emulator | 動作確認 |
| Xcode（macOS必須） | iOSビルド・実機テスト |
| Android Studio SDK Manager | Androidビルド |
