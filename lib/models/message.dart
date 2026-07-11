import 'package:hive/hive.dart';

class Message {
  const Message({
    required this.id,
    required this.sceneId,
    required this.characterId,
    required this.text,
    required this.displayTime,
    required this.isRead,
    required this.orderIndex,
  });

  final String id;
  final String sceneId;
  final String characterId;
  final String text;
  final String displayTime;
  final bool isRead;
  final int orderIndex;

  Message copyWith({
    String? characterId,
    String? text,
    String? displayTime,
    bool? isRead,
    int? orderIndex,
  }) =>
      Message(
        id: id,
        sceneId: sceneId,
        characterId: characterId ?? this.characterId,
        text: text ?? this.text,
        displayTime: displayTime ?? this.displayTime,
        isRead: isRead ?? this.isRead,
        orderIndex: orderIndex ?? this.orderIndex,
      );
}

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 3;

  @override
  Message read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      sceneId: fields[1] as String,
      characterId: fields[2] as String,
      text: fields[3] as String,
      displayTime: fields[4] as String,
      isRead: fields[5] as bool,
      orderIndex: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sceneId)
      ..writeByte(2)
      ..write(obj.characterId)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.displayTime)
      ..writeByte(5)
      ..write(obj.isRead)
      ..writeByte(6)
      ..write(obj.orderIndex);
  }
}
