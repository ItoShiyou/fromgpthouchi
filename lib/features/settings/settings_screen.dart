import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/handdrawn.dart';

import '../../core/brand/theme.dart';
import '../../core/models/world.dart';
import '../../core/persistence/database.dart';
import '../../core/services/ads.dart';
import '../../core/services/analytics.dart';
import '../../core/services/cloud_backup.dart';
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
          if (ref.read(cloudBackupProvider).enabled) ...[
            const SectionTitle('クラウド・機種変更'),
            group([const _CloudPanel()]),
          ],
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

/// クラウドに預ける／戻す、引き継ぎコード。自動では上書きしない。
class _CloudPanel extends ConsumerStatefulWidget {
  const _CloudPanel();

  @override
  ConsumerState<_CloudPanel> createState() => _CloudPanelState();
}

class _CloudPanelState extends ConsumerState<_CloudPanel> {
  bool _busy = false;
  DateTime? _last;

  CloudBackup get _cloud => ref.read(cloudBackupProvider);
  String get _title => ref.read(contentProvider).id;

  @override
  void initState() {
    super.initState();
    _cloud
        .lastBackupAt(_title)
        .then((t) {
          if (mounted) setState(() => _last = t);
        })
        .catchError((Object _) {});
  }

  Future<void> _run(Future<void> Function() f) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await f();
    } catch (_) {
      _say('うまくいきませんでした。通信できる所でもう一度試してください');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _say(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<bool> _confirm(String text) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => PaperDialog(
          buttonLabel: '置き換える',
          onButton: () => Navigator.of(ctx).pop(true),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.8),
          ),
        ),
      ) ==
      true;

  Future<void> _upload() => _run(() async {
    await ref.read(gameProvider.notifier).flush();
    await _cloud.upload(_title, ref.read(gameProvider));
    setState(() => _last = DateTime.now());
    _say('クラウドに預けました');
  });

  Future<void> _download() => _run(() async {
    final saved = await _cloud.download(_title);
    if (saved == null) {
      _say('クラウドに預けたデータがありません');
      return;
    }
    if (!await _confirm('クラウドに預けた時の状態に戻します。\nいまの店の様子は消えます。')) return;
    ref.read(gameProvider.notifier).restoreFrom(saved);
    _say('クラウドから戻しました');
  });

  Future<void> _issueCode() => _run(() async {
    await _cloud.upload(_title, ref.read(gameProvider));
    final code = await _cloud.createTransferCode(_title);
    final shown = [
      for (var i = 0; i < code.length; i += 4)
        code.substring(i, (i + 4).clamp(0, code.length)),
    ].join('-');
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => PaperDialog(
        buttonLabel: 'コピーして閉じる',
        onButton: () {
          Clipboard.setData(ClipboardData(text: shown));
          Navigator.of(ctx).pop();
        },
        child: Column(
          children: [
            const Text('新しい端末で、このコードを入れてください。', style: TextStyle(height: 1.8)),
            const SizedBox(height: 12),
            SelectableText(shown, style: YohakuText.heading(22)),
            const SizedBox(height: 8),
            const Text(
              '24 時間・一度だけ使えます',
              style: TextStyle(fontSize: 11, color: YohakuColors.inkDim),
            ),
          ],
        ),
      ),
    );
  });

  Future<void> _enterCode() async {
    final field = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => PaperDialog(
        buttonLabel: '引き継ぐ',
        onButton: () => Navigator.of(ctx).pop(field.text.trim()),
        child: Column(
          children: [
            const Text('前の端末で出した引き継ぎコード', style: TextStyle(height: 1.8)),
            const SizedBox(height: 8),
            TextField(
              controller: field,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(hintText: 'XXXX-XXXX-XXXX'),
            ),
          ],
        ),
      ),
    );
    if (code == null || code.isEmpty) return;
    if (!await _confirm('前の端末の店を、この端末に引き継ぎます。\nいまの店の様子は消えます。')) return;
    await _run(() async {
      final saved = await _cloud.claimTransferCode(code);
      ref.read(gameProvider.notifier).restoreFrom(saved);
      _say('引き継ぎました');
    });
  }

  @override
  Widget build(BuildContext context) {
    final last = _last;
    return Column(
      children: [
        ListTile(
          enabled: !_busy,
          title: const Text('クラウドに預ける'),
          subtitle: Text(
            last == null
                ? 'まだ預けていません'
                : '前回：${last.month}/${last.day} ${last.hour}:${last.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 11, color: YohakuColors.inkDim),
          ),
          onTap: _upload,
        ),
        ListTile(
          enabled: !_busy,
          title: const Text('クラウドから戻す'),
          onTap: _download,
        ),
        ListTile(
          enabled: !_busy,
          title: const Text('引き継ぎコードを出す（前の端末で）'),
          onTap: _issueCode,
        ),
        ListTile(
          enabled: !_busy,
          title: const Text('引き継ぎコードを入れる（新しい端末で）'),
          onTap: _enterCode,
        ),
      ],
    );
  }
}
