/// 時間・天気・季節など、シリーズ共通の「世界の状態」。
///
/// ここはタイトル（夜喫茶・古本屋・銭湯…）に依存しない。
library;

enum TimeSlot {
  morning('朝'),
  noon('昼'),
  evening('夕方'),
  night('夜'),
  lateNight('深夜'),
  closed('閉店中');

  const TimeSlot(this.label);
  final String label;
}

enum Weather {
  sunny('晴れ'),
  cloudy('曇り'),
  rain('雨'),
  shower('夕立'),
  snow('雪');

  const Weather(this.label);
  final String label;

  bool get isWet => this == rain || this == shower || this == snow;
}

enum Season {
  spring('春'),
  summer('夏'),
  autumn('秋'),
  winter('冬');

  const Season(this.label);
  final String label;

  static Season of(DateTime t) => switch (t.month) {
    3 || 4 || 5 => spring,
    6 || 7 || 8 => summer,
    9 || 10 || 11 => autumn,
    _ => winter,
  };
}

/// 営業日の区切り。深夜 0〜5 時は「前日の営業日」として数える。
const int businessDayStartHour = 5;

/// 営業日（年月日のみ）。出来事の「◯日後」判定に使う。
DateTime businessDateOf(DateTime t) {
  final shifted = t.subtract(const Duration(hours: businessDayStartHour));
  return DateTime(shifted.year, shifted.month, shifted.day);
}

int businessDaysBetween(DateTime a, DateTime b) {
  // DST の影響を避けるため UTC の日付差で数える。
  final da = businessDateOf(a);
  final db = businessDateOf(b);
  return DateTime.utc(
    db.year,
    db.month,
    db.day,
  ).difference(DateTime.utc(da.year, da.month, da.day)).inDays;
}

/// その瞬間の世界の状態。放置計算の各 tick で作られる。
class WorldMoment {
  const WorldMoment({
    required this.time,
    required this.slot,
    required this.weather,
    required this.season,
  });

  final DateTime time;
  final TimeSlot slot;
  final Weather weather;
  final Season season;

  bool get isWeekend =>
      time.weekday == DateTime.saturday || time.weekday == DateTime.sunday;
  bool get isFriday => time.weekday == DateTime.friday;
}
