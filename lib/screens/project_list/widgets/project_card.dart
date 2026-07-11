import 'package:flutter/material.dart';
import '../../../models/project.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.sceneCount,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  final Project project;
  final int sceneCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    final date =
        '${project.updatedAt.year}/${project.updatedAt.month}/${project.updatedAt.day}';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('画面数: $sceneCount  |  $date'),
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
