import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/project.dart';
import 'models/scene.dart';
import 'models/character.dart';
import 'models/message.dart';
import 'models/status_bar_config.dart';
import 'models/enums.dart';
import 'screens/project_list/project_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(SceneAdapter());
  Hive.registerAdapter(CharacterAdapter());
  Hive.registerAdapter(MessageAdapter());
  Hive.registerAdapter(StatusBarConfigAdapter());
  Hive.registerAdapter(SceneTypeAdapter());
  Hive.registerAdapter(DeviceTypeAdapter());

  await Future.wait([
    Hive.openBox<Project>('projects'),
    Hive.openBox<Scene>('scenes'),
    Hive.openBox<Character>('characters'),
    Hive.openBox<Message>('messages'),
    Hive.openBox<StatusBarConfig>('status_configs'),
  ]);

  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'フェイク画面メーカー',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF06C755)),
        useMaterial3: true,
      ),
      home: const ProjectListScreen(),
    );
  }
}
