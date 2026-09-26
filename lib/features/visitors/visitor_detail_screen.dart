import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/handdrawn.dart';

import '../../core/brand/theme.dart';
import '../../core/models/world.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';
import '../../widgets/portrait.dart';
import 'visitor_naming.dart';

/// 04. 客詳細 ― 大きな似顔絵＋「プロフィール／出来事」。
class VisitorDetailScreen extends ConsumerStatefulWidget {
  const VisitorDetailScreen({super.key, required this.visitorId});

  final String visitorId;

  @override
  ConsumerState<VisitorDetailScreen> createState() =>
      _VisitorDetailScreenState();
}

class _VisitorDetailScreenState extends ConsumerState<VisitorDetailScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider);
    final content = ref.watch(contentProvider);
    final def = content.visitor(widget.visitorId);
    final rec = s.visitors[widget.visitorId];
    final met = rec != null;
    final number = content.visitors.indexOf(def) + 1;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: NightBackdrop()),
          SafeArea(
            child: Column(
              children: [
                // ヘッダー：夜の窓辺に座る似顔絵
                SizedBox(
                  height: 230,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: const Alignment(0.5, 0.2),
                              radius: 1.1,
                              colors: [
                                YohakuColors.lamp.withValues(alpha: 0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 24,
                        bottom: 0,
                        child: Portrait(
                          look: def.look,
                          size: 190,
                          locked: !met,
                          background: const Color(0x00000000),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No.${number.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: YohakuColors.cream,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              met ? visitorDisplayName(def, rec) : '？？？',
                              style: const TextStyle(
                                color: YohakuColors.paper,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                            if (met)
                              Text(
                                '来店 ${rec.visits} 回',
                                style: const TextStyle(
                                  color: YohakuColors.cream,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: YohakuColors.paper,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    decoration: ShapeDecoration(
                      color: YohakuColors.paper,
                      shape: RoughBorder(radius: 22),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                          child: PillTabs(
                            labels: const ['プロフィール', '出来事'],
                            selected: _tab,
                            onChanged: (i) => setState(() => _tab = i),
                          ),
                        ),
                        Expanded(
                          child: _tab == 0
                              ? _profile(context)
                              : _events(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profile(BuildContext context) {
    final s = ref.watch(gameProvider);
    final content = ref.watch(contentProvider);
    final def = content.visitor(widget.visitorId);
    final rec = s.visitors[widget.visitorId];
    final met = rec != null;
    final next = visitsToNextProfile(def, rec);
    final fav = def.favoriteMenuId;
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
      children: [
        if (!met) const EmptyNote('まだ会ったことがない。'),
        for (final p in unlockedProfile(def, rec))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(p, style: const TextStyle(height: 1.8)),
          ),
        if (met && next != null)
          Text(
            '（まだ、それくらいしか知らない）',
            style: const TextStyle(fontSize: 12, color: YohakuColors.inkDim),
          ),
        if (met) ...[
          const SectionTitle('よく頼むもの'),
          PaperCard(
            child: Row(
              children: [
                IconTile(
                  fav != null && rec.favoriteKnown
                      ? content.menu(fav).icon
                      : '',
                  size: 40,
                  locked: !(fav != null && rec.favoriteKnown),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fav == null
                        ? 'とくに決まっていない'
                        : rec.favoriteKnown
                        ? content.menu(fav).name
                        : s.ownedMenus.contains(fav)
                        ? 'そのうち頼んでくれるはず'
                        : 'まだ店のメニューにないのかもしれない',
                  ),
                ),
              ],
            ),
          ),
          if (rec.visits >= 2) ...[
            const SectionTitle('見かける時間'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final slot in def.slots)
                  TagPill(slot.label, color: YohakuColors.wood),
                for (final w in def.weathers ?? const <Weather>{})
                  TagPill(w.label, color: YohakuColors.moss),
              ],
            ),
          ],
        ],
      ],
    );
  }

  /// 発見した出来事を「N 日目」の時系列で並べる。
  Widget _events(BuildContext context) {
    final s = ref.watch(gameProvider);
    final content = ref.watch(contentProvider);
    final rec = s.visitors[widget.visitorId];
    final chains = content.stories.where(
      (c) =>
          c.relatedVisitorIds.contains(widget.visitorId) &&
          (c.premiumEpisodeId == null ||
              s.episodes.contains(c.premiumEpisodeId)),
    );
    final found = [
      for (final f in s.fragments)
        if (chains.any((c) => c.id == f.chainId)) f,
    ]..sort((a, b) => a.at.compareTo(b.at));
    final remaining = chains.fold<int>(
      0,
      (a, c) => a + c.steps.length - (s.stories[c.id]?.nextStep ?? 0),
    );
    final origin = rec?.firstSeenAt;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
      children: [
        const SectionTitle('発見した出来事'),
        Container(
          decoration: ShapeDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            shape: RoughBorder(
              radius: 12,
              side: BorderSide(color: YohakuColors.paperLine),
            ),
          ),
          child: Column(
            children: [
              if (origin != null)
                _TimelineRow(day: 1, text: 'はじめて来店', done: true),
              for (final f in found)
                _TimelineRow(
                  day: origin == null
                      ? null
                      : businessDaysBetween(origin, f.at) + 1,
                  text: content.story(f.chainId).steps[f.step].text,
                  done: true,
                ),
              for (var i = 0; i < remaining; i++)
                const _TimelineRow(day: null, text: '', done: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.day,
    required this.text,
    required this.done,
  });

  final int? day;
  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              day == null ? '' : '$day日目',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: YohakuColors.wood,
              ),
            ),
          ),
          Expanded(
            child: done
                ? Text(
                    text,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.6,
                      color: YohakuColors.ink,
                    ),
                  )
                : const BlankRule(height: 16),
          ),
        ],
      ),
    );
  }
}
