import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/models/content.dart';
import '../../core/state/game_controller.dart';
import '../../core/state/purchase_controller.dart';
import '../../widgets/common.dart';

/// 09. ショップ ― 直接購入。
///
/// 課金は 4 種類だけ：広告削除 / 家具セット / 余白くじチケット / プレミアムエピソード。
/// 支払いはストア（PurchaseStore）に任せ、付与は PurchaseController が行う。
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final shop = ref.watch(purchaseProvider);

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
                  price: shop.prices[p.id] ?? yen(p.priceYen),
                  busy: shop.busy.contains(p.id),
                  onBuy: () => _buy(context, ref, p),
                ),
              ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => ref.read(purchaseProvider.notifier).restore(),
                child: const Text('購入を復元'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _buy(BuildContext context, WidgetRef ref, ProductDef p) async {
    final purchases = ref.read(purchaseProvider.notifier);
    // 実ストアでは OS の購入シートが確認を兼ねるので、ここでは何も出さない。
    if (!purchases.isMock) {
      await purchases.buy(p);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => PaperDialog(
        buttonLabel: '購入する',
        onButton: () => Navigator.of(ctx).pop(true),
        child: Column(
          children: [
            IconTile(p.icon, size: 64, artId: p.id),
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
    await purchases.buy(p);
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.content,
    required this.owned,
    required this.price,
    required this.busy,
    required this.onBuy,
  });

  final ProductDef product;
  final TitleContent content;
  final bool owned;
  final String price;
  final bool busy;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      onTap: owned || busy ? null : onBuy,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconTile(product.icon, size: 60, artId: product.id),
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
                    owned
                        ? '購入済み'
                        : busy
                        ? '手続き中…'
                        : price,
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
