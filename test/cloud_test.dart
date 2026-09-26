import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/core/persistence/save_repository.dart';
import 'package:yoru_kissa/core/services/cloud_backup.dart';
import 'package:yoru_kissa/core/state/game_controller.dart';
import 'package:yoru_kissa/core/state/game_state.dart';
import 'package:yoru_kissa/titles/yoru_kissa/content.dart';

/// Supabase の代わり（migrations/0001_init.sql と同じ決まりごと）。
class _Server {
  final saves = <(String, String), Map<String, dynamic>>{};
  final codes = <String, (String, String)>{};
  var _n = 0;
}

class _Device implements CloudBackup {
  _Device(this.server, this.user);
  final _Server server;
  final String user;

  @override
  bool get enabled => true;
  @override
  Future<DateTime?> lastBackupAt(String t) async =>
      server.saves.containsKey((user, t)) ? DateTime(2026) : null;
  @override
  Future<void> upload(String t, GameState s) async =>
      server.saves[(user, t)] = s.toJson();
  @override
  Future<GameState?> download(String t) async {
    final d = server.saves[(user, t)];
    return d == null ? null : GameState.fromJson(d);
  }

  @override
  Future<String> createTransferCode(String t) async {
    final code = 'CODE${server._n++}';
    server.codes[code] = (user, t);
    return code;
  }

  @override
  Future<GameState> claimTransferCode(String code) async {
    final c = server.codes.remove(code) ?? (throw StateError('invalid code'));
    final data = server.saves[c]!;
    server.saves[(user, c.$2)] = data;
    return GameState.fromJson(data);
  }
}

class _NullStore implements SaveStore {
  @override
  Future<void> clear() async {}
  @override
  Future<GameState?> load() async => null;
  @override
  Future<void> save(GameState s) async {}
}

ProviderContainer device(CloudBackup cloud, GameState s) => ProviderContainer(
  overrides: [
    saveRepositoryProvider.overrideWithValue(SaveRepository(_NullStore())),
    initialGameStateProvider.overrideWithValue(s),
    cloudBackupProvider.overrideWithValue(cloud),
  ],
);

void main() {
  final t0 = DateTime(2026, 9, 26, 22);

  test('前の端末でコードを出し、新しい端末で入れると店が引き継がれる', () async {
    final server = _Server();
    final oldPhone = device(
      _Device(server, 'A'),
      GameState.initial(yoruKissa, t0).copyWith(money: 54321, tickets: 7),
    );
    final newPhone = device(
      _Device(server, 'B'),
      GameState.initial(yoruKissa, t0),
    );

    final a = oldPhone.read(cloudBackupProvider);
    await a.upload(yoruKissa.id, oldPhone.read(gameProvider));
    final code = await a.createTransferCode(yoruKissa.id);

    final saved = await newPhone
        .read(cloudBackupProvider)
        .claimTransferCode(code);
    newPhone.read(gameProvider.notifier).restoreFrom(saved);
    expect(newPhone.read(gameProvider).money, 54321);
    expect(newPhone.read(gameProvider).tickets, 7);

    // コードは一度きり
    expect(
      () => newPhone.read(cloudBackupProvider).claimTransferCode(code),
      throwsStateError,
    );
    oldPhone.dispose();
    newPhone.dispose();
  });

  test('戻す時は、未読の「おかえりなさい」と時間送りを持ち込まない', () {
    final c = device(
      const DisabledCloudBackup(),
      GameState.initial(yoruKissa, t0),
    );
    final saved = GameState.initial(
      yoruKissa,
      t0,
    ).copyWith(money: 10, debugOffsetMinutes: 600);
    c.read(gameProvider.notifier).restoreFrom(saved);
    expect(c.read(gameProvider).money, 10);
    expect(c.read(gameProvider).debugOffsetMinutes, 0);
    expect(c.read(gameProvider).pendingReport, isNull);
    c.dispose();
  });

  test('クラウドの設定が無ければ無効', () {
    expect(const DisabledCloudBackup().enabled, isFalse);
    expect(SupabaseCloudBackup.configured, isFalse);
  });
}
