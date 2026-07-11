import 'package:flutter/material.dart';
import '../../../models/character.dart';
import '../../../models/message.dart';
import '../../../widgets/chat_bubble_widget.dart';

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messages,
    required this.characters,
    required this.onReorder,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Message> messages;
  final List<Character> characters;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(Message message) onEdit;
  final void Function(String id) onDelete;

  Character? _findCharacter(String id) {
    try {
      return characters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text('メッセージがありません\n＋ ボタンから追加してください', textAlign: TextAlign.center),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final message = messages[index];
        final character = _findCharacter(message.characterId);
        if (character == null) return const SizedBox.shrink(key: ValueKey('unknown'));

        final prevSame = index > 0 &&
            messages[index - 1].characterId == message.characterId;

        return GestureDetector(
          key: ValueKey(message.id),
          onLongPress: () => _showActions(context, message),
          child: ChatBubbleWidget(
            message: message,
            character: character,
            showAvatar: !prevSame,
          ),
        );
      },
    );
  }

  void _showActions(BuildContext context, Message message) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('編集'),
              onTap: () {
                Navigator.pop(context);
                onEdit(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('削除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete(message.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
