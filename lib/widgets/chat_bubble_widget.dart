import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/message.dart';
import '../utils/constants.dart';
import 'character_avatar_widget.dart';

class ChatBubbleWidget extends StatelessWidget {
  const ChatBubbleWidget({
    super.key,
    required this.message,
    required this.character,
    this.showAvatar = true,
  });

  final Message message;
  final Character character;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return character.isSelf ? _SelfBubble(message: message) : _OtherBubble(
      message: message,
      character: character,
      showAvatar: showAvatar,
    );
  }
}

class _SelfBubble extends StatelessWidget {
  const _SelfBubble({required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 12, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isRead)
            const Padding(
              padding: EdgeInsets.only(right: 4, bottom: 2),
              child: Text('既読', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: chatGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message.displayTime,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtherBubble extends StatelessWidget {
  const _OtherBubble({
    required this.message,
    required this.character,
    required this.showAvatar,
  });

  final Message message;
  final Character character;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 60, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 36,
            child: showAvatar
                ? CharacterAvatarWidget(character: character)
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showAvatar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    character.name,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: chatBubbleWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message.displayTime,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
