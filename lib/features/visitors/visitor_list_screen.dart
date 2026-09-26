import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/portrait.dart';
import 'visitor_detail_screen.dart';
import 'visitor_naming.dart';

/// 03. 来店客一覧。
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

    return PaperPage(
      title: '来店客一覧',
      showClose: true,
      tabs: const ['すべて', '常連', '特別'],
      builder: (context, tab) {
        final list = known.where((v) {
          final rec = s.visitors[v.id]!;
          return switch (tab) {
            1 => rec.visits >= nameRevealVisits,
            2 => v.special,
            _ => true,
          };
        }).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
          children: [
            if (list.isEmpty)
              EmptyNote(
                tab == 0
                    ? 'まだ誰も来ていません。\nアプリを閉じて、しばらくしてからのぞいてみてください。'
                    : tab == 1
                    ? '何度か来てくれると、常連さんになります。'
                    : '特別なお客さんは、天気や時間がそろった時にだけ現れます。',
              ),
            for (final v in list) ...[
              _VisitorRow(visitorId: v.id),
              const Divider(height: 1),
            ],
            if (tab == 0 && s.recentVisits.isNotEmpty) ...[
              const SectionTitle('さいきんの来店'),
              for (final visit in s.recentVisits.take(12))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: Text(
                          '${visit.at.month}/${visit.at.day} ${visit.at.hour.toString().padLeft(2, '0')}:${visit.at.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: YohakuColors.inkDim,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          visit.visitorId == null
                              ? '通りすがりのお客さん'
                              : visitorDisplayName(
                                  content.visitor(visit.visitorId!),
                                  s.visitors[visit.visitorId],
                                ),
                          style: TextStyle(
                            fontSize: 12,
                            color: visit.visitorId == null
                                ? YohakuColors.inkDim
                                : YohakuColors.ink,
                          ),
                        ),
                      ),
                      Text(
                        content.menu(visit.menuId).name,
                        style: const TextStyle(
                          fontSize: 11,
                          color: YohakuColors.inkDim,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _VisitorRow extends ConsumerWidget {
  const _VisitorRow({required this.visitorId});

  final String visitorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final def = c.visitor(visitorId);
    final rec = s.visitors[visitorId]!;
    final profile = unlockedProfile(def, rec);
    final fav = def.favoriteMenuId;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => VisitorDetailScreen(visitorId: visitorId),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Portrait(visitorId: visitorId, look: def.look, size: 58),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          visitorDisplayName(def, rec),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (rec.visits <= 1) const NewBadge(),
                      if (def.special)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: TagPill('特別', color: YohakuColors.moss),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    fav != null && rec.favoriteKnown
                        ? c.menu(fav).name
                        : '好きなもの：？？？',
                    style: const TextStyle(
                      fontSize: 11,
                      color: YohakuColors.inkDim,
                    ),
                  ),
                  if (profile.isNotEmpty)
                    Text(
                      profile.last,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: YohakuColors.inkDim,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '${rec.visits}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: YohakuColors.wood,
                  ),
                ),
                const Text(
                  '回',
                  style: TextStyle(fontSize: 9, color: YohakuColors.inkDim),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
