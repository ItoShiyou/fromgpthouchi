import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/handdrawn.dart';

import '../../core/brand/theme.dart';
import '../../core/services/ads.dart';
import '../../core/services/sound.dart';
import '../../core/state/game_controller.dart';
import '../../core/state/purchase_controller.dart';
import '../../titles/yoru_kissa/cafe_scene.dart';
import '../../widgets/common.dart';
import '../../widgets/portrait.dart';
import '../furniture/furniture_screen.dart';
import '../gacha/gacha_screen.dart';
import '../menu/menu_screen.dart';
import '../report/event_dialog.dart';
import '../report/report_dialog.dart';
import '../settings/settings_screen.dart';
import '../shop/shop_screen.dart';
import '../visitors/visitor_detail_screen.dart';
import '../visitors/visitor_list_screen.dart';
import '../visitors/visitor_naming.dart';
import '../zukan/zukan_screen.dart';

/// 01. ホーム ― 店そのもの。ここが常に基点になる。
///
/// 起動・復帰時に放置時間を精算して「おかえりなさい」を出し、
/// 開いている間も 20 秒ごとに時間を進める（新しい客が座る）。
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;
  bool _dialogOpen = false;

  static const _liveInterval = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ストアが起動時に届け直す購入（中断された支払いなど）を受け取れるようにする
      ref.read(purchaseProvider);
      _applySound();
      final pending = ref.read(gameProvider).pendingReport;
      ref.read(gameProvider.notifier).catchUp(showReport: true);
      // 前回開いたまま閉じた「おかえりなさい」は、精算しても listen が発火しない。
      if (pending != null) _showReport();
    });
    _ticker = Timer.periodic(_liveInterval, (_) {
      ref.read(gameProvider.notifier).catchUp(showReport: false);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = ref.read(gameProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(soundProvider).resume();
        ctrl.cancelNotification();
        ctrl.catchUp(showReport: true);
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        ref.read(soundProvider).pause();
        ctrl.flush();
        ctrl.planNotification();
      default:
        break;
    }
  }

  Future<void> _showReport() async {
    if (_dialogOpen) return;
    final report = ref.read(gameProvider).pendingReport;
    if (report == null) return;
    _dialogOpen = true;
    Navigator.of(context).popUntil((r) => r.isFirst);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ReportDialog(report: report),
    );
    _dialogOpen = false;
    ref.read(gameProvider.notifier).dismissReport();
    // 出来事は「おかえりなさい」のあとに 1 つずつ見せる。
    ref.read(eventQueueProvider.notifier).addAll(report.newFragments);
    _showEvents();
  }

  Future<void> _showEvents() async {
    if (_dialogOpen || !mounted) return;
    final queue = ref.read(eventQueueProvider);
    if (queue.isEmpty) return;
    _dialogOpen = true;
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black45,
      builder: (_) => EventDialog(fragment: queue.first),
    );
    _dialogOpen = false;
    ref.read(eventQueueProvider.notifier).pop();
    if (ref.read(eventQueueProvider).isEmpty) {
      // 出来事を見た直後なら、通知の意味が伝わる。ここで初めて許可を求める
      // （OS は一度答えた人には二度と聞かないので、何度呼んでもよい）。
      ref.read(gameProvider.notifier).requestNotificationPermission();
    }
    _showEvents();
  }

  void _push(Widget page) {
    ref.read(soundProvider).play(Se.paper);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  /// 選んでいる BGM と、設定の音のオン／オフに合わせる。
  void _applySound() {
    final s = ref.read(gameProvider);
    ref
        .read(soundProvider)
        .apply(
          asset: ref.read(gameProvider.notifier).bgmAsset(),
          bgmOn: s.settings.bgmOn,
          seOn: s.settings.seOn,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameProvider.select((s) => s.pendingReport), (prev, next) {
      if (next != null) _showReport();
    });
    ref.listen(
      gameProvider.select(
        (s) => (s.activeBgm, s.settings.bgmOn, s.settings.seOn),
      ),
      (prev, next) => _applySound(),
    );
    ref.listen(eventQueueProvider, (prev, next) {
      if (next.isNotEmpty) _showEvents();
    });
    ref.listen(noticeProvider, (prev, next) {
      if (next == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(next)));
      ref.read(noticeProvider.notifier).clear();
    });

    final s = ref.watch(gameProvider);
    ref.watch(weatherPreviewProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final content = ref.watch(contentProvider);
    final ambiences = ref.watch(ambiencesProvider);
    final m = ctrl.currentMoment();
    final level = ShopLevel.of(s);

    return Scaffold(
      backgroundColor: YohakuColors.nightDeep,
      body: Stack(
        children: [
          Positioned.fill(
            child: CafeScene(
              content: content,
              moment: m,
              placement: s.placement,
              effects: s.activeEffects,
              seated: s.seated,
              onGuestTap: _tapGuest,
            ),
          ),
          // 上部 HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 6, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LevelCard(
                    level: level,
                    caption:
                        '${m.time.hour.toString().padLeft(2, '0')}:${m.time.minute.toString().padLeft(2, '0')}  ${m.slot.label}・${m.weather.label}',
                  ),
                  const Spacer(),
                  _HudPill(icon: Sketch.coin, label: yen(s.money).substring(1)),
                  const SizedBox(width: 6),
                  _HudPill(icon: Sketch.ticket, label: '${s.tickets}'),
                  IconButton(
                    tooltip: '設定',
                    icon: const SketchIcon(
                      Sketch.gear,
                      color: YohakuColors.paper,
                      size: 26,
                    ),
                    onPressed: () => _push(const SettingsScreen()),
                  ),
                ],
              ),
            ),
          ),
          // 下部：レジ・雰囲気・アイコン列
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (ambiences.isNotEmpty || s.activeBgm != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final a in ambiences) _GlassChip(a.name),
                            if (s.activeBgm != null)
                              _GlassChip(
                                '♪ ${content.item(s.activeBgm!).name.replaceFirst('BGM：', '')}',
                              ),
                          ],
                        ),
                      ),
                    _RegisterBar(
                      amount: s.register,
                      hint: s.seated.isEmpty ? 'お客さんを待っています' : 'お客さんをタップしてお会計',
                      onCollect: s.register == 0
                          ? null
                          : () {
                              final got = ctrl.collectRegister();
                              ref.read(soundProvider).play(Se.coin);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${yen(got)} を回収しました')),
                              );
                            },
                    ),
                    if (!s.adFree) ...[
                      const SizedBox(height: 6),
                      const Center(
                        child: ShopBanner(placeholder: AdBannerMock()),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _BarButton(
                          glyph: '客',
                          label: 'お客様',
                          onTap: () => _push(const VisitorListScreen()),
                        ),
                        _BarButton(
                          glyph: '鑑',
                          label: '図鑑',
                          onTap: () => _push(const ZukanScreen()),
                        ),
                        _BarButton(
                          glyph: '具',
                          label: '家具',
                          onTap: () => _push(const FurnitureScreen()),
                        ),
                        _BarButton(
                          glyph: '品',
                          label: 'メニュー',
                          onTap: () => _push(const MenuScreen()),
                        ),
                        _BarButton(
                          glyph: '籤',
                          label: 'くじ',
                          onTap: () => _push(const GachaScreen()),
                        ),
                        _BarButton(
                          glyph: '店',
                          label: 'ショップ',
                          onTap: () => _push(const ShopScreen()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tapGuest(int index) {
    final ctrl = ref.read(gameProvider.notifier);
    final content = ref.read(contentProvider);
    final guest = ctrl.collectGuest(index);
    if (guest == null) return;
    ref.read(soundProvider).play(Se.coin);
    final id = guest.visit.visitorId;
    final def = id == null ? null : content.visitor(id);
    final rec = id == null ? null : ref.read(gameProvider).visitors[id];
    final line = def == null
        ? 'ごちそうさまでした。'
        : def.lines[guest.visit.at.minute % def.lines.length];
    showDialog<void>(
      context: context,
      barrierColor: Colors.black38,
      builder: (ctx) => PaperDialog(
        buttonLabel: '閉じる',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Portrait(
                  visitorId: id,
                  look:
                      def?.look ??
                      anonymousLook(
                        guest.visit.at.millisecondsSinceEpoch ~/ 60000,
                      ),
                  size: 52,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        def == null
                            ? '通りすがりのお客さん'
                            : visitorDisplayName(def, rec),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (rec != null)
                        Text(
                          '来店 ${rec.visits} 回',
                          style: const TextStyle(
                            fontSize: 11,
                            color: YohakuColors.inkDim,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('「$line」', style: const TextStyle(height: 1.8)),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  content.menu(guest.visit.menuId).name,
                  style: const TextStyle(color: YohakuColors.inkDim),
                ),
                const Spacer(),
                Text(
                  '+${yen(guest.bill)}',
                  style: const TextStyle(
                    color: YohakuColors.wood,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (id != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _push(VisitorDetailScreen(visitorId: id));
                  },
                  child: const Text('この人のこと'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _glass = Color(0xB3261B14);

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.caption});

  final ShopLevel level;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: ShapeDecoration(
        color: _glass,
        shape: RoughBorder(radius: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const InkGlyph('店', size: 18, color: YohakuColors.lamp),
              const SizedBox(width: 4),
              Text(
                'Lv.${level.level}',
                style: const TextStyle(
                  color: YohakuColors.paper,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ProgressLine(
            value: level.progress,
            color: YohakuColors.moss,
            height: 5,
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: const TextStyle(fontSize: 10, color: Color(0xCCF5EDE0)),
          ),
        ],
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.icon, required this.label});

  final Sketch icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
      decoration: ShapeDecoration(
        color: _glass,
        shape: RoughBorder(radius: 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SketchIcon(icon, size: 20, color: const Color(0xFF2A1B12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: YohakuColors.paper,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: ShapeDecoration(
        color: _glass,
        shape: RoughBorder(
          radius: 20,
          side: BorderSide(color: YohakuColors.lamp.withValues(alpha: 0.6)),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: YohakuColors.cream),
      ),
    );
  }
}

class _RegisterBar extends StatelessWidget {
  const _RegisterBar({
    required this.amount,
    required this.hint,
    required this.onCollect,
  });

  final int amount;
  final String hint;
  final VoidCallback? onCollect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: ShapeDecoration(
        color: YohakuColors.paper.withValues(alpha: 0.94),
        shape: RoughBorder(radius: 16),
      ),
      child: Row(
        children: [
          const InkGlyph('会', size: 30, color: YohakuColors.wood),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'レジ  ${yen(amount)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 10,
                    color: YohakuColors.inkDim,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 34,
            child: FilledButton(onPressed: onCollect, child: const Text('回収')),
          ),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({
    required this.glyph,
    required this.label,
    required this.onTap,
  });

  final String glyph;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: _glass,
          shape: RoughBorder(
            radius: 12,
            side: BorderSide(color: YohakuColors.cream.withValues(alpha: 0.55)),
          ),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 58,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkGlyph(glyph, size: 30, color: YohakuColors.cream),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: YohakuColors.cream,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
