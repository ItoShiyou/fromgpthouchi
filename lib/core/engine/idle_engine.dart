import 'dart:math' as math;

import '../models/content.dart';
import '../models/world.dart';
import '../state/game_state.dart';
import 'ambience.dart';
import 'seeded_random.dart';
import 'world_engine.dart';

class IdleResult {
  const IdleResult(this.state, this.report);

  final GameState state;
  final IdleReport report;
}

/// 放置計算。
///
/// ```text
/// elapsed          = now - lastSimulatedAt
/// effectiveElapsed = min(elapsed, 12h)
/// ```
///
/// 時間を固定長の tick（既定 5 分）に区切り、各 tick の境界時刻から
/// visitorSeed / eventSeed を作って「その時刻に誰が来て何が起きたか」を決める。
/// tick は絶対時刻で区切るので、何回に分けて起動しても結果は同じ。
/// 12 時間を超えた分は「損」ではなく単に数えないだけ。
/// 出来事の日数判定は実時間の営業日で行うので、長く離れていても物語は進む。
class IdleEngine {
  IdleEngine(this.content)
    : world = WorldEngine(content),
      ambience = AmbienceResolver(content);

  final TitleContent content;
  final WorldEngine world;
  final AmbienceResolver ambience;

  static const int maxSeated = 3;
  static const int maxRecentVisits = 60;
  static const double ticketDropChance = 0.01;
  static const int _visitorSalt = 0x71517;
  static const int _eventSalt = 0xE7E7;

  IdleResult run(GameState s, DateTime now) {
    final from = s.lastSimulatedAt;
    final elapsed = now.isAfter(from) ? now.difference(from) : Duration.zero;
    final effective = elapsed > content.maxIdle ? content.maxIdle : elapsed;
    final windowStart = now.subtract(effective);

    final placed = s.placement.values.toList();
    final ambiences = ambience.resolve(placed).map((a) => a.id).toSet();

    final visitors = Map.of(s.visitors);
    final stories = Map.of(s.stories);
    final fragments = List.of(s.fragments);
    final ownedItems = Set.of(s.ownedItems);
    final newVisits = <Visit>[];
    final newVisitorIds = <String>[];
    final newFragments = <DiscoveredFragment>[];
    final itemsFound = <String>[];
    var income = 0;
    var tickets = 0;

    final tickMs = content.tick.inMilliseconds;
    final firstTick = windowStart.millisecondsSinceEpoch ~/ tickMs + 1;
    final lastTick = now.millisecondsSinceEpoch ~/ tickMs;

    for (var k = firstTick; k <= lastTick; k++) {
      final t = DateTime.fromMillisecondsSinceEpoch(k * tickMs);
      final m = world.momentAt(t);
      if (m.slot == TimeSlot.closed) continue;

      // --- 来店 -------------------------------------------------------------
      final vr = SeededRandom.of([content.seed, _visitorSalt, k]);
      Visit? visit;
      final p =
          content.visitChancePerTick *
          (m.weather.isWet ? 0.85 : 1.0) *
          (1 + 0.08 * ambiences.length);
      if (vr.nextDouble() < p) {
        final weights = <String, double>{'': content.anonymousWeight};
        for (final v in content.visitors) {
          final w = visitorWeight(v, m, ambiences, s.ownedMenus, s.episodes);
          if (w > 0) weights[v.id] = w;
        }
        final picked = vr.weighted(weights)!;
        final visitorId = picked.isEmpty ? null : picked;
        final def = visitorId == null ? null : content.visitor(visitorId);
        final orderable = [
          for (final menu in content.menus)
            if (s.ownedMenus.contains(menu.id)) menu.id,
        ];
        final fav = def?.favoriteMenuId;
        final orderedFavorite =
            fav != null && s.ownedMenus.contains(fav) && vr.nextDouble() < 0.7;
        final menuId = orderedFavorite ? fav : vr.pick(orderable);

        visit = Visit(at: t, visitorId: visitorId, menuId: menuId);
        newVisits.add(visit);
        income += content.menu(menuId).price;

        if (visitorId != null) {
          final prev = visitors[visitorId];
          if (prev == null) {
            newVisitorIds.add(visitorId);
            visitors[visitorId] = VisitorRecord(
              visits: 1,
              firstSeenAt: t,
              lastSeenAt: t,
              favoriteKnown: orderedFavorite,
            );
          } else {
            visitors[visitorId] = prev.copyWith(
              visits: prev.visits + 1,
              lastSeenAt: t,
              favoriteKnown: prev.favoriteKnown || orderedFavorite,
            );
          }
        }
        if (vr.nextDouble() < ticketDropChance) tickets++;
      }

      // --- 出来事 -----------------------------------------------------------
      final er = SeededRandom.of([content.seed, _eventSalt, k]);
      for (final chain in content.stories) {
        if (chain.premiumEpisodeId != null &&
            !s.episodes.contains(chain.premiumEpisodeId)) {
          continue;
        }
        final prog =
            stories[chain.id] ??
            const StoryProgress(nextStep: 0, lastStepAt: null);
        if (prog.nextStep >= chain.steps.length) continue;
        final step = chain.steps[prog.nextStep];
        if (!_conditionMet(step.condition, prog, m, ambiences, s, visit)) {
          continue;
        }
        if (er.nextDouble() >= step.condition.chancePerTick) continue;

        final frag = DiscoveredFragment(
          chainId: chain.id,
          step: prog.nextStep,
          at: t,
        );
        fragments.add(frag);
        newFragments.add(frag);
        stories[chain.id] = StoryProgress(
          nextStep: prog.nextStep + 1,
          lastStepAt: t,
        );
        if (prog.nextStep + 1 == chain.steps.length) {
          tickets += chain.rewardTickets;
          final reward = chain.rewardItemId;
          if (reward != null && ownedItems.add(reward)) itemsFound.add(reward);
        }
        break; // 1 tick に起きる出来事は 1 つだけ。
      }
    }

    // 1 営業日に 1 枚、余白くじチケットを配る（ログインボーナスではなく
    // 「開いたらもらえる」程度。取り逃しても溜めない代わりに罰もない）。
    final today = _dateKey(businessDateOf(now));
    var dailyTicketDate = s.lastDailyTicketDate;
    if (dailyTicketDate != today) {
      tickets++;
      dailyTicketDate = today;
    }

    // 最新の数人は店内に座らせて、タップで回収させる。残りはレジへ。
    final guests = [
      ...s.seated,
      for (final v in newVisits)
        SeatedGuest(visit: v, bill: content.menu(v.menuId).price),
    ];
    final seatedCount = math.min(maxSeated, guests.length);
    final seated = assignSeats(guests.sublist(guests.length - seatedCount));
    final toRegister = guests
        .sublist(0, guests.length - seatedCount)
        .fold<int>(0, (sum, g) => sum + g.bill);

    final recent = [
      ...newVisits.reversed,
      ...s.recentVisits,
    ].take(maxRecentVisits).toList();

    final report = IdleReport(
      from: from,
      to: now,
      elapsed: elapsed,
      effective: effective,
      income: income,
      visitCount: newVisits.length,
      newVisitorIds: newVisitorIds,
      newFragments: newFragments,
      ticketsEarned: tickets,
      itemsFound: itemsFound,
    );

    final next = s.copyWith(
      register: s.register + toRegister,
      seated: seated,
      tickets: s.tickets + tickets,
      visitors: visitors,
      stories: stories,
      fragments: fragments,
      ownedItems: ownedItems,
      recentVisits: recent,
      lastSimulatedAt: now,
      lastDailyTicketDate: dailyTicketDate,
    );
    return IdleResult(next, report);
  }

