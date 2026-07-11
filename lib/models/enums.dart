import 'package:hive/hive.dart';

enum SceneType { chat }

enum DeviceType { iphone, android }

class SceneTypeAdapter extends TypeAdapter<SceneType> {
  @override
  final int typeId = 5;

  @override
  SceneType read(BinaryReader reader) => SceneType.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, SceneType obj) => writer.writeByte(obj.index);
}

class DeviceTypeAdapter extends TypeAdapter<DeviceType> {
  @override
  final int typeId = 6;

  @override
  DeviceType read(BinaryReader reader) => DeviceType.values[reader.readByte()];

  @override
  void write(BinaryWriter writer, DeviceType obj) =>
      writer.writeByte(obj.index);
}
