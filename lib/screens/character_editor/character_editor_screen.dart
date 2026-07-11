import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/scene.dart';
import '../../providers/character_provider.dart';
import '../../widgets/character_avatar_widget.dart';
import 'widgets/character_form.dart';

class CharacterEditorScreen extends ConsumerWidget {
  const CharacterEditorScreen({super.key, required this.scene});

  final Scene scene;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(charactersProvider(scene.id));
    final hasSelf = characters.any((c) => c.isSelf);

    return Scaffold(
      appBar: AppBar(title: const Text('登場人物')),
      body: characters.isEmpty
          ? const Center(child: Text('登場人物がいません\n＋ ボタンから追加してください', textAlign: TextAlign.center))
          : ListView.builder(
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return ListTile(
                  leading: CharacterAvatarWidget(character: character),
                  title: Text(character.name),
                  subtitle: Text(character.isSelf ? '自分（送信側）' : '相手'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => CharacterForm(
                            hasSelf: hasSelf,
                            editing: character,
                            onSave: ({required name, required isSelf, iconPath}) =>
                                ref
                                    .read(charactersProvider(scene.id).notifier)
                                    .update(
                                      character.id,
                                      name: name,
                                      isSelf: isSelf,
                                      iconPath: iconPath,
                                    ),
                          ),
                        );
                      } else if (value == 'delete') {
                        _confirmDelete(context, ref, character.id, character.name);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('編集')),
                      PopupMenuItem(value: 'delete', child: Text('削除')),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => CharacterForm(
            hasSelf: hasSelf,
            onSave: ({required name, required isSelf, iconPath}) => ref
                .read(charactersProvider(scene.id).notifier)
                .add(name: name, isSelf: isSelf, iconPath: iconPath),
          ),
        ),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('削除'),
        content: Text('「$name」を削除しますか？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(charactersProvider(scene.id).notifier).delete(id);
    }
  }
}
