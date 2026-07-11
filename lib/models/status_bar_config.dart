import 'package:hive/hive.dart';
import 'enums.dart';

class StatusBarConfig {
  const StatusBarConfig({
    required this.sceneId,
    required this.customTime,
    required this.useCurrentTime,
    required this.signalStrength,
    required this.batteryLevel,
    required this.isCharging,
    required this.deviceType,
  });

  factory StatusBarConfig.defaultFor(String sceneId) => StatusBarConfig(
        sceneId: sceneId,
        customTime: '9:41',
        useCurrentTime: false,
        signalStrength: 4,
        batteryLevel: 100,
        isCharging: false,
        deviceType: DeviceType.iphone,
      );

  final String sceneId;
  final String customTime;
  final bool useCurrentTime;
  final int signalStrength;
  final int batteryLevel;
  final bool isCharging;
  final DeviceType deviceType;

  StatusBarConfig copyWith({
    String? customTime,
    bool? useCurrentTime,
    int? signalStrength,
    int? batteryLevel,
    bool? isCharging,
    DeviceType? deviceType,
  }) =>
      StatusBarConfig(
        sceneId: sceneId,
        customTime: customTime ?? this.customTime,
        useCurrentTime: useCurrentTime ?? this.useCurrentTime,
        signalStrength: signalStrength ?? this.signalStrength,
        batteryLevel: batteryLevel ?? this.batteryLevel,
        isCharging: isCharging ?? this.isCharging,
        deviceType: deviceType ?? this.deviceType,
      );
}

class StatusBarConfigAdapter extends TypeAdapter<StatusBarConfig> {
  @override
  final int typeId = 4;

  @override
  StatusBarConfig read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return StatusBarConfig(
      sceneId: fields[0] as String,
      customTime: fields[1] as String,
      useCurrentTime: fields[2] as bool,
      signalStrength: fields[3] as int,
      batteryLevel: fields[4] as int,
      isCharging: fields[5] as bool,
      deviceType: fields[6] as DeviceType,
    );
  }

  @override
  void write(BinaryWriter writer, StatusBarConfig obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.sceneId)
      ..writeByte(1)
      ..write(obj.customTime)
      ..writeByte(2)
      ..write(obj.useCurrentTime)
      ..writeByte(3)
      ..write(obj.signalStrength)
      ..writeByte(4)
      ..write(obj.batteryLevel)
      ..writeByte(5)
      ..write(obj.isCharging)
      ..writeByte(6)
      ..write(obj.deviceType);
  }
}
