# 初回実装 設計

> **作業ディレクトリ:** `.steering/20260630-initial-implementation/`
> **作成日:** 2026-06-30

---

## 1. 実装アプローチ

### 基本方針

- `docs/architecture.md` に定義したレイヤー構成（models → providers → screens → widgets）の順に下から積み上げる
- 「動くものを早く作る」優先：まず最小限の画面で一通り動かしてから、UI の磨き込みを行う
- `flutter create` でプロジェクト生成後、即座に `pubspec.yaml` を整備してビルドが通る状態を基準点とする

### 実装順序

```
Step 1: プロジェクト基盤
  ├─ flutter create
  ├─ pubspec.yaml（パッケージ追加）
  └─ main.dart（Hive初期化・ProviderScope）

Step 2: データ層
  ├─ models/ （Project・Scene・Character・Message・StatusBarConfig・enums）
  └─ build_runner で TypeAdapter 自動生成

Step 3: 状態管理層
  └─ providers/ （各 Notifier）

Step 4: 画面実装（優先度順）
  S01 → S02 → S04 → S05 → S06 → S07 → S08

Step 5: 共通ウィジェット
  └─ StatusBarWidget・ChatBubbleWidget・CharacterAvatarWidget

Step 6: 画像書き出し
  └─ ImageExporter ユーティリティ

Step 7: 仕上げ
  ├─ iOS/Android 権限設定
  ├─ アニメーション調整
  └─ 動作確認（iOS Simulator / Android Emulator）
```

---

## 2. 作成するファイル一覧

### プロジェクトルート

| ファイル | 内容 |
|---------|------|
| `pubspec.yaml` | 依存パッケージを追加 |
| `analysis_options.yaml` | flutter_lints + riverpod_lint + custom_lint |
| `ios/Runner/Info.plist` | 写真ライブラリ権限の説明文追加 |
| `android/app/src/main/AndroidManifest.xml` | ストレージ権限追加（API ≤ 32） |

### `lib/` 配下

#### models/

| ファイル | 内容 |
|---------|------|
| `enums.dart` | `SceneType`・`DeviceType` |
| `project.dart` | `Project` モデル（HiveObject） |
| `scene.dart` | `Scene` モデル |
| `character.dart` | `Character` モデル |
| `message.dart` | `Message` モデル |
| `status_bar_config.dart` | `StatusBarConfig` モデル |

#### providers/

| ファイル | 内容 |
|---------|------|
| `hive_providers.dart` | 各 Hive Box を提供するプロバイダ |
| `project_provider.dart` | `ProjectNotifier`・`projectsProvider` |
| `scene_provider.dart` | `SceneNotifier`・`scenesProvider(projectId)` |
| `character_provider.dart` | `CharacterNotifier`・`charactersProvider(sceneId)` |
| `message_provider.dart` | `MessageNotifier`・`messagesProvider(sceneId)` |
| `status_bar_provider.dart` | `StatusBarNotifier`・`statusBarProvider(sceneId)` |
| `fullscreen_provider.dart` | `FullscreenProgressNotifier`（表示済みメッセージ数管理） |

#### screens/

| ファイル | 内容 |
|---------|------|
| `project_list/project_list_screen.dart` | S01 |
| `project_list/widgets/project_card.dart` | プロジェクトカード |
| `scene_list/scene_list_screen.dart` | S02 |
| `scene_list/widgets/scene_card.dart` | シーンカード |
| `chat_editor/chat_editor_screen.dart` | S04 |
| `chat_editor/widgets/message_list.dart` | メッセージ一覧（ドラッグ並び替え対応） |
| `chat_editor/widgets/message_form.dart` | メッセージ追加・編集フォーム |
| `character_editor/character_editor_screen.dart` | S05 |
| `character_editor/widgets/character_form.dart` | 登場人物追加・編集フォーム |
| `status_bar_config/status_bar_config_screen.dart` | S06 |
| `fullscreen_view/fullscreen_view_screen.dart` | S07 |
| `lock_screen_preview/lock_screen_preview_screen.dart` | S08 |

#### widgets/（共通）

