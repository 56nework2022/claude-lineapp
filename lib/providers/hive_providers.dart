import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/project.dart';
import '../models/scene.dart';
import '../models/character.dart';
import '../models/message.dart';
import '../models/status_bar_config.dart';

final projectBoxProvider = Provider<Box<Project>>(
  (ref) => Hive.box<Project>('projects'),
);

final sceneBoxProvider = Provider<Box<Scene>>(
  (ref) => Hive.box<Scene>('scenes'),
);

final characterBoxProvider = Provider<Box<Character>>(
  (ref) => Hive.box<Character>('characters'),
);

final messageBoxProvider = Provider<Box<Message>>(
  (ref) => Hive.box<Message>('messages'),
);

final statusBarBoxProvider = Provider<Box<StatusBarConfig>>(
  (ref) => Hive.box<StatusBarConfig>('status_configs'),
);
