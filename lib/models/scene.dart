import 'package:hive/hive.dart';
import 'enums.dart';

class Scene {
  const Scene({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    required this.orderIndex,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String name;
  final SceneType type;
  final int orderIndex;
  final DateTime createdAt;

  Scene copyWith({String? name, int? orderIndex}) => Scene(
        id: id,
        projectId: projectId,
        name: name ?? this.name,
        type: type,
        orderIndex: orderIndex ?? this.orderIndex,
        createdAt: createdAt,
      );
}

class SceneAdapter extends TypeAdapter<Scene> {
  @override
  final int typeId = 1;

  @override
  Scene read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return Scene(
      id: fields[0] as String,
      projectId: fields[1] as String,
      name: fields[2] as String,
      type: fields[3] as SceneType,
      orderIndex: fields[4] as int,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Scene obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.projectId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.orderIndex)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
