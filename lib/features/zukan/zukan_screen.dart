import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/models/content.dart';
import '../../core/state/game_controller.dart';
import '../../core/state/game_state.dart';
import '../../widgets/common.dart';
import '../../widgets/portrait.dart';
import '../visitors/visitor_detail_screen.dart';
import '../visitors/visitor_naming.dart';

/// 05. 図鑑 ― お客様・家具・メニュー・出来事。
/// このゲームの中毒性の中心。
class ZukanScreen extends ConsumerWidget {
  const ZukanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final visitors = c.visitors
        .where(
          (v) =>
              v.premiumEpisodeId == null ||
              s.episodes.contains(v.premiumEpisodeId),
        )
        .toList();
    final stories = c.stories
        .where(
          (x) =>
              x.premiumEpisodeId == null ||
              s.episodes.contains(x.premiumEpisodeId),
        )
        .toList();

    return PaperPage(
      title: '図鑑',
      tabs: const ['お客様', '家具', 'メニュー', '出来事'],
      builder: (context, tab) {
        final (found, total) = switch (tab) {
          0 => (
            visitors.where((v) => s.visitors.containsKey(v.id)).length,
            visitors.length,
          ),
          1 => (
            c.items.where((i) => s.ownedItems.contains(i.id)).length,
            c.items.length,
          ),
          2 => (s.ownedMenus.length, c.menus.length),
          _ => (
            stories.fold<int>(
              0,
              (a, x) => a + (s.stories[x.id]?.nextStep ?? 0),
            ),
            stories.fold<int>(0, (a, x) => a + x.steps.length),
          ),
        };
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: ProgressLine(value: total == 0 ? 0 : found / total),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$found / $total',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (tab) {
                0 => _grid([
                  for (var i = 0; i < visitors.length; i++)
                    _ZukanCell(
                      number: c.visitors.indexOf(visitors[i]) + 1,
                      name: s.visitors.containsKey(visitors[i].id)
                          ? visitorDisplayName(
                              visitors[i],
                              s.visitors[visitors[i].id],
                            )
                          : '？？？',
                      image: Portrait(
                        visitorId: visitors[i].id,
                        look: visitors[i].look,
                        size: 66,
                        locked: !s.visitors.containsKey(visitors[i].id),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              VisitorDetailScreen(visitorId: visitors[i].id),
                        ),
                      ),
                    ),
                ]),
                1 => _grid([
                  for (var i = 0; i < c.items.length; i++)
                    _ZukanCell(
                      number: i + 1,
                      name: s.ownedItems.contains(c.items[i].id)
                          ? c.items[i].name
                          : '？？？',
                      image: IconTile(
                        c.items[i].icon,
                        artId: c.items[i].id,
                        size: 66,
                        locked: !s.ownedItems.contains(c.items[i].id),
                      ),
                      onTap: () => _itemInfo(context, c.items[i], s),
                    ),
                ]),
                2 => _grid([
                  for (var i = 0; i < c.menus.length; i++)
                    _ZukanCell(
                      number: i + 1,
                      name: s.ownedMenus.contains(c.menus[i].id)
                          ? c.menus[i].name
                          : '？？？',
                      image: IconTile(
                        c.menus[i].icon,
                        artId: c.menus[i].id,
                        size: 66,
                        locked: !s.ownedMenus.contains(c.menus[i].id),
                      ),
                    ),
                ]),
                _ => ListView(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                  children: [
                    for (final chain in stories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PaperCard(
                          child: _StoryCard(
                            chain: chain,
                            found: s.stories[chain.id]?.nextStep ?? 0,
                            fragments: s.fragments,
                          ),
                        ),
                      ),
                  ],
                ),
              },
            ),
          ],
        );
      },
    );
  }

  Widget _grid(List<Widget> cells) => GridView.count(
    crossAxisCount: 3,
    padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
    mainAxisSpacing: 10,
    crossAxisSpacing: 10,
    childAspectRatio: 0.78,
    children: cells,
  );

  void _itemInfo(BuildContext context, ItemDef i, GameState s) {
    final owned = s.ownedItems.contains(i.id);
    showDialog<void>(
      context: context,
      builder: (_) => PaperDialog(
        buttonLabel: '閉じる',
        child: Column(
          children: [
            IconTile(i.icon, size: 80, locked: !owned, artId: i.id),
            const SizedBox(height: 12),
            Text(
              owned ? i.name : '？？？',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              owned ? i.description : '入手方法：${i.source.label}',
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.7),
            ),
            if (owned && i.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 4, children: [for (final t in i.tags) TagPill(t)]),
            ],
          ],
        ),
      ),
    );
  }
}

class _ZukanCell extends StatelessWidget {
  const _ZukanCell({
    required this.number,
    required this.name,
    required this.image,
    this.onTap,
  });

  final int number;
  final String name;
  final Widget image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
      child: Column(
        children: [
          image,
          const SizedBox(height: 4),
          Text(
            'No.${number.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 9, color: YohakuColors.inkDim),
          ),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.chain,
    required this.found,
    required this.fragments,
  });

  final StoryChainDef chain;
  final int found;
  final List<DiscoveredFragment> fragments;

  @override
  Widget build(BuildContext context) {
    final done = found >= chain.steps.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                found == 0 ? '？？？' : chain.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            if (chain.premiumEpisodeId != null)
              const TagPill('エピソード', color: YohakuColors.rose),
            const SizedBox(width: 6),
            TagPill(
              '$found / ${chain.steps.length}',
              color: done ? YohakuColors.wood : YohakuColors.moss,
              filled: done,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < chain.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    i < found
                        ? fragments
                                  .where(
                                    (f) => f.chainId == chain.id && f.step == i,
                                  )
                                  .map((f) => '${f.at.month}/${f.at.day}')
                                  .firstOrNull ??
                              ''
                        : '',
                    style: const TextStyle(
                      fontSize: 10,
                      color: YohakuColors.inkDim,
                      height: 2,
                    ),
                  ),
                ),
                Expanded(
                  child:
                      i > found || (i == found && chain.steps[i].hint == null)
                      ? const BlankRule()
                      : Text(
                          i < found
                              ? chain.steps[i].text
                              : '（${chain.steps[i].hint}）',
                          style: TextStyle(
                            fontSize: i < found ? 13 : 11,
                            height: 1.7,
                            color: i < found
                                ? YohakuColors.ink
                                : YohakuColors.inkDim,
                          ),
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