| ファイル | 内容 |
|---------|------|
| `widgets/status_bar_widget.dart` | iPhone/Android 切り替えステータスバー |
| `widgets/chat_bubble_widget.dart` | 送信/受信 吹き出し |
| `widgets/character_avatar_widget.dart` | 画像 or イニシャルアバター |

#### utils/

| ファイル | 内容 |
|---------|------|
| `utils/image_exporter.dart` | RepaintBoundary → PNG → カメラロール保存 |
| `utils/constants.dart` | アバターカラーリスト・デフォルト値など |

---

## 3. データ構造詳細

`docs/functional-design.md` のER図をそのまま実装する。変更なし。

### Hive typeId 割り当て

| モデル | typeId | フィールド数 |
|--------|--------|------------|
| Project | 0 | 4（id / name / createdAt / updatedAt） |
| Scene | 1 | 6（id / projectId / name / type / orderIndex / createdAt） |
| Character | 2 | 5（id / sceneId / name / iconPath / isSelf / orderIndex） |
| Message | 3 | 7（id / sceneId / characterId / text / displayTime / isRead / orderIndex） |
| StatusBarConfig | 4 | 7（sceneId / customTime / useCurrentTime / signalStrength / batteryLevel / isCharging / deviceType） |
| SceneType | 5 | enum |
| DeviceType | 6 | enum |

---

## 4. 各画面の実装詳細

### S01：プロジェクト一覧

- `projectsProvider` を watch してカード一覧を表示
- FAB でプロジェクト名入力ダイアログ → `ProjectNotifier.create(name)`
- カードを長押し or スワイプで削除確認ダイアログ → `ProjectNotifier.delete(id)`
- タップで S02 へ `go_router` または `Navigator.push`（初期実装は Navigator で十分）

### S02：画面（Scene）一覧

- `scenesProvider(projectId)` を watch してカード一覧表示
- FAB でシーン名入力ダイアログ → `SceneNotifier.create(projectId, name, SceneType.chat)`
  - フェーズ1は種類選択ダイアログを省略し、直接 `chat` 固定で作成する
- 長押しメニューで名前変更・削除
- タップで S04 へ遷移

### S04：LINE風トークエディタ

- 上部：`StatusBarWidget`（プレビュー用、実際の画面サイズに収まるよう縮小表示でも可）
- 中部：`ListView` でメッセージ一覧（`ChatBubbleWidget` を並べる）
  - `ReorderableListView` でドラッグ並び替えに対応
- 下部：メッセージ追加ボタン → `MessageForm` のボトムシート（`showModalBottomSheet`）
- AppBar アクション：
  - 登場人物設定（→ S05）
  - ステータスバー設定（→ S06）
  - 通知プレビュー（→ S08）
  - フルスクリーン（→ S07）
  - 画像書き出し（`ImageExporter.export()`）

### S05：登場人物エディタ

- `charactersProvider(sceneId)` を watch してリスト表示
- 追加ボタン → `CharacterForm`（名前・アイコン・isSelf フラグ）
- `isSelf=true` のキャラクターがすでに存在する場合、追加フォームでは isSelf チェックを無効化
- アイコン選択：`image_picker` でギャラリーから選択 → `getApplicationDocumentsDirectory()` にコピー保存 → `iconPath` に保存

### S06：ステータスバー設定

- `statusBarProvider(sceneId)` を watch して現在値を表示
- 設定変更のたびに `StatusBarNotifier.update()` で即時保存
- 画面上部に `StatusBarWidget` でリアルタイムプレビュー表示

### S07：フルスクリーン表示

```
画面遷移時:
  1. SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)
  2. fullscreenProgressProvider をリセット（表示済み数 = 0）

表示構造:
  Stack
    ├─ 背景（白 or LINE風グレー）
    ├─ StatusBarWidget（最上部）
    ├─ AnimatedList（メッセージ）← 表示済み分のみ
    └─ GestureDetector（画面全体を覆う）
         ├─ onTap → FullscreenProgressNotifier.advance()
         └─ onLongPress → 戻る処理

戻る処理:
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)
  Navigator.pop()
```

**メッセージ表示アニメーション：**
- `AnimatedList` に新しいアイテムを `insertItem` で追加
- スライドイン（`SlideTransition`）+ フェードイン（`FadeTransition`）を組み合わせ
- duration: 300ms

