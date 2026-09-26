import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/state/game_controller.dart';
import '../../titles/yoru_kissa/cafe_scene.dart';
import '../../widgets/common.dart';
import '../visitors/visitor_detail_screen.dart';
import '../visitors/visitor_naming.dart';

/// 01. ホーム ― 店そのもの。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final content = ref.watch(contentProvider);
    final ambiences = ref.watch(ambiencesProvider);
    final m = ctrl.currentMoment();
    final now = m.time;
    final lastFragment = s.fragments.isEmpty ? null : s.fragments.last;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        Row(
          children: [
            Text(
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${m.slot.label}・${m.weather.label}・${m.season.label}',
              style: const TextStyle(color: YohakuColors.paperDim),
            ),
            const Spacer(),
            Text(
              content.placeName,
              style: const TextStyle(
                fontSize: 12,
                color: YohakuColors.paperDim,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        CafeScene(
          content: content,
          moment: m,
          placement: s.placement,
          effects: s.activeEffects,
          seated: s.seated,
          onGuestTap: (i) => _tapGuest(context, ref, i),
        ),
        const SizedBox(height: 10),
        if (ambiences.isNotEmpty || s.activeBgm != null)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final a in ambiences) TagPill(a.name),
              if (s.activeBgm != null)
                TagPill(
                  '♪ ${content.item(s.activeBgm!).name.replaceFirst('BGM：', '')}',
                  color: YohakuColors.lamp,
                ),
            ],
          ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.point_of_sale_outlined,
              color: YohakuColors.lamp,
            ),
            title: Text('レジ  ${yen(s.register)}'),
            subtitle: Text(
              s.seated.isEmpty ? 'お客さんが来るのを待っています' : '席のお客さんをタップすると、お会計できます',
              style: const TextStyle(
                fontSize: 12,
                color: YohakuColors.paperDim,
              ),
            ),
            trailing: FilledButton.tonal(
              onPressed: s.register == 0
                  ? null
                  : () {
                      final got = ctrl.collectRegister();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${yen(got)} を回収しました')),
                      );
                    },
              child: const Text('回収'),
            ),
          ),
        ),
        if (lastFragment != null) ...[
          const SectionTitle('さいきんの出来事'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.story(lastFragment.chainId).title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: YohakuColors.lamp,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content
                        .story(lastFragment.chainId)
                        .steps[lastFragment.step]
                        .text,
                    style: const TextStyle(height: 1.8),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (!s.adFree) ...[const SizedBox(height: 16), const AdBannerMock()],
      ],
    );
  }

  void _tapGuest(BuildContext context, WidgetRef ref, int index) {
    final ctrl = ref.read(gameProvider.notifier);
    final content = ref.read(contentProvider);
    final guest = ctrl.collectGuest(index);
    if (guest == null) return;
    final id = guest.visit.visitorId;
    final def = id == null ? null : content.visitor(id);
    final rec = id == null ? null : ref.read(gameProvider).visitors[id];
    final line = def == null
        ? 'ごちそうさまでした。'
        : def.lines[guest.visit.at.minute % def.lines.length];
    showDialog<void>(
      context: context,
      barrierColor: Colors.black38,
      builder: (ctx) => _GuestDialog(
        name: def == null ? '通りすがりのお客さん' : visitorDisplayName(def, rec),
        line: line,
        menu: content.menu(guest.visit.menuId).name,
        bill: guest.bill,
        color: Color(def?.colorValue ?? 0xFF6B6E78),
        visits: rec?.visits,
        onDetail: id == null
            ? null
            : () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VisitorDetailScreen(visitorId: id),
                  ),
                );
              },
      ),
    );
  }
}

class _GuestDialog extends StatelessWidget {
  const _GuestDialog({
    required this.name,
    required this.line,
    required this.menu,
    required this.bill,
    required this.color,
    required this.visits,
    required this.onDetail,
  });

  final String name;
  final String line;
  final String menu;
  final int bill;
  final Color color;
  final int? visits;
  final VoidCallback? onDetail;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: YohakuColors.inkRaised,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 14, backgroundColor: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (visits != null)
                  Text(
                    '来店 $visits 回',
                    style: const TextStyle(
                      fontSize: 11,
                      color: YohakuColors.paperDim,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('「$line」', style: const TextStyle(height: 1.8)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  menu,
                  style: const TextStyle(color: YohakuColors.paperDim),
                ),
                const Spacer(),
                Text(
                  '+${yen(bill)}',
                  style: const TextStyle(
                    color: YohakuColors.lamp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDetail != null)
                  TextButton(onPressed: onDetail, child: const Text('この人のこと')),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