  /// このまま閉じておいたら、次の出来事はいつ起きるか。
  ///
  /// 乱数が時刻で決まるので、店の模様替えなどをしない限り予測は外れない。
  /// 通知は「出来事が起きた時だけ」送るので、この時刻に 1 件だけ予約する。
  DiscoveredFragment? predictNextEvent(
    GameState s,
    DateTime now, {
    Duration? horizon,
  }) {
    final h = horizon ?? content.maxIdle;
    final r = run(s.copyWith(lastSimulatedAt: now), now.add(h));
    final f = r.report.newFragments;
    return f.isEmpty ? null : f.first;
  }

  /// 席が決まっている客はそのまま、新しい客は空いている席に座らせる。
  static List<SeatedGuest> assignSeats(List<SeatedGuest> guests) {
    final used = <int>{};
    final kept = [
      for (final g in guests)
        if (g.seat >= 0 && g.seat < maxSeated && used.add(g.seat)) g else null,
    ];
    var next = 0;
    return [
      for (var i = 0; i < guests.length; i++)
        kept[i] ??
            () {
              while (used.contains(next)) {
                next++;
              }
              used.add(next);
              return guests[i].withSeat(next);
            }(),
    ];
  }

  /// 客の出現しやすさ。0 なら来ない。
  double visitorWeight(
    VisitorDef v,
    WorldMoment m,
    Set<String> ambiences,
    Set<String> ownedMenus,
    Set<String> episodes,
  ) {
    if (v.premiumEpisodeId != null && !episodes.contains(v.premiumEpisodeId)) {
      return 0;
    }
    if (!v.slots.contains(m.slot)) return 0;
    if (v.weathers != null && !v.weathers!.contains(m.weather)) return 0;
    if (v.requiredAmbience != null && !ambiences.contains(v.requiredAmbience)) {
      return 0;
    }
    var w = v.baseWeight * (v.weatherBoost[m.weather] ?? 1.0);
    for (final a in ambiences) {
      w *= v.ambienceBoost[a] ?? 1.0;
    }
    w *= m.isWeekend ? v.weekendBoost : v.weekdayBoost;
    if (m.isFriday) w *= v.fridayBoost;
    final fav = v.favoriteMenuId;
    if (fav != null && ownedMenus.contains(fav)) w *= 1.3;
    return w;
  }

  bool _conditionMet(
    StoryCondition c,
    StoryProgress prog,
    WorldMoment m,
    Set<String> ambiences,
    GameState s,
    Visit? visit,
  ) {
    if (c.slots != null && !c.slots!.contains(m.slot)) return false;
    if (c.weathers != null && !c.weathers!.contains(m.weather)) return false;
    if (c.ambience != null && !ambiences.contains(c.ambience)) return false;
    if (c.menuId != null && !s.ownedMenus.contains(c.menuId)) return false;
    if (c.visitorId != null && visit?.visitorId != c.visitorId) return false;
    final last = prog.lastStepAt;
    if (last != null) {
      // 同じ営業日に同じ物語が 2 段階進むことはない。
      final gap = math.max(1, c.minDaysSincePrevious);
      if (businessDaysBetween(last, m.time) < gap) return false;
    }
    return true;
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
