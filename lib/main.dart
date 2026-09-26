import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/art/art_library.dart';
import 'core/persistence/database.dart';
import 'core/persistence/save_repository.dart';
import 'core/services/analytics.dart';
import 'core/services/cloud_backup.dart';
import 'core/services/event_notifier.dart';
import 'core/services/purchase_store.dart';
import 'core/services/sound.dart';
import 'core/state/game_controller.dart';
import 'core/state/purchase_controller.dart';
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
  Art.current = await ArtLibrary.load(yoruKissa.id);
  final cloud = await createCloudBackup();
  final notifier = createEventNotifier();
  await notifier.init();
  runApp(
    ProviderScope(
      overrides: [
        saveRepositoryProvider.overrideWithValue(SaveRepository(store)),
        initialGameStateProvider.overrideWithValue(initial),
        eventNotifierProvider.overrideWithValue(notifier),
        databaseProvider.overrideWithValue(db),
        cloudBackupProvider.overrideWithValue(cloud),
        if (cloud is SupabaseCloudBackup &&
            SupabaseReceiptVerifier.enabledByBuild)
          receiptVerifierProvider.overrideWithValue(
            SupabaseReceiptVerifier(cloud.client, yoruKissa.id),
          ),
        analyticsProvider.overrideWithValue(
          Analytics([DriftAnalyticsSink(db)]),
        ),
        soundProvider.overrideWithValue(SoundDirector(AudioplayersOutput())),
        purchaseStoreProvider.overrideWithValue(
          createPurchaseStore(yoruKissa.products),
        ),
      ],
      child: const YohakuApp(),
    ),
  );
}
