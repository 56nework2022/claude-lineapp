import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/status_bar_config.dart';
import '../models/enums.dart';
import 'hive_providers.dart';

class StatusBarNotifier extends StateNotifier<StatusBarConfig> {
  StatusBarNotifier(this._box, String sceneId)
      : super(_box.get(sceneId) ?? StatusBarConfig.defaultFor(sceneId));

  final Box<StatusBarConfig> _box;

  Future<void> update({
    String? customTime,
    bool? useCurrentTime,
    int? signalStrength,
    int? batteryLevel,
    bool? isCharging,
    DeviceType? deviceType,
  }) async {
    final updated = state.copyWith(
      customTime: customTime,
      useCurrentTime: useCurrentTime,
      signalStrength: signalStrength,
      batteryLevel: batteryLevel,
      isCharging: isCharging,
      deviceType: deviceType,
    );
    await _box.put(state.sceneId, updated);
    state = updated;
  }
}

final statusBarProvider = StateNotifierProvider.family<StatusBarNotifier,
    StatusBarConfig, String>((ref, sceneId) {
  return StatusBarNotifier(ref.watch(statusBarBoxProvider), sceneId);
});
