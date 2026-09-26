import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/core/engine/idle_engine.dart';
import 'package:yoru_kissa/core/persistence/database.dart';
import 'package:yoru_kissa/core/persistence/save_repository.dart';
import 'package:yoru_kissa/core/state/game_state.dart';
import 'package:yoru_kissa/titles/yoru_kissa/content.dart';

/// メモリ上の旧形式ストア（移行テスト用）。
class _MemoryStore implements SaveStore {
  GameState? value;
  int saves = 0;

  @override
  Future<void> clear() async => value = null;

  @override
  Future<GameState?> load() async => value;

  @override
  Future<void> save(GameState s) async {
    saves++;
    await Future<void>.delayed(const Duration(milliseconds: 5));
    value = s;
  }
}

void main() {
  late YohakuDatabase db;
  final t0 = DateTime(2026, 9, 26, 22);

  setUp(() => db = YohakuDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  GameState played() {
    final r = IdleEngine(
      yoruKissa,
    ).run(GameState.initial(yoruKissa, t0), t0.add(const Duration(hours: 12)));
    return r.state.copyWith(
      pendingReport: r.report,
      activeBgm: 'bgm_rain_jazz',
      activeEffects: {'fx_steam'},
      purchasedProducts: {'ad_free'},
      episodes: {'rain_three'},
      adFree: true,
    );
  }

  test('SQLite に書いて読むと、同じ状態に戻る', () async {
    final store = DriftSaveStore(db);
    expect(await store.load(), isNull);
    final s = played();
    await store.save(s);
    final back = await store.load();
    expect(jsonEncode(back), jsonEncode(s));
  });

  test('上書き保存しても古い行が残らない', () async {
    final store = DriftSaveStore(db);
    await store.save(played());
    final fresh = GameState.initial(yoruKissa, t0);
    await store.save(fresh);
    final back = (await store.load())!;
    expect(back.visitors, isEmpty);
    expect(back.fragments, isEmpty);
    expect(back.ownedItems, fresh.ownedItems);
  });

  test('旧形式のセーブがあれば取り込み、旧形式は消す', () async {
    final store = DriftSaveStore(db);
    final legacy = _MemoryStore()..value = played();
    final loaded = await SaveRepository.loadWithMigration(store, legacy);
    expect(loaded, isNotNull);
    expect(legacy.value, isNull);
    expect(jsonEncode(await store.load()), jsonEncode(loaded));
  });

  test('保存が重なっても、最新の状態だけが書かれる', () async {
    final mem = _MemoryStore();
    final repo = SaveRepository(mem);
    final base = GameState.initial(yoruKissa, t0);
    for (var i = 1; i <= 10; i++) {
      repo.save(base.copyWith(money: i));
    }
    await repo.flush();
    expect(mem.value!.money, 10);
    expect(mem.saves, lessThanOrEqualTo(2));
  });

  test('消すと何も残らない', () async {
    final store = DriftSaveStore(db);
    await store.save(played());
    await store.clear();
    expect(await store.load(), isNull);
  });
}
