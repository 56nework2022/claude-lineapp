import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import 'hive_providers.dart';

const _uuid = Uuid();

class MessageNotifier extends StateNotifier<List<Message>> {
  MessageNotifier(this._box, this.sceneId)
      : super(
          _box.values
              .where((m) => m.sceneId == sceneId)
              .toList()
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex)),
        );

  final Box<Message> _box;
  final String sceneId;

  Future<void> add({
    required String characterId,
    required String text,
    required String displayTime,
    required bool isRead,
  }) async {
    final message = Message(
      id: _uuid.v4(),
      sceneId: sceneId,
      characterId: characterId,
      text: text.trim(),
      displayTime: displayTime,
      isRead: isRead,
      orderIndex: state.length,
    );
    await _box.put(message.id, message);
    state = [...state, message];
  }

  Future<void> update(
    String id, {
    String? characterId,
    String? text,
    String? displayTime,
    bool? isRead,
  }) async {
    final message = _box.get(id);
    if (message == null) return;
    final updated = message.copyWith(
      characterId: characterId,
      text: text?.trim(),
      displayTime: displayTime,
      isRead: isRead,
    );
    await _box.put(id, updated);
    state = state.map((m) => m.id == id ? updated : m).toList();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    final reindexed = [
      for (int i = 0; i < list.length; i++) list[i].copyWith(orderIndex: i),
    ];
    for (final m in reindexed) {
      await _box.put(m.id, m);
    }
    state = reindexed;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    state = state.where((m) => m.id != id).toList();
  }
}

final messagesProvider = StateNotifierProvider.family<MessageNotifier,
    List<Message>, String>((ref, sceneId) {
  return MessageNotifier(ref.watch(messageBoxProvider), sceneId);
});
