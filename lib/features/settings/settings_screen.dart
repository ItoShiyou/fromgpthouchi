import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';

/// 10. 設定 ― バックアップ・音・通知など。
/// モック用に「時間を進める」デバッグ機能を置いている。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final c = ref.watch(contentProvider);

    void advance(Duration d) {
      // 先に閉じてから時間を進める（「おかえりなさい」をお店の上に出すため）。
      Navigator.of(context).pop();
      ctrl.debugAdvance(d);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const SectionTitle('音'),
          Card(
            child: Column(
              children: [
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
              ],
            ),
          ),
          const SectionTitle('通知'),
          Card(
            child: SwitchListTile(
              title: const Text('出来事があったら知らせる'),
              subtitle: const Text(
                '「ログインしないと損」の通知は送りません。',
                style: TextStyle(fontSize: 12, color: YohakuColors.paperDim),
              ),
              value: s.settings.notificationsOn,
              onChanged: (v) =>
                  ctrl.updateSettings(s.settings.copyWith(notificationsOn: v)),
            ),
          ),
          const SectionTitle('バックアップ'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('セーブデータを書き出す'),
              subtitle: const Text(
                '本番では Supabase の cloud_save に保存します（モックではクリップボードへ）',
                style: TextStyle(fontSize: 12, color: YohakuColors.paperDim),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: ctrl.exportSave()));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('セーブデータをコピーしました')));
              },
            ),
          ),
          const SectionTitle('試遊用（デバッグ）'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'アプリを閉じて時間が経ったことにします。',
                    style: TextStyle(
                      fontSize: 12,
                      color: YohakuColors.paperDim,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => advance(const Duration(hours: 1)),
                        child: const Text('+1 時間'),
                      ),
                      OutlinedButton(
                        onPressed: () => advance(const Duration(hours: 3)),
                        child: const Text('+3 時間'),
                      ),
                      OutlinedButton(
                        onPressed: () => advance(const Duration(hours: 8)),
                        child: const Text('+8 時間'),
                      ),
                      OutlinedButton(
                        onPressed: () => advance(const Duration(hours: 13)),
                        child: const Text('+13 時間（上限超え）'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '時間のずれ：${s.debugOffsetMinutes ~/ 60} 時間 ${s.debugOffsetMinutes % 60} 分',
                    style: const TextStyle(
                      fontSize: 12,
                      color: YohakuColors.paperDim,
                    ),
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
                  const Divider(height: 24),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: YohakuColors.rose,
                    ),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: YohakuColors.inkRaised,
                          title: const Text('はじめからにしますか？'),
                          content: const Text('セーブデータが消えます。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('やめる'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('消す'),
                            ),
                          ],
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
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '${c.brandName}：${c.titleName}  mock 0.1',
              style: const TextStyle(
                fontSize: 11,
                color: YohakuColors.paperDim,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
