# 初回実装 タスクリスト

> **作業ディレクトリ:** `.steering/20260630-initial-implementation/`
> **作成日:** 2026-06-30

進捗凡例: `[ ]` 未着手 / `[x]` 完了

---

## Phase 1: プロジェクト基盤

- [x] **1-1.** `flutter create` でプロジェクト生成（パッケージ名: `com.example.fake_screen_maker` 等）
- [x] **1-2.** `pubspec.yaml` にパッケージを追加し `flutter pub get` が通ることを確認

  ```
  flutter_riverpod, hive, hive_flutter, uuid,
  image_picker, screenshot, image_gallery_saver, path_provider
  ```

- [x] **1-3.** `dev_dependencies` に追加し lint・コード生成が動くことを確認

  ```
  hive_generator, build_runner, flutter_lints, riverpod_lint, custom_lint
  ```

- [x] **1-4.** `analysis_options.yaml` を整備（`flutter_lints` + `custom_lint` 有効化）
- [x] **1-5.** `main.dart` を整備（Hive 初期化・`ProviderScope` ラップ・アプリテーマ設定）

---

## Phase 2: データ層（models/）

- [ ] **2-1.** `lib/models/enums.dart` を作成（`SceneType`・`DeviceType`）
- [ ] **2-2.** `lib/models/project.dart` を作成（`HiveObject`・`@HiveType(typeId: 0)`）
- [ ] **2-3.** `lib/models/scene.dart` を作成（`@HiveType(typeId: 1)`）
- [ ] **2-4.** `lib/models/character.dart` を作成（`@HiveType(typeId: 2)`）
- [ ] **2-5.** `lib/models/message.dart` を作成（`@HiveType(typeId: 3)`）
- [ ] **2-6.** `lib/models/status_bar_config.dart` を作成（`@HiveType(typeId: 4)`）
- [x] **2-7.** TypeAdapter は手書きで実装（hive_generator と custom_lint のバージョン競合のため build_runner 不使用）

- [x] **2-8.** `main.dart` で全 TypeAdapter を登録し、全 Box を開く処理を実装

---

## Phase 3: 状態管理層（providers/）

- [x] **3-1.** `lib/providers/hive_providers.dart` を作成（Box を提供する `Provider`）
- [x] **3-2.** `lib/providers/project_provider.dart` を作成
  - `ProjectNotifier extends StateNotifier<List<Project>>`
  - 操作: `create(name)` / `delete(id)` / `rename(id, name)`
- [x] **3-3.** `lib/providers/scene_provider.dart` を作成
  - `SceneNotifier` — `projectId` でフィルタ
  - 操作: `create(projectId, name)` / `delete(id)` / `rename(id, name)` / `reorder(oldIndex, newIndex)`
- [x] **3-4.** `lib/providers/character_provider.dart` を作成
  - `CharacterNotifier` — `sceneId` でフィルタ
  - 操作: `add(...)` / `update(...)` / `delete(id)`
- [x] **3-5.** `lib/providers/message_provider.dart` を作成
  - `MessageNotifier` — `sceneId` でフィルタ
  - 操作: `add(...)` / `update(...)` / `delete(id)` / `reorder(oldIndex, newIndex)`
- [x] **3-6.** `lib/providers/status_bar_provider.dart` を作成
  - `StatusBarNotifier` — sceneId に対応する設定を1件管理
  - 操作: `update(...)` / `init(sceneId)`（Sceneを新規作成したときにデフォルト値で初期化）
- [x] **3-7.** `lib/providers/fullscreen_provider.dart` を作成
  - `FullscreenProgressNotifier extends StateNotifier<int>`（表示済みメッセージ数）
  - 操作: `reset()` / `advance(maxIndex)`

---

## Phase 4: 共通ウィジェット（widgets/）

- [x] **4-1.** `lib/utils/constants.dart` を作成（アバターカラーリスト・デフォルト値）
- [x] **4-2.** `lib/widgets/character_avatar_widget.dart` を作成
  - `iconPath` があれば画像を円形表示、なければイニシャル＋カラー背景
- [x] **4-3.** `lib/widgets/chat_bubble_widget.dart` を作成
  - isSelf に応じて右寄せ緑 / 左寄せ白を切り替え
  - 既読表示・時刻表示を実装
- [x] **4-4.** `lib/widgets/status_bar_widget.dart` を作成
  - iPhone風 / Android風の切り替え
  - `useCurrentTime == true` のとき `Timer.periodic` で1分ごとに更新

---

## Phase 5: 画面実装

### S01：プロジェクト一覧

- [x] **5-1.** `lib/screens/project_list/widgets/project_card.dart` を作成
- [x] **5-2.** `lib/screens/project_list/project_list_screen.dart` を作成
  - プロジェクト一覧表示・新規作成ダイアログ・削除（スワイプ or 長押し）
  - タップで S02 へ遷移

### S02：画面（Scene）一覧

