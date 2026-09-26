import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/models/content.dart';
import '../../core/state/game_controller.dart';
import '../../core/state/game_state.dart';
import '../../widgets/common.dart';
import '../visitors/visitor_detail_screen.dart';
import '../visitors/visitor_naming.dart';

/// 05. 図鑑 ― 人・アイテム・メニュー・出来事。
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
    final stepTotal = stories.fold<int>(0, (a, x) => a + x.steps.length);
    final stepFound = stories.fold<int>(
      0,
      (a, x) => a + (s.stories[x.id]?.nextStep ?? 0),
    );

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelPadding: EdgeInsets.zero,
            tabs: [
              Tab(
                text:
                    '客 ${visitors.where((v) => s.visitors.containsKey(v.id)).length}/${visitors.length}',
              ),
              Tab(
                text:
                    'もの ${c.items.where((i) => s.ownedItems.contains(i.id)).length}/${c.items.length}',
              ),
              Tab(text: 'メニュー ${s.ownedMenus.length}/${c.menus.length}'),
              Tab(text: '出来事 $stepFound/$stepTotal'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _VisitorGrid(visitors: visitors, state: s),
                _ItemList(content: c, state: s),
                _MenuList(content: c, state: s),
                _StoryList(stories: stories, state: s),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitorGrid extends StatelessWidget {
  const _VisitorGrid({required this.visitors, required this.state});

  final List<VisitorDef> visitors;
  final GameState state;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.8,
      children: [
        for (final v in visitors)
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => VisitorDetailScreen(visitorId: v.id),
              ),
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: state.visitors.containsKey(v.id)
                          ? Color(v.colorValue)
                          : YohakuColors.inkLine,
                      child: state.visitors.containsKey(v.id)
                          ? null
                          : const Text('？'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.visitors.containsKey(v.id)
                          ? visitorDisplayName(v, state.visitors[v.id])
                          : '？？？',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({required this.content, required this.state});

  final TitleContent content;
  final GameState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        for (final kind in ItemKind.values) ...[
          SectionTitle(kind.label),
          for (final i in content.items.where((x) => x.kind == kind))
            _ZukanRow(
              owned: state.ownedItems.contains(i.id),
              title: i.name,
              subtitle: state.ownedItems.contains(i.id)
                  ? i.description
                  : '入手方法：${i.source.label}',
              tags: i.tags,
            ),
        ],
      ],
    );
  }
}

class _MenuList extends StatelessWidget {
  const _MenuList({required this.content, required this.state});

  final TitleContent content;
  final GameState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final m in content.menus)
          _ZukanRow(
            owned: state.ownedMenus.contains(m.id),
            title: m.name,
            subtitle: state.ownedMenus.contains(m.id)
                ? m.description
                : 'メニュー画面で覚えられます',
          ),
      ],
    );
  }
}

class _ZukanRow extends StatelessWidget {
  const _ZukanRow({
    required this.owned,
    required this.title,
    required this.subtitle,
    this.tags = const [],
  });

  final bool owned;
  final String title;
  final String subtitle;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                owned ? Icons.check_circle : Icons.circle_outlined,
                size: 18,
                color: owned ? YohakuColors.lamp : YohakuColors.inkLine,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owned ? title : '？？？',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: YohakuColors.paperDim,
                        height: 1.6,
                      ),
                    ),
                    if (owned && tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        children: [for (final t in tags) TagPill(t)],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryList extends StatelessWidget {
  const _StoryList({required this.stories, required this.state});

  final List<StoryChainDef> stories;
  final GameState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final c in stories)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _StoryCard(
                  chain: c,
                  found: state.stories[c.id]?.nextStep ?? 0,
                  fragments: state.fragments,
                ),
              ),
            ),
          ),
      ],
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
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
            if (chain.premiumEpisodeId != null)
              const TagPill('エピソード', color: YohakuColors.rose),
            const SizedBox(width: 6),
            TagPill(
              '$found / ${chain.steps.length}',
              color: done ? YohakuColors.lamp : YohakuColors.moss,
              filled: done,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < chain.steps.length; i++)
          if (i < found)
            _StepLine(
              date: fragments
                  .where((f) => f.chainId == chain.id && f.step == i)
                  .map((f) => '${f.at.month}/${f.at.day}')
                  .firstOrNull,
              text: chain.steps[i].text,
            )
          else if (i == found && chain.steps[i].hint != null)
            _StepLine(text: 'ヒント：${chain.steps[i].hint}', dim: true)
          else
            const _StepLine(text: '……', dim: true),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.text, this.date, this.dim = false});

  final String text;
  final String? date;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              date ?? '',
              style: const TextStyle(
                fontSize: 11,
                color: YohakuColors.paperDim,
                height: 1.9,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                height: 1.7,
                fontSize: dim ? 12 : 14,
                color: dim ? YohakuColors.paperDim : YohakuColors.paper,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
