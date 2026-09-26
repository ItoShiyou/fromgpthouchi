import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../persistence/database.dart';

/// 記録の送り先。いまは端末内（試遊ログ）だけ。
/// Firebase Analytics を入れる時は、これを実装したものを Analytics に足すだけ。
abstract interface class AnalyticsSink {
  Future<void> log(String name, Map<String, Object?> params, DateTime at);
}

class DriftAnalyticsSink implements AnalyticsSink {
  DriftAnalyticsSink(this.db);

  final YohakuDatabase db;

  @override
  Future<void> log(String name, Map<String, Object?> params, DateTime at) => db
      .into(db.analyticsEvents)
      .insert(
        AnalyticsEventsCompanion.insert(
          at: at,
          name: name,
          paramsJson: jsonEncode(params),
        ),
      );
}

/// 試遊で見たいこと（SPEC 9 章）を記録する。
///
/// 見たいのは「翌日また開くか」「1 回が 2 分前後か」「出来事の続きが気になっているか」。
class Analytics {
  Analytics(this.sinks, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final List<AnalyticsSink> sinks;
  final DateTime Function() _clock;

  void log(String name, [Map<String, Object?> params = const {}]) {
    final at = _clock();
    for (final s in sinks) {
      unawaited(s.log(name, params, at).catchError((Object _) {}));
    }
  }

  void sessionStart({Duration? sinceLast}) =>
      log('session_start', {'since_last_min': sinceLast?.inMinutes});
  void sessionEnd(Duration length) =>
      log('session_end', {'seconds': length.inSeconds});
  void reportShown({
    required int minutes,
    required int income,
    required int visits,
    required int events,
  }) => log('report_shown', {
    'minutes': minutes,
    'income': income,
    'visits': visits,
    'events': events,
  });
  void eventSeen(String chainId, int step) =>
      log('event_seen', {'chain': chainId, 'step': step});
  void visitorOpened(String visitorId) =>
      log('visitor_opened', {'visitor': visitorId});
  void zukanTab(int tab) => log('zukan_tab', {'tab': tab});
  void furnitureBought(String itemId, List<String> ambiencesAfter) =>
      log('furniture_bought', {'item': itemId, 'ambiences': ambiencesAfter});
  void menuLearned(String menuId) => log('menu_learned', {'menu': menuId});
  void gachaDrawn(int times, int newItems) =>
      log('gacha_drawn', {'times': times, 'new': newItems});
  void purchased(String productId, {required bool restored}) =>
      log('purchase', {'product': productId, 'restored': restored});
}

/// 試遊ログのまとめ（設定画面に出す）。
class PlaytestSummary {
  const PlaytestSummary({
    required this.firstDay,
    required this.daysPlayed,
    required this.sessions,
    required this.medianSessionSeconds,
    required this.returnedNextDay,
    required this.eventsSeen,
    required this.visitorOpens,
    required this.zukanOpens,
  });

  final DateTime? firstDay;
  final int daysPlayed;
  final int sessions;
  final int? medianSessionSeconds;

  /// 初日の翌日にも開いたか（D1）。
  final bool returnedNextDay;
  final int eventsSeen;
  final int visitorOpens;
  final int zukanOpens;

  static Future<PlaytestSummary> of(YohakuDatabase db) async {
    final rows = await (db.select(
      db.analyticsEvents,
    )..orderBy([(t) => OrderingTerm.asc(t.at)])).get();
    DateTime day(DateTime t) => DateTime(t.year, t.month, t.day);
    final starts = rows.where((r) => r.name == 'session_start').toList();
    final days = {for (final r in starts) day(r.at)};
    final first = starts.isEmpty ? null : day(starts.first.at);
    final lengths = [
      for (final r in rows.where((r) => r.name == 'session_end'))
        (jsonDecode(r.paramsJson) as Map<String, dynamic>)['seconds'] as int,
    ]..sort();
    return PlaytestSummary(
      firstDay: first,
      daysPlayed: days.length,
      sessions: starts.length,
      medianSessionSeconds: lengths.isEmpty
          ? null
          : lengths[lengths.length ~/ 2],
      returnedNextDay:
          first != null && days.contains(first.add(const Duration(days: 1))),
      eventsSeen: rows.where((r) => r.name == 'event_seen').length,
      visitorOpens: rows.where((r) => r.name == 'visitor_opened').length,
      zukanOpens: rows.where((r) => r.name == 'zukan_tab').length,
    );
  }

  /// 書き出し用（試遊してくれた人から送ってもらう）。
  static Future<String> export(YohakuDatabase db) async {
    final rows = await (db.select(
      db.analyticsEvents,
    )..orderBy([(t) => OrderingTerm.asc(t.at)])).get();
    return jsonEncode([
      for (final r in rows)
        {
          'at': r.at.toIso8601String(),
          'name': r.name,
          ...jsonDecode(r.paramsJson) as Map<String, dynamic>,
        },
    ]);
  }
}
