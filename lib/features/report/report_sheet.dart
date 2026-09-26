import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/state/game_controller.dart';

/// 02. 放置結果 ―「おかえりなさい」。
class ReportSheet extends ConsumerWidget {
  const ReportSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(gameProvider.select((s) => s.pendingReport));
    final content = ref.watch(contentProvider);
    if (r == null) return const SizedBox(height: 120);

    Widget row(String label, String value, {bool accent = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: YohakuColors.paperDim)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: accent ? YohakuColors.lamp : YohakuColors.paper,
            ),
          ),
        ],
      ),
    );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'おかえりなさい',
                        style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'あなたがいない間の ${content.placeName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: YohakuColors.paperDim,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    row('営業時間', hm(r.effective)),
                    if (r.isCapped)
                      Text(
                        '（${hm(r.elapsed)} 離れていました。お店は最大 ${content.maxIdle.inHours} 時間分まで営業します）',
                        style: const TextStyle(
                          fontSize: 11,
                          color: YohakuColors.paperDim,
                        ),
                      ),
                    row('売上', '+${yen(r.income)}', accent: true),
                    row('来店', '${r.visitCount} 人'),
                    if (r.ticketsEarned > 0)
                      row('余白くじチケット', '+${r.ticketsEarned}'),
                    if (r.newVisitorIds.isNotEmpty) ...[
                      const Divider(height: 28),
                      const Text(
                        'はじめてのお客さん',
                        style: TextStyle(
                          fontSize: 12,
                          color: YohakuColors.paperDim,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final id in r.newVisitorIds)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 8,
                                backgroundColor: Color(
                                  content.visitor(id).colorValue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(content.visitor(id).silhouetteName),
                            ],
                          ),
                        ),
                    ],
                    if (r.newFragments.isNotEmpty) ...[
                      const Divider(height: 28),
                      Text(
                        '新しい出来事　${r.newFragments.length} 件',
                        style: const TextStyle(
                          fontSize: 12,
                          color: YohakuColors.paperDim,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final f in r.newFragments)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: YohakuColors.inkRaised,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                content.story(f.chainId).title,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: YohakuColors.lamp,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                content.story(f.chainId).steps[f.step].text,
                                style: const TextStyle(height: 1.7),
                              ),
                            ],
                          ),
                        ),
                    ],
                    if (r.itemsFound.isNotEmpty) ...[
                      const Divider(height: 28),
                      const Text(
                        'お店に残っていたもの',
                        style: TextStyle(
                          fontSize: 12,
                          color: YohakuColors.paperDim,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final id in r.itemsFound)
                        Text('・${content.item(id).name}'),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('お店をのぞく'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
