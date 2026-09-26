import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';
import 'visitor_naming.dart';

/// 04. 客詳細 ― プロフィール＋発見した出来事。
class VisitorDetailScreen extends ConsumerWidget {
  const VisitorDetailScreen({super.key, required this.visitorId});

  final String visitorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final content = ref.watch(contentProvider);
    final def = content.visitor(visitorId);
    final rec = s.visitors[visitorId];
    final met = rec != null;
    final profile = unlockedProfile(def, rec);
    final next = visitsToNextProfile(def, rec);
    final fav = def.favoriteMenuId;
    final chains = content.stories.where(
      (c) => c.relatedVisitorIds.contains(visitorId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(met ? visitorDisplayName(def, rec) : '？？？')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: met
                      ? Color(def.colorValue)
                      : YohakuColors.inkLine,
                  child: met
                      ? null
                      : const Text('？', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(height: 12),
                if (met)
                  Text(
                    '来店 ${rec.visits} 回・はじめて見かけたのは ${rec.firstSeenAt.month}/${rec.firstSeenAt.day}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: YohakuColors.paperDim,
                    ),
                  )
                else
                  const Text(
                    'まだ会ったことがない',
                    style: TextStyle(color: YohakuColors.paperDim),
                  ),
              ],
            ),
          ),
          const SectionTitle('わかっていること'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final p in profile)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text('・$p', style: const TextStyle(height: 1.7)),
                    ),
                  if (next != null)
                    Text(
                      met ? 'あと $next 回来てくれたら、何かわかるかもしれない。' : '……',
                      style: const TextStyle(
                        fontSize: 12,
                        color: YohakuColors.paperDim,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (met) ...[
            const SectionTitle('よく頼むもの'),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.local_cafe_outlined,
                  color: YohakuColors.lamp,
                ),
                title: Text(
                  fav == null
                      ? 'とくに決まっていない'
                      : rec.favoriteKnown
                      ? content.menu(fav).name
                      : '？？？',
                ),
                subtitle: fav != null && !rec.favoriteKnown
                    ? Text(
                        s.ownedMenus.contains(fav)
                            ? 'そのうち頼んでくれるはず'
                            : 'まだ店のメニューにないのかもしれない',
                        style: const TextStyle(
                          fontSize: 12,
                          color: YohakuColors.paperDim,
                        ),
                      )
                    : null,
              ),
            ),
            if (rec.visits >= 2) ...[
              const SectionTitle('見かける時間'),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final slot in def.slots) TagPill(slot.label),
                  for (final w in def.weathers ?? const {})
                    TagPill(w.label, color: YohakuColors.lamp),
                ],
              ),
            ],
          ],
          if (chains.isNotEmpty) ...[
            const SectionTitle('この人のまわりの出来事'),
            for (final c in chains)
              if (c.premiumEpisodeId == null ||
                  s.episodes.contains(c.premiumEpisodeId))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.title,
                            style: const TextStyle(
                              color: YohakuColors.lamp,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (var i = 0; i < c.steps.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                (s.stories[c.id]?.nextStep ?? 0) > i
                                    ? c.steps[i].text
                                    : '……',
                                style: TextStyle(
                                  height: 1.7,
                                  color: (s.stories[c.id]?.nextStep ?? 0) > i
                                      ? YohakuColors.paper
                                      : YohakuColors.inkLine,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