- [x] **5-3.** `lib/screens/scene_list/widgets/scene_card.dart` を作成
- [x] **5-4.** `lib/screens/scene_list/scene_list_screen.dart` を作成
  - Scene 一覧表示・新規作成ダイアログ・削除・名前変更
  - タップで S04 へ遷移

### S04：LINE風トークエディタ

- [x] **5-5.** `lib/screens/chat_editor/widgets/message_form.dart` を作成
  - 送信者選択・本文入力・時刻入力・既読トグルのフォーム
  - 追加モードと編集モードを切り替え
- [x] **5-6.** `lib/screens/chat_editor/widgets/message_list.dart` を作成
  - `ReorderableListView` で `ChatBubbleWidget` を並べる
  - 各アイテムに編集・削除アクション
- [x] **5-7.** `lib/screens/chat_editor/chat_editor_screen.dart` を作成
  - `StatusBarWidget` プレビュー・`MessageList`・メッセージ追加 FAB
  - AppBar アクション（登場人物・ステータスバー・通知プレビュー・フルスクリーン・書き出し）
  - `RepaintBoundary` を設置して画像書き出しに対応

### S05：登場人物エディタ

- [x] **5-8.** `lib/screens/character_editor/widgets/character_form.dart` を作成
  - 名前入力・アイコン選択（`image_picker`）・isSelf トグル
- [x] **5-9.** `lib/screens/character_editor/character_editor_screen.dart` を作成
  - 登場人物一覧・追加・編集・削除

### S06：ステータスバー設定

- [x] **5-10.** `lib/screens/status_bar_config/status_bar_config_screen.dart` を作成
  - 時刻（テキスト入力 / 現在時刻トグル）・電波・電池・充電・デバイス種別
  - 上部にリアルタイムプレビューとして `StatusBarWidget` を表示

### S07：フルスクリーン表示

- [x] **5-11.** `lib/screens/fullscreen_view/fullscreen_view_screen.dart` を作成
  - 画面遷移時に `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)`
  - `FullscreenProgressNotifier.reset()` で進行状態をリセット
  - `AnimatedList` でメッセージを1件ずつ `SlideTransition` + `FadeTransition` で表示
  - 画面タップで `advance()`・長押しで戻る処理
  - 戻る際に `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`
  - `RepaintBoundary` を設置して画像書き出しに対応

### S08：ロック画面/通知プレビュー

- [x] **5-12.** `lib/screens/lock_screen_preview/lock_screen_preview_screen.dart` を作成
  - iPhone風 / Android風のロック画面背景
  - 先頭メッセージを通知バナー形式で表示
  - 「撮影開始」ボタンで S07 へ遷移

---

## Phase 6: 画像書き出し

- [x] **6-1.** `lib/utils/image_exporter.dart` を作成
  - `RepaintBoundary.toImage(pixelRatio: 3.0)` → PNG → `Gal.putImageBytes()`
  - 権限チェックを先行して実行
  - 成功・失敗を `ScaffoldMessenger` の SnackBar で通知
- [x] **6-2.** `image_gallery_saver` → `gal` パッケージに差し替え（Android API 33+ 対応）

---

## Phase 7: ネイティブ権限設定

- [x] **7-1.** `ios/Runner/Info.plist` に追加
  - `NSPhotoLibraryAddUsageDescription`（画像書き出し）
  - `NSPhotoLibraryUsageDescription`（アイコン選択）
- [x] **7-2.** `android/app/src/main/AndroidManifest.xml` に追加
  - `READ_EXTERNAL_STORAGE`（API ≤ 32）
  - `WRITE_EXTERNAL_STORAGE`（API ≤ 28）

---

## Phase 8: 動作確認・仕上げ

- [ ] **8-1.** iOS Simulator で全画面を一通り操作して動作確認（要macOS実機環境）
- [ ] **8-2.** Android Emulator で全画面を一通り操作して動作確認（要実機環境）
- [x] **8-3.** フルスクリーン表示でシステムUIが完全に隠れることを確認（コードレビューで確認：`SystemUiMode.immersiveSticky`）
- [x] **8-4.** タップによるメッセージ進行アニメーションを確認（コードレビューで確認：`AnimatedList` + `SlideTransition` + `FadeTransition`）
- [x] **8-5.** 画像書き出しでカメラロールに PNG が保存されることを確認（コードレビューで確認：`Gal.putImageBytes()` + 権限チェック）
- [x] **8-6.** データの永続化確認（コードレビューで確認：Hive全Box登録済み・全CRUD操作でput/delete）
- [x] **8-7.** `flutter analyze` でエラー・警告がないことを確認（No issues found）
- [x] **8-8.** 受け入れ条件（`requirements.md` §4）をすべてチェック（コードレビューで全項目確認済み）

---

## 完了条件

- [x] 受け入れ条件8項目がすべて ✅（コードレビューで確認済み、実機確認は8-1・8-2で）
- [x] `flutter analyze` がクリーン
- [ ] iOS Simulator / Android Emulator の両方で動作確認済み（要実機環境）
