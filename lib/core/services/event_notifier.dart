import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// 出来事の通知。
///
/// 送るのは「出来事が起きる時」の 1 件だけ。ログインを促す通知・毎日の定時通知は作らない。
/// 起きる時刻は放置計算で正確に予測できる（IdleEngine.predictNextEvent）。
abstract interface class EventNotifier {
  Future<void> init();

  /// 許可を求める。出来事を初めて見た直後など、理由が伝わる時にだけ呼ぶ。
  Future<void> requestPermission();

  /// 予約済みの通知を消して、[at] に 1 件だけ予約する。
  Future<void> scheduleOnly(
    DateTime at, {
    required String title,
    required String body,
  });

  Future<void> cancel();
}

/// Web・テストでは何もしない。
class NoopEventNotifier implements EventNotifier {
  const NoopEventNotifier();

  @override
  Future<void> init() async {}

  @override
  Future<void> requestPermission() async {}

  @override
  Future<void> scheduleOnly(
    DateTime at, {
    required String title,
    required String body,
  }) async {}

  @override
  Future<void> cancel() async {}
}

class LocalEventNotifier implements EventNotifier {
  final _plugin = FlutterLocalNotificationsPlugin();
  static const _id = 1;
  bool _ready = false;

  @override
  Future<void> init() async {
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // 起動時には許可を求めない
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  @override
  Future<void> requestPermission() async {
    if (!_ready) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true);
  }

  @override
  Future<void> scheduleOnly(
    DateTime at, {
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    await cancel();
    // 時刻は UTC に直して予約するので、端末のタイムゾーン設定に依存しない。
    await _plugin.zonedSchedule(
      id: _id,
      scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'events',
          '出来事',
          channelDescription: 'お店で何かが起きた時だけ届きます',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // 正確なアラームの権限は求めない（数分ずれても困らない）。
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancel() async {
    if (!_ready) return;
    await _plugin.cancel(id: _id);
  }
}

EventNotifier createEventNotifier() =>
    kIsWeb ? const NoopEventNotifier() : LocalEventNotifier();
