import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/core/persistence/database.dart';
import 'package:yoru_kissa/core/persistence/save_repository.dart';
import 'package:yoru_kissa/core/services/analytics.dart';
import 'package:yoru_kissa/core/state/game_state.dart';
import 'package:yoru_kissa/titles/yoru_kissa/content.dart';

void main() {
  late YohakuDatabase db;
  setUp(() => db = YohakuDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> logAt(DateTime at, void Function(Analytics a) f) async {
    final sink = DriftAnalyticsSink(db);
    final a = Analytics([sink], clock: () => at);
    f(a);
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  test('試遊ログから「翌日も開いたか」「1 回の長さ」がわかる', () async {
    final d1 = DateTime(2026, 9, 26, 8);
    await logAt(d1, (a) => a.sessionStart());
    await logAt(
      d1.add(const Duration(minutes: 2)),
      (a) => a.sessionEnd(const Duration(seconds: 100)),
    );
    await logAt(d1.add(const Duration(hours: 13)), (a) {
      a.sessionStart(sinceLast: const Duration(hours: 13));
      a.eventSeen('red_umbrella', 0);
      a.visitorOpened('rain_person');
    });
    await logAt(
      d1.add(const Duration(hours: 13, minutes: 3)),
      (a) => a.sessionEnd(const Duration(seconds: 180)),
    );
    var p = await PlaytestSummary.of(db);
    expect(p.returnedNextDay, isFalse); // まだ同じ日
    expect(p.sessions, 2);

    final d2 = DateTime(2026, 9, 27, 7, 30);
    await logAt(d2, (a) {
      a.sessionStart();
      a.zukanTab(3);
    });
    await logAt(
      d2.add(const Duration(seconds: 40)),
      (a) => a.sessionEnd(const Duration(seconds: 40)),
    );
    p = await PlaytestSummary.of(db);
    expect(p.returnedNextDay, isTrue);
    expect(p.daysPlayed, 2);
    expect(p.medianSessionSeconds, 100);
    expect(p.eventsSeen, 1);
    expect(p.visitorOpens, 1);
    expect(p.zukanOpens, 1);
    expect(await PlaytestSummary.export(db), contains('"name":"event_seen"'));
  });

  test('セーブデータを消しても、試遊ログは残る', () async {
    await logAt(DateTime(2026, 9, 26), (a) => a.sessionStart());
    final store = DriftSaveStore(db);
    await store.save(GameState.initial(yoruKissa, DateTime(2026, 9, 26)));
    await store.clear();
    expect(await store.load(), isNull);
    expect((await PlaytestSummary.of(db)).sessions, 1);
  });

  test('送り先が失敗しても、ゲームは止まらない', () async {
    final a = Analytics([_Broken()]);
    a.sessionStart();
    await Future<void>.delayed(const Duration(milliseconds: 10));
  });
}

class _Broken implements AnalyticsSink {
  @override
  Future<void> log(String name, Map<String, Object?> params, DateTime at) =>
      Future.error('offline');
}
