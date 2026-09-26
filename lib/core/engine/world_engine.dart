import '../models/content.dart';
import '../models/world.dart';
import 'seeded_random.dart';

/// 時刻から時間帯・天気・季節を決める。
class WorldEngine {
  const WorldEngine(this.content);

  final TitleContent content;

  static TimeSlot rawSlotOf(DateTime t) {
    final h = t.hour;
    if (h >= 5 && h < 11) return TimeSlot.morning;
    if (h >= 11 && h < 17) return TimeSlot.noon;
    if (h >= 17 && h < 20) return TimeSlot.evening;
    if (h >= 20) return TimeSlot.night;
    return TimeSlot.lateNight;
  }

  /// 閉店時間帯を考慮した時間帯。
  TimeSlot slotOf(DateTime t) {
    final raw = rawSlotOf(t);
    return content.openSlots.contains(raw) ? raw : TimeSlot.closed;
  }

  /// 天気は 3 時間ごとに変わる。日付と時間帯ブロックから決定的に決まる
  /// （weatherSeed）。
  Weather weatherAt(DateTime t) {
    final block = t.hour ~/ 3;
    final rng = SeededRandom.of([
      content.seed,
      0x57EA,
      t.year,
      t.month,
      t.day,
      block,
    ]);
    final season = Season.of(t);
    final afternoon = t.hour >= 12 && t.hour < 18;
    final table = <Weather, double>{
      Weather.sunny: 40,
      Weather.cloudy: 25,
      Weather.rain: season == Season.summer ? 12 : 22,
      if (season == Season.summer && afternoon) Weather.shower: 15,
      if (season == Season.winter) Weather.snow: 12,
    };
    return rng.weighted(table)!;
  }

  WorldMoment momentAt(DateTime t) => WorldMoment(
    time: t,
    slot: slotOf(t),
    weather: weatherAt(t),
    season: Season.of(t),
  );
}
