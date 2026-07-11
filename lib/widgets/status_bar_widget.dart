import 'dart:async';
import 'package:flutter/material.dart';
import '../models/status_bar_config.dart';
import '../models/enums.dart';

class StatusBarWidget extends StatefulWidget {
  const StatusBarWidget({super.key, required this.config});
  final StatusBarConfig config;

  @override
  State<StatusBarWidget> createState() => _StatusBarWidgetState();
}

class _StatusBarWidgetState extends State<StatusBarWidget> {
  Timer? _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    if (widget.config.useCurrentTime) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateTime());
    }
  }

  @override
  void didUpdateWidget(StatusBarWidget old) {
    super.didUpdateWidget(old);
    _timer?.cancel();
    _timer = null;
    _updateTime();
    if (widget.config.useCurrentTime) {
      _timer = Timer.periodic(const Duration(seconds: 30), (_) => _updateTime());
    }
  }

  void _updateTime() {
    if (!mounted) return;
    if (widget.config.useCurrentTime) {
      final now = DateTime.now();
      setState(() {
        _currentTime =
            '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
      });
    } else {
      setState(() => _currentTime = widget.config.customTime);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.config.deviceType == DeviceType.iphone
        ? _IphoneStatusBar(config: widget.config, time: _currentTime)
        : _AndroidStatusBar(config: widget.config, time: _currentTime);
  }
}

class _IphoneStatusBar extends StatelessWidget {
  const _IphoneStatusBar({required this.config, required this.time});
  final StatusBarConfig config;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              _SignalBars(strength: config.signalStrength, isIphone: true),
              const SizedBox(width: 6),
              _WifiIcon(),
              const SizedBox(width: 6),
              _BatteryIcon(
                level: config.batteryLevel,
                isCharging: config.isCharging,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AndroidStatusBar extends StatelessWidget {
  const _AndroidStatusBar({required this.config, required this.time});
  final StatusBarConfig config;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              _SignalBars(strength: config.signalStrength, isIphone: false),
              const SizedBox(width: 6),
              _BatteryIcon(
                level: config.batteryLevel,
                isCharging: config.isCharging,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.strength, required this.isIphone});
  final int strength;
  final bool isIphone;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final active = i < strength;
        return Container(
          width: 3,
          height: 4.0 + i * 2.5,
          margin: const EdgeInsets.only(right: 1.5),
          decoration: BoxDecoration(
            color: active ? Colors.black : Colors.black26,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class _WifiIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.wifi, size: 16, color: Colors.black);
  }
}

class _BatteryIcon extends StatelessWidget {
  const _BatteryIcon({required this.level, required this.isCharging});
  final int level;
  final bool isCharging;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isCharging)
          const Icon(Icons.bolt, size: 12, color: Colors.black54),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: 22,
              height: 11,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 22 * (level / 100).clamp(0.0, 1.0),
              height: 11,
              decoration: BoxDecoration(
                color: level < 20 ? Colors.red : Colors.black87,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