### S08：ロック画面/通知プレビュー

- `messagesProvider(sceneId)` の先頭メッセージを通知に表示
- `devieType` に応じて iPhone風 or Android風の背景・ロック画面UIを描画
- 「撮影開始」ボタンで S07 へ
- フルスクリーンモードは S07 への遷移時のみ適用（S08 自体はエディタモード）

---

## 5. 共通ウィジェット設計

### `StatusBarWidget`

```dart
StatusBarWidget({
  required StatusBarConfig config,
  // useCurrentTime=true の場合、Timer.periodic で1分ごとに再描画
})
```

- iPhone風：左=時刻（bold）、右=電波バー + WiFiアイコン + 電池アイコン
- Android風：左=時刻、右=電波バー + 電池アイコン
- `config.useCurrentTime == true` のとき `DateTime.now()` を表示し、`Timer.periodic` で更新

### `ChatBubbleWidget`

```dart
ChatBubbleWidget({
  required Message message,
  required Character character,
  bool showAvatar = true,   // 連続する同一人物の2件目以降は非表示
  bool showTime = true,
})
```

- `character.isSelf == true`：右寄せ・緑背景（`#06C755` 風）
- `character.isSelf == false`：左寄せ・白背景 + `CharacterAvatarWidget`
- 既読マーク：`message.isRead == true && character.isSelf == true` のとき「既読」テキストを右下に表示

### `CharacterAvatarWidget`

```dart
CharacterAvatarWidget({
  required Character character,
  double size = 36,
})
```

- `character.iconPath != null`：`File(iconPath)` を `CircleAvatar` で円形表示
- `character.iconPath == null`：名前の1文字目 + `constants.dart` のカラーリストから `hashCode` で色選択

---

## 6. 画像書き出し設計

```dart
class ImageExporter {
  static Future<void> export(GlobalKey repaintBoundaryKey) async {
    // 1. 権限確認（iOS: photo library add、Android: write external storage ≤ API28）
    // 2. RenderRepaintBoundary.toImage(pixelRatio: 3.0)
    // 3. ByteData → Uint8List（PNG）
    // 4. ImageGallerySaver.saveImage()
    // 5. 成功/失敗をSnackBarで通知
  }
}
```

`RepaintBoundary` は S07（フルスクリーン表示）の最外ウィジェットに設置する。S04 のエディタプレビューからも書き出せるよう、`ChatEditorScreen` にも設置する。

---

## 7. ルーティング

初期実装では `go_router` を導入せず、`Navigator.push` / `Navigator.pop` で実装する。
ネスト遷移が複雑になるフェーズ2で `go_router` への移行を検討。

```
ProjectListScreen
  └─ Navigator.push → SceneListScreen(projectId)
      └─ Navigator.push → ChatEditorScreen(sceneId)
          ├─ Navigator.push → CharacterEditorScreen(sceneId)
          ├─ Navigator.push → StatusBarConfigScreen(sceneId)
          ├─ Navigator.push → LockScreenPreviewScreen(sceneId)
          └─ Navigator.push → FullscreenViewScreen(sceneId)
```

---

## 8. 影響範囲

初回実装のため既存コードへの影響はなし。
`flutter create` から新規作成するため、生成される `lib/main.dart` と `test/widget_test.dart` の初期内容は上書きする。

---

## 9. 未解決事項・リスク

| 項目 | 内容 | 対応方針 |
|------|------|---------|
| `image_gallery_saver` のメンテナンス状況 | 最終更新が古い可能性がある | pub.dev で確認し、必要なら `gal` パッケージを代替として検討 |
| Android 権限（API 33+） | `WRITE_EXTERNAL_STORAGE` が廃止 | `image_gallery_saver` or `gal` パッケージが内部で処理していることを確認する |
| `screenshot` パッケージの信頼性 | フルスクリーン表示中の精度 | `RepaintBoundary` + `toImage` の直接実装も選択肢として用意 |
| iOS Simulator でのカメラロール保存テスト | シミュレータでは写真アプリへの保存が可能 | 実機でも動作確認を要す |
