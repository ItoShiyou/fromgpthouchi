import 'dart:math' as math;

import '../models/content.dart';

class GachaDraw {
  const GachaDraw({
    required this.entry,
    required this.isNew,
    required this.byPity,
  });

  final GachaEntry entry;
  final bool isNew;

  /// 天井によって未所持が確定した回か。
  final bool byPity;
}

class GachaOutcome {
  const GachaOutcome({
    required this.draws,
    required this.pityAfter,
    required this.refund,
  });

  final List<GachaDraw> draws;
  final int pityAfter;
  final int refund;
}

/// 余白くじ。
///
/// - 出るのは家具・小物・BGM・演出だけ。性能は上がらない。
/// - 排出率は [GachaDef.rarityRates] と [GachaDef.rateOf] で事前に表示する。
/// - [GachaDef.pityCount] 回のうちに未所持が出なければ、次は必ず未所持（天井）。
/// - 「A+B+C を揃えたら報酬」のようなコンプリート要素は持たない。
class GachaEngine {
  GachaEngine(this.def, {math.Random? random})
    : _random = random ?? math.Random();

  final GachaDef def;
  final math.Random _random;

  GachaOutcome draw({
    required int times,
    required Set<String> owned,
    required int pity,
  }) {
    final ownedNow = Set.of(owned);
    final draws = <GachaDraw>[];
    var p = pity;
    var refund = 0;
    for (var i = 0; i < times; i++) {
      final unowned = def.entries
          .where((e) => !ownedNow.contains(e.itemId))
          .toList();
      final pityHit = p >= def.pityCount - 1 && unowned.isNotEmpty;
      final pool = pityHit ? unowned : def.entries;
      final entry = _pick(pool);
      final isNew = ownedNow.add(entry.itemId);
      if (!isNew) refund += def.duplicateRefund;
      p = isNew ? 0 : p + 1;
      draws.add(GachaDraw(entry: entry, isNew: isNew, byPity: pityHit));
    }
    return GachaOutcome(draws: draws, pityAfter: p, refund: refund);
  }

  GachaEntry _pick(List<GachaEntry> pool) {
    final total = pool.fold<double>(0, (a, e) => a + def.rateOf(e));
    var r = _random.nextDouble() * total;
    for (final e in pool) {
      r -= def.rateOf(e);
      if (r < 0) return e;
    }
    return pool.last;
  }
}
