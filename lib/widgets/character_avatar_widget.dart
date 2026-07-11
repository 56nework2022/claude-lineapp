import 'dart:io';
import 'package:flutter/material.dart';
import '../models/character.dart';
import '../utils/constants.dart';

class CharacterAvatarWidget extends StatelessWidget {
  const CharacterAvatarWidget({
    super.key,
    required this.character,
    this.size = 36,
  });

  final Character character;
  final double size;

  @override
  Widget build(BuildContext context) {
    final path = character.iconPath;
    if (path != null && File(path).existsSync()) {
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: FileImage(File(path)),
      );
    }
    final initial = character.name.isNotEmpty ? character.name[0] : '?';
    final color = avatarColors[character.name.hashCode % avatarColors.length];
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
