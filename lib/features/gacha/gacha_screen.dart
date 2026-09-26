import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/engine/gacha_engine.dart';
import '../../core/models/content.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';
import '../shop/shop_screen.dart';

/// 08. 余白くじ。
///
/// 「課金すると強くなる」ではなく「課金すると世界が広がる」。
/// 排出率は常に画面に出す。天井あり。コンプリート報酬なし。
class GachaScreen extends ConsumerWidget {
  const GachaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final g = c.gacha;
    final ownedInPool = g.entries
        .where((e) => s.ownedItems.contains(e.itemId))
        .length;
    final remainingToPity = g.pityCount - s.gachaPity;

    return Scaffold(
      appBar: AppBar(title: Text(g.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.redeem_outlined,
                    size: 48,
                    color: YohakuColors.lamp,
                  ),
                  const SizedBox(height: 8),
                  const Text('お店に、小さな何かが増えるくじ。', style: TextStyle(height: 1.6)),
                  const SizedBox(height: 4),
                  Text(
                    '集めた数  $ownedInPool / ${g.entries.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: YohakuColors.paperDim,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: YohakuColors.ink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      ownedInPool == g.entries.length
                          ? 'すべて集まりました'
                          : 'あと $remainingToPity 回以内に、まだ持っていないものが必ず出ます',
                      style: const TextStyle(
                        fontSize: 12,
                        color: YohakuColors.moss,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'チケット  ${s.tickets} 枚',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: s.tickets >= 1
                              ? () => _draw(context, ref, 1)
                              : null,
                          child: const Text('1 回引く'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: s.tickets >= 10
                              ? () => _draw(context, ref, 10)
                              : null,
                          child: const Text('10 回引く'),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ShopScreen(),
                      ),
                    ),
                    child: const Text('チケットを手に入れる'),
                  ),
                  const Text(
                    'チケットは 1 日 1 枚配られるほか、お客さんが置いていくこともあります。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: YohakuColors.paperDim,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle('提供割合（排出率）'),
          Card(
            child: Column(
              children: [
                for (final r in Rarity.values)
                  ListTile(
                    dense: true,
                    title: Text(r.label),
                    trailing: Text(
                      '${((g.rarityRates[r] ?? 0) * 100).toStringAsFixed(1)}%',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (final e in g.entries)
                  ListTile(
                    dense: true,
                    leading: Icon(
                      s.ownedItems.contains(e.itemId)
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      size: 18,
                      color: s.ownedItems.contains(e.itemId)
                          ? YohakuColors.lamp
                          : YohakuColors.inkLine,
                    ),
                    title: Text(c.item(e.itemId).name),
                    subtitle: Text(
                      e.rarity.label,
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Text(
                      '${(g.rateOf(e) * 100).toStringAsFixed(2)}%',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '・出てくるのは家具・小物・BGM・演出だけです。お店の売上や客の数は変わりません。\n'
            '・${g.pityCount} 回引くまでに持っていないものが出なかった場合、次の 1 回は必ず持っていないものになります。\n'
            '・持っているものが出た場合は ${yen(g.duplicateRefund)} の売上に換わります。\n'
            '・特定の組み合わせを揃えることで得られる特典はありません。',
            style: const TextStyle(
              fontSize: 11,
              color: YohakuColors.paperDim,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  void _draw(BuildContext context, WidgetRef ref, int times) {
    final out = ref.read(gameProvider.notifier).drawGacha(times);
    if (out == null) return;
    final c = ref.read(contentProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: YohakuColors.inkRaised,
        title: const Text('余白くじ'),
        content: SizedBox(
          width: 320,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final d in out.draws)
                _DrawRow(draw: d, name: c.item(d.entry.itemId).name),
              if (out.refund > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    '持っていたものは ${yen(out.refund)} の売上になりました',
                    style: const TextStyle(
                      fontSize: 12,
                      color: YohakuColors.paperDim,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

class _DrawRow extends StatelessWidget {
  const _DrawRow({required this.draw, required this.name});

  final GachaDraw draw;
  final String name;

  @override
  Widget build(BuildContext context) {
    final color = switch (draw.entry.rarity) {
      Rarity.common => YohakuColors.moss,
      Rarity.rare => YohakuColors.lamp,
      Rarity.superRare => YohakuColors.rose,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          TagPill(draw.entry.rarity.label, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(name)),
          if (draw.isNew)
            const TagPill('NEW', color: YohakuColors.rose, filled: true),
          if (draw.byPity)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.verified_outlined,
                size: 16,
                color: YohakuColors.moss,
              ),
            ),
        ],
      ),
    );
  }
}
