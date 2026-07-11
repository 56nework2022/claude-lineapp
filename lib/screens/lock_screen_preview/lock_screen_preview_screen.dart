import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/scene.dart';
import '../../models/enums.dart';
import '../../providers/message_provider.dart';
import '../../providers/character_provider.dart';
import '../../providers/status_bar_provider.dart';
import '../fullscreen_view/fullscreen_view_screen.dart';

class LockScreenPreviewScreen extends ConsumerWidget {
  const LockScreenPreviewScreen({super.key, required this.scene});

  final Scene scene;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider(scene.id));
    final characters = ref.watch(charactersProvider(scene.id));
    final statusBar = ref.watch(statusBarProvider(scene.id));

    final firstMessage = messages.isNotEmpty ? messages.first : null;
    final sender = firstMessage != null
        ? characters.where((c) => c.id == firstMessage.characterId).firstOrNull
        : null;

    final isIphone = statusBar.deviceType == DeviceType.iphone;
    final now = DateTime.now();
    final timeStr =
        '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr = '${now.month}月${now.day}日(${_weekday(now.weekday)})';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isIphone
                ? [const Color(0xFF2C3E50), const Color(0xFF3498DB)]
                : [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                timeStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const Spacer(),
              if (firstMessage != null)
                _NotificationBanner(
                  senderName: sender?.name ?? '不明',
                  messageText: firstMessage.text,
                  time: firstMessage.displayTime,
                  isIphone: isIphone,
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullscreenViewScreen(scene: scene),
                  ),
                ),
                icon: const Icon(Icons.fullscreen),
                label: const Text('撮影開始'),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('戻る', style: TextStyle(color: Colors.white70)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _weekday(int weekday) {
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    return days[(weekday - 1) % 7];
  }
}

class _NotificationBanner extends StatelessWidget {
  const _NotificationBanner({
    required this.senderName,
    required this.messageText,
    required this.time,
    required this.isIphone,
  });

  final String senderName;
  final String messageText;
  final String time;
  final bool isIphone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51),
          borderRadius: BorderRadius.circular(isIphone ? 16 : 8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF06C755),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        senderName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        time,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    messageText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
