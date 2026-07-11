import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/scene.dart';
import '../models/enums.dart';
import 'hive_providers.dart';

const _uuid = Uuid();

class SceneNotifier extends StateNotifier<List<Scene>> {
  SceneNotifier(this._box, this.projectId)
      : super(
          _box.values
              .where((s) => s.projectId == projectId)
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
        );

  final Box<Scene> _box;
  final String projectId;

  Future<void> create(String name) async {
    final scene = Scene(
      id: _uuid.v4(),
      projectId: projectId,
      name: name.trim(),
      type: SceneType.chat,
      orderIndex: state.length,
      createdAt: DateTime.now(),
    );
    await _box.put(scene.id, scene);
    state = [...state, scene];
  }

  Future<void> rename(String id, String name) async {
    final scene = _box.get(id);
    if (scene == null) return;
    final updated = scene.copyWith(name: name.trim());
    await _box.put(id, updated);
    state = state.map((s) => s.id == id ? updated : s).toList();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    final reindexed = [
      for (int i = 0; i < list.length; i++) list[i].copyWith(orderIndex: i),
    ];
    for (final s in reindexed) {
      await _box.put(s.id, s);
    }
    state = reindexed;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    state = state.where((s) => s.id != id).toList();
  }
}

final scenesProvider = StateNotifierProvider.family<SceneNotifier, List<Scene>,
    String>((ref, projectId) {
  return SceneNotifier(ref.watch(sceneBoxProvider), projectId);
});
