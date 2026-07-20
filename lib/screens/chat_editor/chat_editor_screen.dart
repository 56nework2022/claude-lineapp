import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/scene.dart';
import '../../providers/message_provider.dart';
import '../../providers/character_provider.dart';
import '../../providers/status_bar_provider.dart';
import '../../utils/image_exporter.dart';
import '../../widgets/status_bar_widget.dart';
import '../character_editor/character_editor_screen.dart';
import '../status_bar_config/status_bar_config_screen.dart';
import '../fullscreen_view/fullscreen_view_screen.dart';
import '../lock_screen_preview/lock_screen_preview_screen.dart';
import 'widgets/message_form.dart';
import 'widgets/message_list.dart';

class ChatEditorScreen extends ConsumerStatefulWidget {
  const ChatEditorScreen({super.key, required this.scene});

  final Scene scene;

  @override
  ConsumerState<ChatEditorScreen> createState() => _ChatEditorScreenState();
}

class _ChatEditorScreenState extends ConsumerState<ChatEditorScreen> {
  final _screenshotKey = GlobalKey();
  bool _reorderMode = false;

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    final messages = ref.watch(messagesProvider(scene.id));
    final characters = ref.watch(charactersProvider(scene.id));
    final statusBar = ref.watch(statusBarProvider(scene.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(scene.name),
        actions: [
          IconButton(
            icon: Icon(_reorderMode ? Icons.check : Icons.swap_vert),
            tooltip: _reorderMode ? '並び替え完了' : '並び替え',
            onPressed: () => setState(() => _reorderMode = !_reorderMode),
          ),
          if (!_reorderMode) ...[
            IconButton(
              icon: const Icon(Icons.people_outline),
              tooltip: '登場人物',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CharacterEditorScreen(scene: scene),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.signal_cellular_alt),
              tooltip: 'ステータスバー設定',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StatusBarConfigScreen(scene: scene),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.fullscreen),
              tooltip: 'フルスクリーン撮影',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullscreenViewScreen(scene: scene),
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'lock') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LockScreenPreviewScreen(scene: scene),
                    ),
                  );
                } else if (value == 'export') {
                  ImageExporter.export(_screenshotKey, context);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'lock', child: Text('通知プレビュー')),
                PopupMenuItem(value: 'export', child: Text('画像を書き出す')),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          StatusBarWidget(config: statusBar),
          Expanded(
            child: RepaintBoundary(
              key: _screenshotKey,
              child: Container(
                color: const Color(0xFFEFF3F4),
                child: MessageList(
                  messages: messages,
                  characters: characters,
                  reorderMode: _reorderMode,
                  onReorder: (oldIndex, newIndex) => ref
                      .read(messagesProvider(scene.id).notifier)
                      .reorder(oldIndex, newIndex),
                  onEdit: (message) => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => MessageForm(
                      characters: characters,
                      editing: message,
                      onSave:
                          ({
                            required characterId,
                            required text,
                            required displayTime,
                            required isRead,
                          }) => ref
                              .read(messagesProvider(scene.id).notifier)
                              .update(
                                message.id,
                                characterId: characterId,
                                text: text,
                                displayTime: displayTime,
                                isRead: isRead,
                              ),
                    ),
                  ),
                  onDelete: (id) =>
                      ref.read(messagesProvider(scene.id).notifier).delete(id),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _reorderMode
          ? null
          : FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => MessageForm(
                  characters: characters,
                  onSave:
                      ({
                        required characterId,
                        required text,
                        required displayTime,
                        required isRead,
                      }) => ref
                          .read(messagesProvider(scene.id).notifier)
                          .add(
                            characterId: characterId,
                            text: text,
                            displayTime: displayTime,
                            isRead: isRead,
                          ),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('メッセージ追加'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
