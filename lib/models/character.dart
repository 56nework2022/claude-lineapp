import 'package:hive/hive.dart';

class Character {
  const Character({
    required this.id,
    required this.sceneId,
    required this.name,
    required this.isSelf,
    required this.orderIndex,
    this.iconPath,
  });

  final String id;
  final String sceneId;
  final String name;
  final bool isSelf;
  final int orderIndex;
  final String? iconPath;

  Character copyWith({
    String? name,
    bool? isSelf,
    int? orderIndex,
    String? iconPath,
    bool clearIcon = false,
  }) =>
      Character(
        id: id,
        sceneId: sceneId,
        name: name ?? this.name,
        isSelf: isSelf ?? this.isSelf,
        orderIndex: orderIndex ?? this.orderIndex,
        iconPath: clearIcon ? null : (iconPath ?? this.iconPath),
      );
}

class CharacterAdapter extends TypeAdapter<Character> {
  @override
  final int typeId = 2;

  @override
  Character read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return Character(
      id: fields[0] as String,
      sceneId: fields[1] as String,
      name: fields[2] as String,
      isSelf: fields[3] as bool,
      orderIndex: fields[4] as int,
      iconPath: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Character obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sceneId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.isSelf)
      ..writeByte(4)
      ..write(obj.orderIndex)
      ..writeByte(5)
      ..write(obj.iconPath);
  }
}
