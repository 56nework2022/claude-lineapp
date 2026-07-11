# 開発ガイドライン

> **ステータス:** ドラフト v1.0
> **最終更新:** 2026-06-29

---

## 1. コーディング規約

### 基本方針

- `flutter_lints` + `riverpod_lint` の lint ルールをすべてパスした状態を維持する
- `dart format` によるフォーマットを必ず適用する（手動フォーマット禁止）
- 警告（warning）はエラーと同等に扱い、放置しない

### ファイル構成の順序

各 Dartファイル内の記述順序を統一する。

```dart
// 1. import（dart: → package: → 相対パスの順）
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';

// 2. enum・型エイリアス（そのファイルで定義する場合）

// 3. Provider定義（providers/ ファイルの場合）

// 4. クラス定義
```

### クラス・メソッドの長さ

- 1クラス：原則300行以内。超える場合はファイル分割を検討する
- 1メソッド：原則30行以内。超える場合はプライベートメソッドに切り出す
- `build()` メソッド：原則50行以内。ウィジェットを細かく分割して保つ

### コメント

- コメントは「**なぜそう書いたか**」が非自明な場合のみ記述する
- 「何をしているか」はコード自体で読める状態にする（コードで語る）
- TODO は `// TODO: 内容` 形式で記述し、放置しない

---

## 2. 命名規則

### Dart全般

| 対象 | 規則 | 例 |
|------|------|-----|
| ファイル名 | スネークケース | `project_list_screen.dart` |
| クラス名 | パスカルケース | `ProjectListScreen` |
| 変数・関数名 | キャメルケース | `projectName`, `createProject()` |
| 定数 | キャメルケース（`const`） | `const defaultAvatarSize = 40.0` |
| プライベートメンバ | アンダースコア接頭辞 | `_buildMessageList()` |
| enum 型名 | パスカルケース | `SceneType`, `DeviceType` |
| enum 値 | キャメルケース | `SceneType.chat`, `DeviceType.iphone` |

### Riverpod 固有

| 対象 | 規則 | 例 |
|------|------|-----|
| Provider変数 | キャメルケース + `Provider` | `projectsProvider` |
| Notifier クラス | パスカルケース + `Notifier` | `ProjectNotifier` |
| 選択的プロバイダ（family） | キャメルケース + `Provider` | `scenesByProjectProvider` |

### ウィジェット

| 対象 | 規則 | 例 |
|------|------|-----|
| Screen クラス | パスカルケース + `Screen` | `ProjectListScreen` |
| 共有ウィジェット | パスカルケース + `Widget` | `ChatBubbleWidget` |
| 画面専用ウィジェット | パスカルケース（Widgetなし可） | `ProjectCard`, `MessageForm` |

---

## 3. Flutter / Dart コーディングスタイル

### Widget の分割基準

- `build()` が50行を超えたらウィジェットを切り出す
- 再利用しない小さなウィジェットはファイル末尾の `private` クラスとして定義してよい
- 再利用するウィジェットは `screens/[画面名]/widgets/` または `widgets/` に独立ファイルで定義する

```dart
// 良い例：小さなパーツはプライベートクラスで
class ChatEditorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: _MessageList(),
    );
  }
}

class _MessageList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ...
  }
}
```

### `const` の積極的な活用

コンパイル時定数になり得るウィジェット・値には必ず `const` を付ける。

```dart
// 良い例
const SizedBox(height: 16),
const Text('送信者'),

// 悪い例
SizedBox(height: 16),
Text('送信者'),
```

### Riverpod の使い方

- 画面クラスは `ConsumerWidget` または `ConsumerStatefulWidget` を継承する
- `ref.watch()` は `build()` 内のみで使用する
- `ref.read()` はイベントハンドラ（onPressed等）内でのみ使用する
- `StateNotifier` の状態変更はすべて Notifier のメソッド経由で行う（外部から直接 state を書き換えない）

```dart
// 良い例
onPressed: () => ref.read(projectsProvider.notifier).createProject(name),

// 悪い例
onPressed: () => ref.read(projectsProvider.notifier).state = [...],
```

### 非同期処理

