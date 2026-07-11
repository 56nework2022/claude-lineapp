import 'package:flutter/material.dart';
import '../../../models/character.dart';
import '../../../models/message.dart';

class MessageForm extends StatefulWidget {
  const MessageForm({
    super.key,
    required this.characters,
    this.editing,
    required this.onSave,
  });

  final List<Character> characters;
  final Message? editing;
  final void Function({
    required String characterId,
    required String text,
    required String displayTime,
    required bool isRead,
  }) onSave;

  @override
  State<MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  late String _characterId;
  late TextEditingController _textCtrl;
  late TextEditingController _timeCtrl;
  late bool _isRead;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _characterId = e?.characterId ??
        (widget.characters.isNotEmpty ? widget.characters.first.id : '');
    _textCtrl = TextEditingController(text: e?.text ?? '');
    _timeCtrl = TextEditingController(text: e?.displayTime ?? _defaultTime());
    _isRead = e?.isRead ?? false;
  }

  String _defaultTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.characters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('先に登場人物を追加してください'),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.editing == null ? 'メッセージを追加' : 'メッセージを編集',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: widget.characters.any((c) => c.id == _characterId)
                ? _characterId
                : widget.characters.first.id,
            decoration: const InputDecoration(labelText: '送信者', border: OutlineInputBorder()),
            items: widget.characters
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => _characterId = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textCtrl,
            decoration: const InputDecoration(labelText: '本文', border: OutlineInputBorder()),
            maxLines: 3,
            autofocus: widget.editing == null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _timeCtrl,
            decoration: const InputDecoration(labelText: '時刻（例：14:30）', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _isRead,
                onChanged: (v) => setState(() => _isRead = v!),
              ),
              const Text('既読'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('キャンセル'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_textCtrl.text.trim().isEmpty) return;
                  widget.onSave(
                    characterId: _characterId,
                    text: _textCtrl.text,
                    displayTime: _timeCtrl.text,
                    isRead: _isRead,
                  );
                  Navigator.pop(context);
                },
                child: Text(widget.editing == null ? '追加' : '保存'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
