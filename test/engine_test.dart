import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/core/engine/ambience.dart';
import 'package:yoru_kissa/core/engine/gacha_engine.dart';
import 'package:yoru_kissa/core/engine/idle_engine.dart';
import 'package:yoru_kissa/core/models/content.dart';
import 'package:yoru_kissa/core/models/world.dart';
import 'package:yoru_kissa/core/state/game_state.dart';
import 'package:yoru_kissa/titles/yoru_kissa/content.dart';

/// 常に同じ値を返す乱数（天井のテスト用）。
class _FixedRandom implements math.Random {
  _FixedRandom(this.value);
  final double value;
  @override
  double nextDouble() => value;
  @override
  int nextInt(int max) => 0;
  @override
  bool nextBool() => false;
}

void main() {
  final c = yoruKissa;
  final engine = IdleEngine(c);
  final t0 = DateTime(2026, 9, 26, 22);

  GameState fresh(DateTime at) => GameState.initial(c, at);

  group('放置計算', () {
    test('12 時間を超えた分は数えない（損もしない）', () {
      final s = fresh(t0);
      final r20 = engine.run(s, t0.add(const Duration(hours: 20))).report;
      expect(r20.elapsed, const Duration(hours: 20));
      expect(r20.effective, const Duration(hours: 12));
      expect(r20.isCapped, isTrue);

      // 直近 12 時間ぶんだけを計算したのと同じ結果になる。
      final s8 = fresh(t0.add(const Duration(hours: 8)));
      final r12 = engine.run(s8, t0.add(const Duration(hours: 20))).report;
      expect(r20.income, r12.income);
      expect(r20.visitCount, r12.visitCount);
    });

    test('何回に分けて起動しても、来店と売上は同じ', () {
      final end = t0.add(const Duration(hours: 12));
      final once = engine.run(fresh(t0), end);

      var s = fresh(t0);
      var income = 0;
      var visits = 0;
      var fragments = 0;
      for (var m = 37; m <= 12 * 60; m += 37) {
        final r = engine.run(s, t0.add(Duration(minutes: m)));
        s = r.state;
        income += r.report.income;
        visits += r.report.visitCount;
        fragments += r.report.newFragments.length;
      }
      final last = engine.run(s, end);
      income += last.report.income;
      visits += last.report.visitCount;
      fragments += last.report.newFragments.length;

      expect(visits, once.report.visitCount);
      expect(income, once.report.income);
      expect(fragments, once.report.newFragments.length);
    });

    test('12 時間でそれなりの来店と売上がある', () {
      final r = engine.run(fresh(t0), t0.add(const Duration(hours: 12))).report;
      expect(r.visitCount, greaterThan(5));
      expect(r.income, greaterThan(2000));
    });

    test('時間が進んでいなければ何も起きない', () {
      final s = fresh(t0);
      final r = engine.run(s, t0).report;
      expect(r.visitCount, 0);
      expect(r.income, 0);
    });

    test('未回収の売上は レジ＋席の客 に分かれ、合計は売上と一致', () {
      final r = engine.run(fresh(t0), t0.add(const Duration(hours: 8)));
      expect(r.state.seated.length, lessThanOrEqualTo(IdleEngine.maxSeated));
      expect(r.state.uncollected, r.report.income);
    });

    test('会計しても、残った客は席を移らない', () {
      final r = engine.run(fresh(t0), t0.add(const Duration(hours: 8)));
      final seated = r.state.seated;
      expect(seated.map((g) => g.seat).toSet(), {0, 1, 2});
      // 真ん中の客が帰ったあと、次の客は空いた席に座る。
      final after = [seated[0], seated[2]];
      final next = IdleEngine.assignSeats([
        ...after,
        SeatedGuest(visit: seated[1].visit, bill: 100),
      ]);
      expect(next[0].seat, seated[0].seat);
      expect(next[1].seat, seated[2].seat);
      expect(next[2].seat, seated[1].seat);
    });

    test('雨でない時間帯には「雨の日だけ来る人」は来ない', () {
      final m = engine.world.momentAt(DateTime(2026, 9, 26, 22));
      final v = c.visitor('rain_person');
      final w = engine.visitorWeight(
        v,
        WorldMoment(
          time: m.time,
          slot: TimeSlot.night,
          weather: Weather.sunny,
          season: m.season,
        ),
        const {},
        const {},
        const {},
      );
      expect(w, 0);
      final wet = engine.visitorWeight(
        v,
        WorldMoment(
          time: m.time,
          slot: TimeSlot.night,
          weather: Weather.rain,
          season: m.season,
        ),
        const {},
        const {},
        const {},
      );
      expect(wet, greaterThan(0));
    });

    test('一か月遊ぶと、出来事がいくつも進む', () {
      // 1 日 2 回（朝と夜）開くプレイヤー。
      var s = fresh(t0).copyWith(
        placement: {
          PlacementSlot.table: 'round_table',
          PlacementSlot.window: 'lace_curtain',
          PlacementSlot.corner: 'monstera',
          PlacementSlot.light: 'stand_light',
          PlacementSlot.wall: 'bookshelf',
        },
        ownedMenus: {...c.menus.map((m) => m.id)},
      );
      var t = t0;
      for (var day = 0; day < 30; day++) {
        t = t.add(const Duration(hours: 10));
        s = engine.run(s, t).state;
        t = t.add(const Duration(hours: 14));
        s = engine.run(s, t).state;
      }
      final progressed = c.stories
          .where((x) => (s.stories[x.id]?.nextStep ?? 0) > 0)
          .length;
      expect(s.visitors.length, greaterThanOrEqualTo(4));
      expect(progressed, greaterThanOrEqualTo(3));
      // 同じ物語が同じ営業日に 2 段階進むことはない。
      for (final chain in c.stories) {
        final days = s.fragments
            .where((f) => f.chainId == chain.id)
            .map((f) => businessDateOf(f.at))
            .toList();
        expect(days.toSet().length, days.length, reason: chain.id);
      }
    });

    test('プレミアムエピソードを買っていなければ、その物語は始まらない', () {
      var s = fresh(t0);
      var t = t0;
      for (var i = 0; i < 40; i++) {
        t = t.add(const Duration(hours: 12));
        s = engine.run(s, t).state;
      }
      expect(s.stories['rain_three'], isNull);
      expect(s.visitors['photographer'], isNull);
    });
  });

  group('雰囲気', () {
    test('植物＋暖色照明＋木製テーブル で「落ち着いた店」', () {
      final r = AmbienceResolver(c);
      expect(
        r.resolve(['monstera', 'stand_light', 'round_table']).map((a) => a.id),
        contains('calm'),
      );
      expect(
        r.resolve(['monstera', 'round_table']).map((a) => a.id),
        isNot(contains('calm')),
      );
    });

    test('ネオン＋レコード＋赤いソファ で「夜の店」', () {
      final r = AmbienceResolver(c);
      expect(
        r.resolve(['neon_sign', 'record_player', 'red_sofa']).map((a) => a.id),
        contains('night'),
      );
    });
  });

  group('余白くじ', () {
    test('排出率の合計は 100%', () {
      final total = c.gacha.entries.fold<double>(
        0,
        (a, e) => a + c.gacha.rateOf(e),
      );
      expect(total, closeTo(1.0, 1e-9));
    });

    test('10 回以内に必ず未所持が出る（天井）', () {
      // 常に先頭（古いポスター）を引いてしまう最悪の乱数。
      final g = GachaEngine(c.gacha, random: _FixedRandom(0));
      final out = g.draw(times: 10, owned: {'old_poster'}, pity: 0);
      expect(out.draws.take(9).every((d) => !d.isNew), isTrue);
      expect(out.draws.last.isNew, isTrue);
      expect(out.draws.last.byPity, isTrue);
      expect(out.pityAfter, 0);
      expect(out.refund, 9 * c.gacha.duplicateRefund);
    });

    test('全部持っていれば天井は発動しない', () {
      final g = GachaEngine(c.gacha, random: _FixedRandom(0.5));
      final all = c.gacha.entries.map((e) => e.itemId).toSet();
      final out = g.draw(times: 12, owned: all, pity: 0);
      expect(out.draws.any((d) => d.isNew || d.byPity), isFalse);
    });
  });

  test('セーブデータは JSON で往復できる', () {
    final r = engine.run(fresh(t0), t0.add(const Duration(hours: 12)));
    final s = r.state.copyWith(
      pendingReport: r.report,
      activeBgm: 'bgm_rain_jazz',
    );
    final back = GameState.fromJson(
      jsonDecode(jsonEncode(s)) as Map<String, dynamic>,
    );
    expect(jsonEncode(back), jsonEncode(s));
  });

  test('コンテンツ定義の参照がすべて解決できる', () {
    for (final v in c.visitors) {
      if (v.favoriteMenuId != null) c.menu(v.favoriteMenuId!);
    }
    for (final ch in c.stories) {
      for (final id in ch.relatedVisitorIds) {
        c.visitor(id);
      }
      if (ch.rewardItemId != null) c.item(ch.rewardItemId!);
      for (final st in ch.steps) {
        if (st.condition.visitorId != null) c.visitor(st.condition.visitorId!);
        if (st.condition.menuId != null) c.menu(st.condition.menuId!);
        if (st.condition.ambience != null) c.ambience(st.condition.ambience!);
      }
    }
    for (final p in c.products) {
      for (final id in p.itemIds) {
        c.item(id);
      }
    }
    for (final e in c.gacha.entries) {
      expect(c.item(e.itemId).kind, isNotNull);
    }
    for (final i in c.items.where((i) => i.kind == ItemKind.furniture)) {
      expect(i.slot, isNotNull, reason: i.id);
    }
    // 企画書の試作品の規模：客 5 / 家具 10 / メニュー 5 / 出来事 5
    expect(c.visitors.where((v) => v.premiumEpisodeId == null).length, 5);
    expect(
      c.items
          .where(
            (i) =>
                i.source == ItemSource.initial || i.source == ItemSource.coin,
          )
          .length,
      10,
    );
    expect(c.menus.length, 5);
    expect(c.stories.where((s) => s.premiumEpisodeId == null).length, 5);
  });
}
