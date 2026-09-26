import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/core/engine/idle_engine.dart';
import 'package:yoru_kissa/core/persistence/save_repository.dart';
import 'package:yoru_kissa/core/services/event_notifier.dart';
import 'package:yoru_kissa/core/state/game_controller.dart';
import 'package:yoru_kissa/core/state/game_state.dart';
import 'package:yoru_kissa/titles/yoru_kissa/content.dart';

class _FakeNotifier implements EventNotifier {
  final scheduled = <(DateTime, String)>[];
  int cancels = 0;

  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> scheduleOnly(
    DateTime at, {
    required String title,
    required String body,
  }) async {
    scheduled.add((at, body));
  }

  @override
  Future<void> cancel() async => cancels++;
}

class _NullStore implements SaveStore {
  @override
  Future<void> clear() async {}

  @override
  Future<GameState?> load() async => null;

  @override
  Future<void> save(GameState s) async {}
}

void main() {
  ProviderContainer make(_FakeNotifier n, {bool notificationsOn = true}) {
    final s = GameState.initial(
      yoruKissa,
      DateTime.now(),
    ).copyWith(settings: GameSettings(notificationsOn: notificationsOn));
    return ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(SaveRepository(_NullStore())),
        initialGameStateProvider.overrideWithValue(s),
        eventNotifierProvider.overrideWithValue(n),
      ],
    );
  }

  test('裏に回る時、次の出来事の時刻に 1 件だけ予約する', () async {
    final n = _FakeNotifier();
    final c = make(n);
    final ctrl = c.read(gameProvider.notifier);
    // 1 か月先まで見て、予測が出る状態で試す
    var tries = 0;
    while (IdleEngine(yoruKissa)
                .predictNextEvent(c.read(gameProvider), ctrl.now()) ==
            null &&
        tries++ < 60) {
      ctrl.debugAdvance(const Duration(hours: 12));
    }
    final predicted = IdleEngine(yoruKissa)
        .predictNextEvent(c.read(gameProvider), ctrl.now())!;
    await ctrl.planNotification();
    expect(n.scheduled, hasLength(1));
    // 時間送りの分を差し引いた、実際の時刻で予約される
    expect(
      n.scheduled.single.$1,
      predicted.at.subtract(
        Duration(minutes: c.read(gameProvider).debugOffsetMinutes),
      ),
    );
    c.dispose();
  });

  test('通知をオフにしていれば予約しない', () async {
    final n = _FakeNotifier();
    final c = make(n, notificationsOn: false);
    await c.read(gameProvider.notifier).planNotification();
    expect(n.scheduled, isEmpty);
    expect(n.cancels, 1);
    c.dispose();
  });
}
