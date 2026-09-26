import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/persistence/database.dart';
import 'core/persistence/save_repository.dart';
import 'core/state/game_controller.dart';
import 'titles/yoru_kissa/content.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = YohakuDatabase.open('yohaku_${yoruKissa.id}');
  final store = DriftSaveStore(db);
  final legacy = PrefsSaveStore(
    await SharedPreferences.getInstance(),
    yoruKissa.id,
  );
  final initial = await SaveRepository.loadWithMigration(store, legacy);
  runApp(
    ProviderScope(
      overrides: [
        saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
        initialGameStateProvider.overrideWithValue(initial),
      ],
      child: const YohakuApp(),
    ),
  );
}
