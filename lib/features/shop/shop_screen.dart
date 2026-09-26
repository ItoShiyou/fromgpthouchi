import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/models/content.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';

/// 09. ショップ ― 直接購入。
///
/// 課金は 4 種類だけ：広告削除 / 家具セット / 余白くじチケット / プレミアムエピソード。
/// モックでは IAP を呼ばず、確認ダイアログの後に購入済みとして扱う。
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);

    return PaperPage(
      title: 'ショップ',
      tabs: const ['おすすめ', 'アイテム', 'チケット'],
      builder: (context, tab) {
        final products = c.products.where((p) {
          return switch (tab) {
            0 => p.recommended,
            1 =>
              p.type == ProductType.pack ||
                  p.type == ProductType.episode ||
                  p.type == ProductType.adFree,
            _ => p.type == ProductType.tickets,
          };
        }).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
          children: [
            for (final p in products)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ProductCard(
                  product: p,
                  content: c,
                  owned: !p.consumable && s.purchasedProducts.contains(p.id),
                  onBuy: () => _buy(context, ref, p),
                ),
              ),
            const SizedBox(height: 4),
          ],
        );
      },
    );
  }

  Future<void> _buy(BuildContext context, WidgetRef ref, ProductDef p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => PaperDialog(
        buttonLabel: '購入する',
        onButton: () => Navigator.of(ctx).pop(true),
        child: Column(
          children: [
            IconTile(p.icon, size: 64),
            const SizedBox(height: 10),
            Text(
              p.name,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              '${yen(p.priceYen)} で購入します',
              style: const TextStyle(fontSize: 13),
            ),
            const Text(
              '（試作版のため、実際の決済はありません）',
              style: TextStyle(fontSize: 10, color: YohakuColors.inkDim),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('やめる'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    ref.read(gameProvider.notifier).completePurchase(p.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('「${p.name}」を購入しました')));
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.content,
    required this.owned,
    required this.onBuy,
  });

  final ProductDef product;
  final TitleContent content;
  final bool owned;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      onTap: owned ? null : onBuy,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconTile(product.icon, size: 60),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: YohakuColors.inkDim,
                    height: 1.5,
                  ),
                ),
                if (product.itemIds.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.itemIds
                        .map((id) => content.item(id).name)
                        .join('・'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: YohakuColors.ink,
                    ),
                  ),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    owned ? '購入済み' : yen(product.priceYen),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: owned ? 12 : 15,
                      color: owned ? YohakuColors.moss : YohakuColors.ink,
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
}