- `async/await` を使用し、`.then()` チェーンは避ける
- エラーハンドリングは `try/catch` で明示的に行う
- `FutureProvider` / `AsyncNotifier` を活用し、ローディング・エラー状態を UI に反映する

---

## 4. スタイリング規約

### テーマ・カラー

- アプリ全体のテーマは `main.dart` の `ThemeData` で一元管理する
- 色・フォントサイズ・余白などをウィジェット内にハードコードしない
- `Theme.of(context)` または定数ファイル（`utils/constants.dart`）を参照する

```dart
// 良い例
color: Theme.of(context).colorScheme.primary,
padding: EdgeInsets.all(AppConstants.defaultPadding),

// 悪い例
color: Color(0xFF06C755),
padding: EdgeInsets.all(16),
```

### フェイク画面のスタイリング（LINE風等）

- フェイク画面専用のスタイル値（吹き出し色・フォント・余白）は `utils/constants.dart` にまとめる
- LINE の公式カラーコード・ロゴ・名称は使用しない。「LINE風」の独自表現にとどめる

### レスポンシブ対応

- フェーズ1はスマートフォン縦向きのみを対象とする
- `MediaQuery.of(context).size` を使って画面幅に応じた調整が必要な場合はそこで取得する
- ハードコードされたピクセル値ではなく、画面幅の割合（`width * 0.8` 等）を使う

---

## 5. テスト規約

### 対象と優先度

| 対象 | 優先度 | 方針 |
|------|--------|------|
| モデルクラス（serialize/deserialize） | 高 | ユニットテストを書く |
| Notifier のビジネスロジック | 高 | ユニットテストを書く |
| 共通ウィジェット（ChatBubbleWidget等） | 中 | ウィジェットテストを書く |
| 各画面 | 低 | フェーズ1では手動確認で可 |

### ファイル・命名規則

- テストファイルは `test/` 以下に本体と同じディレクトリ構造で配置する
- ファイル名は `[対象ファイル名]_test.dart`
- テストクラス・関数名は `test('〇〇の場合、〇〇になる', ...)` 形式で日本語可

```dart
test('プロジェクト名が空の場合、作成できない', () {
  // ...
});
```

### テストの書き方

- Arrange / Act / Assert の3ステップを意識する
- 1つの `test()` で1つのことだけ検証する
- Hive のテストは `hive_test` パッケージを使いインメモリで実行する

---

## 6. Git 規約

### ブランチ戦略

```
main          # リリース可能な状態を常に維持
  └─ feature/[機能名]    # 機能開発
  └─ fix/[修正内容]      # バグ修正
  └─ chore/[作業内容]    # 設定・ドキュメント等
```

ひとり開発のためシンプルに保つ。基本的に `feature/*` から `main` へのマージで運用する。

### コミットメッセージ

**形式：** `[種別] 内容（日本語可）`

| 種別 | 用途 |
|------|------|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `refactor` | 動作を変えないコード改善 |
| `docs` | ドキュメントのみの変更 |
| `chore` | ビルド・設定・パッケージ管理 |
| `test` | テストコードの追加・修正 |
| `style` | コードフォーマットのみ（`dart format`） |

**例：**
```
feat: プロジェクト一覧画面を実装
fix: フルスクリーン表示でステータスバーが残る問題を修正
chore: hive・riverpod パッケージを追加
docs: 機能設計書にデータフロー図を追加
```

### コミットの粒度

- 1コミット＝1つの論理的な変更単位
- 動作しない状態でコミットしない
- `*.g.dart`（自動生成ファイル）はコミットしない

### プッシュ・マージのタイミング

- `main` への直接コミットは設定確認・ドキュメント追加等の軽微な変更のみ
- 機能実装は `feature/*` ブランチで行い、動作確認後に `main` へマージ

---

## 7. 品質チェックリスト（実装後に確認）

実装を完了したら以下を確認してからコミットする。

```
□ dart format でフォーマット済み
□ flutter analyze で警告・エラーなし
□ iOS シミュレータで動作確認済み
□ Android エミュレータで動作確認済み（または実機）
□ フルスクリーン表示でシステムUIが一切表示されないことを確認
□ 透かし（ウォーターマーク）が表示されていないことを確認
□ LINEのロゴ・名称を使っていないことを確認
□ 関連するテストが通ること（該当する場合）
```
