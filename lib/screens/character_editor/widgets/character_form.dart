import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../models/character.dart';
import '../../../widgets/character_avatar_widget.dart';

class CharacterForm extends StatefulWidget {
  const CharacterForm({
    super.key,
    required this.hasSelf,
    this.editing,
    required this.onSave,
  });

  final bool hasSelf;
  final Character? editing;
  final void Function({
    required String name,
    required bool isSelf,
    String? iconPath,
  }) onSave;

  @override
  State<CharacterForm> createState() => _CharacterFormState();
}

class _CharacterFormState extends State<CharacterForm> {
  late TextEditingController _nameCtrl;
  late bool _isSelf;
  String? _iconPath;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _isSelf = e?.isSelf ?? (!widget.hasSelf);
    _iconPath = e?.iconPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool _pickingImage = false;

  Future<void> _pickImage() async {
    if (_pickingImage) return;
    _pickingImage = true;
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final dest = p.join(dir.path, 'avatars', '${DateTime.now().millisecondsSinceEpoch}.jpg');
      await Directory(p.dirname(dest)).create(recursive: true);
      await File(file.path).copy(dest);
      setState(() => _iconPath = dest);
    } on PlatformException {
      // 画像ピッカーが多重起動された場合など。無視して再タップを待つ。
    } finally {
      _pickingImage = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dummyChar = Character(
      id: '',
      sceneId: '',
      name: _nameCtrl.text.isEmpty ? '?' : _nameCtrl.text,
      isSelf: false,
      orderIndex: 0,
      iconPath: _iconPath,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.editing == null ? '登場人物を追加' : '登場人物を編集',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                CharacterAvatarWidget(character: dummyChar, size: 72),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '名前', border: OutlineInputBorder()),
            autofocus: widget.editing == null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('自分（送信側）'),
            subtitle: const Text('右側の緑吹き出しになります'),
            value: _isSelf,
            onChanged: (widget.editing?.isSelf == true || !widget.hasSelf)
                ? (v) => setState(() => _isSelf = v)
                : null,
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
                  if (_nameCtrl.text.trim().isEmpty) return;
                  widget.onSave(
                    name: _nameCtrl.text,
                    isSelf: _isSelf,
                    iconPath: _iconPath,
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
