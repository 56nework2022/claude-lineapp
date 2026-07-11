import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import 'hive_providers.dart';

const _uuid = Uuid();

class ProjectNotifier extends StateNotifier<List<Project>> {
  ProjectNotifier(this._box) : super(_box.values.toList()..sort(_byDate));

  final Box<Project> _box;

  static int _byDate(Project a, Project b) =>
      b.createdAt.compareTo(a.createdAt);

  Future<void> create(String name) async {
    final now = DateTime.now();
    final project = Project(
      id: _uuid.v4(),
      name: name.trim(),
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(project.id, project);
    state = [project, ...state];
  }

  Future<void> rename(String id, String name) async {
    final project = _box.get(id);
    if (project == null) return;
    final updated = project.copyWith(name: name.trim(), updatedAt: DateTime.now());
    await _box.put(id, updated);
    state = state.map((p) => p.id == id ? updated : p).toList();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    state = state.where((p) => p.id != id).toList();
  }
}

final projectsProvider =
    StateNotifierProvider<ProjectNotifier, List<Project>>((ref) {
  return ProjectNotifier(ref.watch(projectBoxProvider));
});
