import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/persistence/save_repository.dart';
import 'core/state/game_controller.dart';
import 'titles/yoru_kissa/content.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        saveRepositoryProvider.overrideWithValue(
          SaveRepository(prefs, yoruKissa.id),
        ),
      ],
      child: const YohakuApp(),
    ),
  );
}
