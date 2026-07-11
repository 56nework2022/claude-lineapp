import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/scene.dart';
import '../../providers/message_provider.dart';
import '../../providers/character_provider.dart';
import '../../providers/status_bar_provider.dart';
import '../../providers/fullscreen_provider.dart';
import '../../utils/image_exporter.dart';
import '../../models/character.dart';
import '../../widgets/status_bar_widget.dart';
import '../../widgets/chat_bubble_widget.dart';

class FullscreenViewScreen extends ConsumerStatefulWidget {
  const FullscreenViewScreen({super.key, required this.scene});

  final Scene scene;

  @override
  ConsumerState<FullscreenViewScreen> createState() =>
      _FullscreenViewScreenState();
}

class _FullscreenViewScreenState extends ConsumerState<FullscreenViewScreen> {
  final _screenshotKey = GlobalKey();
  final _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fullscreenProgressProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _advance() {
    final messages = ref.read(messagesProvider(widget.scene.id));
    final current = ref.read(fullscreenProgressProvider);
    if (current < messages.length) {
      ref.read(fullscreenProgressProvider.notifier).advance(messages.length);
      _listKey.currentState?.insertItem(current);
    }
  }

  void _exit() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.scene.id));
    final characters = ref.watch(charactersProvider(widget.scene.id));
    final statusBar = ref.watch(statusBarProvider(widget.scene.id));
    final progress = ref.watch(fullscreenProgressProvider);

    final visibleMessages = messages.take(progress).toList();

    Character? findCharacter(String id) {
      try {
        return characters.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F4),
      body: GestureDetector(
        onTap: _advance,
        onLongPress: _exit,
        child: RepaintBoundary(
          key: _screenshotKey,
          child: Container(
            color: const Color(0xFFEFF3F4),
            child: Column(
              children: [
              StatusBarWidget(config: statusBar),
              Expanded(
                child: Stack(
                  children: [
                    AnimatedList(
                      key: _listKey,
                      initialItemCount: 0,
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemBuilder: (context, index, animation) {
                        if (index >= visibleMessages.length) {
                          return const SizedBox.shrink();
                        }
                        final message = visibleMessages[index];
                        final character = findCharacter(message.characterId);
                        if (character == null) return const SizedBox.shrink();

                        final prevSame = index > 0 &&
                            visibleMessages[index - 1].characterId ==
                                message.characterId;

                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOut)),
                          ),
                          child: FadeTransition(
                            opacity: animation,
                            child: ChatBubbleWidget(
                              message: message,
                              character: character,
                              showAvatar: !prevSame,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton.small(
                        onPressed: () => ImageExporter.export(_screenshotKey, context),
                        backgroundColor: Colors.white54,
                        foregroundColor: Colors.black54,
                        child: const Icon(Icons.download),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
