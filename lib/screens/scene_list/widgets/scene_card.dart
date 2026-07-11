import 'package:flutter/material.dart';
import '../../../models/scene.dart';

class SceneCard extends StatelessWidget {
  const SceneCard({
    super.key,
    required this.scene,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  final Scene scene;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.chat_bubble_outline),
        title: Text(scene.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('LINE風トーク'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'rename') onRename();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'rename', child: Text('名前を変更')),
            PopupMenuItem(value: 'delete', child: Text('削除')),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
