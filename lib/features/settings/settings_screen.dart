import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/handdrawn.dart';

import '../../core/brand/theme.dart';
import '../../core/models/world.dart';
import '../../core/persistence/database.dart';
import '../../core/services/ads.dart';
import '../../core/services/analytics.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';
import '../series/series_screen.dart';

/// 10. 設定 ― 音・通知・バックアップなど。
/// モック用に「時間を進める」「天気を見る」デバッグ機能を置いている。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final c = ref.watch(contentProvider);
    final preview = ref.watch(weatherPreviewProvider);

    void advance(Duration d) {
      // 先に閉じてから時間を進める（「おかえりなさい」をお店の上に出すため）。
      Navigator.of(context).pop();
      ctrl.debugAdvance(d);
    }

    Widget group(List<Widget> children) => PaperCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );

    return PaperPage(
      title: '設定',
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
        children: [
          const SectionTitle('音'),
          group([
            SwitchListTile(
              title: const Text('BGM'),
              value: s.settings.bgmOn,
              onChanged: (v) =>
                  ctrl.updateSettings(s.settings.copyWith(bgmOn: v)),
            ),
            SwitchListTile(
              title: const Text('効果音'),
              value: s.settings.seOn,
              onChanged: (v) =>
                  ctrl.updateSettings(s.settings.copyWith(seOn: v)),
            ),
          ]),
          const SectionTitle('通知'),
          group([
            SwitchListTile(
              title: const Text('出来事があったら知らせる'),
              subtitle: const Text(
                '「ログインしないと損」の通知は送りません。',
                style: TextStyle(fontSize: 11, color: YohakuColors.inkDim),
              ),
              value: s.settings.notificationsOn,
              onChanged: (v) {
                ctrl.updateSettings(s.settings.copyWith(notificationsOn: v));
                v
                    ? ctrl.requestNotificationPermission()
                    : ctrl.cancelNotification();
              },
            ),
          ]),
          const SectionTitle('データ'),
          group([
            ListTile(
              leading: const SketchIcon(
                Sketch.upload,
                color: YohakuColors.wood,
              ),
              title: const Text('バックアップ'),
              subtitle: const Text(
                'セーブデータをコピーします',
                style: TextStyle(fontSize: 11, color: YohakuColors.inkDim),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: ctrl.exportSave()));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('セーブデータをコピーしました')));
              },
            ),
            FutureBuilder<bool>(
              future: adPrivacyOptionsRequired(),
              builder: (context, snap) => snap.data == true
                  ? ListTile(
                      title: const Text('広告の同意設定'),
                      trailing: const SketchIcon(Sketch.forward, size: 20),
                      onTap: showAdPrivacyOptions,
                    )
                  : const SizedBox.shrink(),
            ),
            ListTile(
              leading: const SketchIcon(Sketch.book, color: YohakuColors.wood),
              title: const Text('まちの余白 シリーズ'),
              trailing: const SketchIcon(Sketch.forward, size: 20),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SeriesScreen()),
              ),
            ),
          ]),
          if (ref.read(databaseProvider) case final db?) ...[
            const SectionTitle('試遊ログ'),
            group([_PlaytestPanel(db: db)]),
          ],
          const SectionTitle('試遊用（デバッグ）'),
          group([
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'アプリを閉じて時間が経ったことにします。',
                    style: TextStyle(fontSize: 12, color: YohakuColors.inkDim),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (h, label) in const [
                        (1, '+1 時間'),
                        (3, '+3 時間'),
                        (8, '+8 時間'),
                        (13, '+13 時間（上限超え）'),
                      ])
                        OutlinedButton(
                          onPressed: () => advance(Duration(hours: h)),
                          child: Text(label),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '時間のずれ：${s.debugOffsetMinutes ~/ 60} 時間 ${s.debugOffsetMinutes % 60} 分',
                      style: const TextStyle(
                        fontSize: 11,
                        color: YohakuColors.inkDim,
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  const Text(
                    '店の絵の天気を差し替えて見る（計算には影響しません）',
                    style: TextStyle(fontSize: 12, color: YohakuColors.inkDim),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ChoiceChip(
                        label: const Text('実際の天気'),
                        selected: preview == null,
                        onSelected: (_) =>
                            ref.read(weatherPreviewProvider.notifier).set(null),
                      ),
                      for (final w in Weather.values)
                        ChoiceChip(
                          label: Text(w.label),
                          selected: preview == w,
                          onSelected: (_) =>
                              ref.read(weatherPreviewProvider.notifier).set(w),
                        ),
                    ],
                  ),
                  const Divider(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => ctrl.debugAddMoney(10000),
                        child: const Text('売上 +¥10,000'),
                      ),
                      OutlinedButton(
                        onPressed: () => ctrl.debugAddTickets(10),
                        child: const Text('チケット +10'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: YohakuColors.rose,
                    ),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => PaperDialog(
                          buttonLabel: '消す',
                          onButton: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'はじめからにしますか？\nセーブデータが消えます。',
                            textAlign: TextAlign.center,
                            style: TextStyle(height: 1.8),
                          ),
                        ),
                      );
                      if (ok == true) {
                        await ctrl.reset();
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    child: const Text('セーブデータを消す'),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '${c.brandName}：${c.titleName}  mock 0.2',
              style: const TextStyle(
                fontSize: 10,
                color: YohakuColors.inkDim,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 試遊で見たいこと（SPEC 9 章）のまとめ。端末の中にだけ残る。
class _PlaytestPanel extends StatefulWidget {
  const _PlaytestPanel({required this.db});

  final YohakuDatabase db;

  @override
  State<_PlaytestPanel> createState() => _PlaytestPanelState();
}

class _PlaytestPanelState extends State<_PlaytestPanel> {
  late final Future<PlaytestSummary> _summary = PlaytestSummary.of(widget.db);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: FutureBuilder<PlaytestSummary>(
        future: _summary,
        builder: (context, snap) {
          final p = snap.data;
          if (p == null) return const SizedBox(height: 40);
          Widget row(String label, String value) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Text(label, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                const Expanded(child: BlankRule(height: 12)),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
          final median = p.medianSessionSeconds;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              row(
                'はじめた日',
                p.firstDay == null
                    ? '—'
                    : '${p.firstDay!.month}/${p.firstDay!.day}',
              ),
              row(
                '翌日も開いた',
                p.firstDay == null ? '—' : (p.returnedNextDay ? 'はい' : 'まだ'),
              ),
              row('開いた日数', '${p.daysPlayed} 日'),
              row('開いた回数', '${p.sessions} 回'),
              row(
                '1 回の長さ（中央値）',
                median == null ? '—' : '${median ~/ 60} 分 ${median % 60} 秒',
              ),
              row('見た出来事', '${p.eventsSeen} 件'),
              row('客のことを見た', '${p.visitorOpens} 回'),
              row('図鑑のタブを開いた', '${p.zukanOpens} 回'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final json = await PlaytestSummary.export(widget.db);
                    await Clipboard.setData(ClipboardData(text: json));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('試遊ログをコピーしました')),
                      );
                    }
                  },
                  child: const Text('試遊ログを書き出す'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
