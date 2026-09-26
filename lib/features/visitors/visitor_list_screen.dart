import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';
import 'visitor_detail_screen.dart';
import 'visitor_naming.dart';

/// 03. 客一覧 ― 来店した人。
class VisitorListScreen extends ConsumerWidget {
  const VisitorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final content = ref.watch(contentProvider);
    final known =
        [
          for (final v in content.visitors)
            if (s.visitors.containsKey(v.id)) v,
        ]..sort(
          (a, b) => s.visitors[b.id]!.lastSeenAt.compareTo(
            s.visitors[a.id]!.lastSeenAt,
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        SectionTitle('常連さん  ${known.length}'),
        if (known.isEmpty)
          const EmptyNote('まだ誰も来ていません。\nアプリを閉じて、しばらくしてからのぞいてみてください。'),
        for (final v in known)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VisitorDetailScreen(visitorId: v.id),
                  ),
                ),
                leading: CircleAvatar(backgroundColor: Color(v.colorValue)),
                title: Text(visitorDisplayName(v, s.visitors[v.id])),
                subtitle: Text(
                  '来店 ${s.visitors[v.id]!.visits} 回・${_ago(ref.read(gameProvider.notifier).now(), s.visitors[v.id]!.lastSeenAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: YohakuColors.paperDim,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        const SectionTitle('さいきんの来店'),
        if (s.recentVisits.isEmpty) const EmptyNote('来店の記録はまだありません。'),
        for (final v in s.recentVisits.take(20))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    '${v.at.month}/${v.at.day} ${v.at.hour.toString().padLeft(2, '0')}:${v.at.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: YohakuColors.paperDim,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    v.visitorId == null
                        ? '通りすがりのお客さん'
                        : visitorDisplayName(
                            content.visitor(v.visitorId!),
                            s.visitors[v.visitorId],
                          ),
                    style: TextStyle(
                      color: v.visitorId == null
                          ? YohakuColors.paperDim
                          : YohakuColors.paper,
                    ),
                  ),
                ),
                Text(
                  content.menu(v.menuId).name,
                  style: const TextStyle(
                    fontSize: 12,
                    color: YohakuColors.paperDim,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _ago(DateTime now, DateTime t) {
    final d = now.difference(t);
    if (d.inMinutes < 60) return '${d.inMinutes} 分前';
    if (d.inHours < 24) return '${d.inHours} 時間前';
    return '${d.inDays} 日前';
  }
}
