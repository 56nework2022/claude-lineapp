import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/character.dart';
import 'hive_providers.dart';

const _uuid = Uuid();

class CharacterNotifier extends StateNotifier<List<Character>> {
  CharacterNotifier(this._box, this.sceneId)
      : super(
          _box.values
              .where((c) => c.sceneId == sceneId)
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
        );

  final Box<Character> _box;
  final String sceneId;

  Future<void> add({
    required String name,
    required bool isSelf,
    String? iconPath,
  }) async {
    final character = Character(
      id: _uuid.v4(),
      sceneId: sceneId,
      name: name.trim(),
      isSelf: isSelf,
      orderIndex: state.length,
      iconPath: iconPath,
    );
    await _box.put(character.id, character);
    state = [...state, character];
  }

  Future<void> update(
    String id, {
    String? name,
    bool? isSelf,
    String? iconPath,
    bool clearIcon = false,
  }) async {
    final character = _box.get(id);
    if (character == null) return;
    final updated = character.copyWith(
      name: name,
      isSelf: isSelf,
      iconPath: iconPath,
      clearIcon: clearIcon,
    );
    await _box.put(id, updated);
    state = state.map((c) => c.id == id ? updated : c).toList();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    state = state.where((c) => c.id != id).toList();
  }
}

final charactersProvider = StateNotifierProvider.family<CharacterNotifier,
    List<Character>, String>((ref, sceneId) {
  return CharacterNotifier(ref.watch(characterBoxProvider), sceneId);
});
