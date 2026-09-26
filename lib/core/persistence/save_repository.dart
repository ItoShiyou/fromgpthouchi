import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/content.dart';
import '../state/game_state.dart';
import 'database.dart';

/// セーブデータの置き場所。
abstract interface class SaveStore {
  Future<GameState?> load();
  Future<void> save(GameState s);
  Future<void> clear();
}

/// 正本：SQLite（Drift）。企画書 17 のテーブル構成で保存する。
class DriftSaveStore implements SaveStore {
  DriftSaveStore(this.db);

  final YohakuDatabase db;

  @override
  Future<GameState?> load() async {
    final p = await (db.select(
      db.playerState,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (p == null) return null;
    final inv = await db.select(db.inventory).get();
    Set<String> ids(String kind) => {
      for (final r in inv)
        if (r.kind == kind) r.refId,
    };
    final placement = await db.select(db.placement).get();
    final visitors = await db.select(db.visitorState).get();
    final events = await db.select(db.eventState).get();
    final fragments = await (db.select(
      db.fragments,
    )..orderBy([(t) => OrderingTerm.asc(t.at)])).get();

    List<dynamic> list(String json) => jsonDecode(json) as List<dynamic>;
    return GameState(
      money: p.money,
      register: p.register,
      tickets: p.tickets,
      ownedItems: ids('item'),
      ownedMenus: ids('menu'),
      purchasedProducts: ids('product'),
      episodes: ids('episode'),
      grantedReceipts: ids('receipt'),
      placement: {
        for (final r in placement)
          if (PlacementSlot.values.any((s) => s.name == r.slot))
            PlacementSlot.values.byName(r.slot): r.itemId,
      },
      visitors: {
        for (final v in visitors)
          v.visitorId: VisitorRecord(
            visits: v.visits,
            firstSeenAt: v.firstSeenAt,
            lastSeenAt: v.lastSeenAt,
            favoriteKnown: v.favoriteKnown,
          ),
      },
      stories: {
        for (final e in events)
          e.chainId: StoryProgress(
            nextStep: e.nextStep,
            lastStepAt: e.lastStepAt,
          ),
      },
      fragments: [
        for (final f in fragments)
          DiscoveredFragment(chainId: f.chainId, step: f.step, at: f.at),
      ],
      recentVisits: [
        for (final v in list(p.recentVisitsJson))
          Visit.fromJson(v as Map<String, dynamic>),
      ],
      seated: [
        for (final g in list(p.seatedJson))
          SeatedGuest.fromJson(g as Map<String, dynamic>),
      ],
      lastSimulatedAt: p.lastSimulatedAt,
      lastDailyTicketDate: p.lastDailyTicketDate,
      gachaPity: p.gachaPity,
      gachaDraws: p.gachaDraws,
      adFree: p.adFree,
      activeBgm: p.activeBgm,
      activeEffects: list(p.activeEffectsJson).cast<String>().toSet(),
      debugOffsetMinutes: p.debugOffsetMinutes,
      settings: GameSettings.fromJson(
        jsonDecode(p.settingsJson) as Map<String, dynamic>,
      ),
      pendingReport: p.pendingReportJson == null
          ? null
          : IdleReport.fromJson(
              jsonDecode(p.pendingReportJson!) as Map<String, dynamic>,
            ),
    );
  }

  @override
  Future<void> save(GameState s) => db.transaction(() async {
    await db
        .into(db.playerState)
        .insertOnConflictUpdate(
          PlayerStateCompanion.insert(
            id: const Value(1),
            money: s.money,
            register: s.register,
            tickets: s.tickets,
            lastSimulatedAt: s.lastSimulatedAt,
            lastDailyTicketDate: Value(s.lastDailyTicketDate),
            gachaPity: s.gachaPity,
            gachaDraws: s.gachaDraws,
            adFree: s.adFree,
            activeBgm: Value(s.activeBgm),
            debugOffsetMinutes: s.debugOffsetMinutes,
            seatedJson: jsonEncode(s.seated),
            recentVisitsJson: jsonEncode(s.recentVisits),
            activeEffectsJson: jsonEncode(s.activeEffects.toList()),
            settingsJson: jsonEncode(s.settings),
            pendingReportJson: Value(
              s.pendingReport == null ? null : jsonEncode(s.pendingReport),
            ),
          ),
        );
    // 小さい表なので、差分ではなく丸ごと書き直す。
    await db.delete(db.inventory).go();
    await db.delete(db.placement).go();
    await db.delete(db.visitorState).go();
    await db.delete(db.eventState).go();
    await db.delete(db.fragments).go();
    await db.batch((b) {
      b.insertAll(db.inventory, [
        for (final id in s.ownedItems)
          InventoryCompanion.insert(kind: 'item', refId: id),
        for (final id in s.ownedMenus)
          InventoryCompanion.insert(kind: 'menu', refId: id),
        for (final id in s.purchasedProducts)
          InventoryCompanion.insert(kind: 'product', refId: id),
        for (final id in s.episodes)
          InventoryCompanion.insert(kind: 'episode', refId: id),
        for (final id in s.grantedReceipts)
          InventoryCompanion.insert(kind: 'receipt', refId: id),
      ]);
      b.insertAll(db.placement, [
        for (final e in s.placement.entries)
          PlacementCompanion.insert(slot: e.key.name, itemId: e.value),
      ]);
      b.insertAll(db.visitorState, [
        for (final e in s.visitors.entries)
          VisitorStateCompanion.insert(
            visitorId: e.key,
            visits: e.value.visits,
            firstSeenAt: e.value.firstSeenAt,
            lastSeenAt: e.value.lastSeenAt,
            favoriteKnown: e.value.favoriteKnown,
          ),
      ]);
      b.insertAll(db.eventState, [
        for (final e in s.stories.entries)
          EventStateCompanion.insert(
            chainId: e.key,
            nextStep: e.value.nextStep,
            lastStepAt: Value(e.value.lastStepAt),
          ),
      ]);
      b.insertAll(db.fragments, [
        for (final f in s.fragments)
          FragmentsCompanion.insert(chainId: f.chainId, step: f.step, at: f.at),
      ]);
    });
  });

  @override
  Future<void> clear() => db.transaction(() async {
    // 試遊ログはセーブデータではないので残す
    for (final t in db.allTables) {
      if (t is $AnalyticsEventsTable) continue;
      await db.delete(t).go();
    }
  });
}

/// 旧形式（v0.1〜0.3）：shared_preferences の JSON 1 本。移行元としてだけ使う。
class PrefsSaveStore implements SaveStore {
  PrefsSaveStore(this._prefs, this.titleId);

  final SharedPreferences _prefs;
  final String titleId;

  String get _key => 'save.$titleId';

  @override
  Future<GameState?> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(GameState s) => _prefs.setString(_key, jsonEncode(s));

  @override
  Future<void> clear() => _prefs.remove(_key);
}

/// ゲームから見た保存窓口。
///
/// 20 秒ごとの自動精算などで保存が重なっても、書き込みは 1 本ずつ・最新の状態だけ行う。
class SaveRepository {
  SaveRepository(this.store);

  final SaveStore store;

  GameState? _next;
  Future<void>? _writing;

  /// 旧形式のセーブがあれば取り込み、以後は [store] だけを使う。
  static Future<GameState?> loadWithMigration(
    SaveStore store,
    SaveStore? legacy,
  ) async {
    final current = await store.load();
    if (current != null || legacy == null) return current;
    final old = await legacy.load();
    if (old == null) return null;
    await store.save(old);
    await legacy.clear();
    return old;
  }

  Future<void> save(GameState s) {
    _next = s;
    return _writing ??= _drain();
  }

  Future<void> _drain() async {
    try {
      while (_next != null) {
        final s = _next!;
        _next = null;
        await store.save(s);
      }
    } finally {
      _writing = null;
    }
  }

  /// 書きかけがあれば終わるまで待つ（アプリが裏に回る時など）。
  Future<void> flush() => _writing ?? Future.value();

  Future<void> clear() async {
    await flush();
    await store.clear();
  }

  /// バックアップ用の書き出し。
  String export(GameState s) => base64Encode(utf8.encode(jsonEncode(s)));
}
