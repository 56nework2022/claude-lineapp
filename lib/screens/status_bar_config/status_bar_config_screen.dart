import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/scene.dart';
import '../../models/enums.dart';
import '../../providers/status_bar_provider.dart';
import '../../widgets/status_bar_widget.dart';

class StatusBarConfigScreen extends ConsumerWidget {
  const StatusBarConfigScreen({super.key, required this.scene});

  final Scene scene;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(statusBarProvider(scene.id));
    final notifier = ref.read(statusBarProvider(scene.id).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('ステータスバー設定')),
      body: Column(
        children: [
          StatusBarWidget(config: config),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionTitle('デバイス'),
                SegmentedButton<DeviceType>(
                  segments: const [
                    ButtonSegment(value: DeviceType.iphone, label: Text('iPhone風')),
                    ButtonSegment(value: DeviceType.android, label: Text('Android風')),
                  ],
                  selected: {config.deviceType},
                  onSelectionChanged: (v) => notifier.update(deviceType: v.first),
                ),
                const SizedBox(height: 24),
                _SectionTitle('時刻'),
                SwitchListTile(
                  title: const Text('現在時刻を使用'),
                  value: config.useCurrentTime,
                  onChanged: (v) => notifier.update(useCurrentTime: v),
                  contentPadding: EdgeInsets.zero,
                ),
                if (!config.useCurrentTime)
                  TextFormField(
                    initialValue: config.customTime,
                    decoration: const InputDecoration(
                      labelText: '表示する時刻（例：9:41）',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => notifier.update(customTime: v),
                  ),
                const SizedBox(height: 24),
                _SectionTitle('電波強度: ${config.signalStrength}/4'),
                Slider(
                  value: config.signalStrength.toDouble(),
                  min: 0,
                  max: 4,
                  divisions: 4,
                  label: '${config.signalStrength}',
                  onChanged: (v) => notifier.update(signalStrength: v.round()),
                ),
                const SizedBox(height: 16),
                _SectionTitle('電池残量: ${config.batteryLevel}%'),
                Slider(
                  value: config.batteryLevel.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${config.batteryLevel}%',
                  onChanged: (v) => notifier.update(batteryLevel: v.round()),
                ),
                SwitchListTile(
                  title: const Text('充電中'),
                  value: config.isCharging,
                  onChanged: (v) => notifier.update(isCharging: v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w600),
      ),
    );
  }
}
