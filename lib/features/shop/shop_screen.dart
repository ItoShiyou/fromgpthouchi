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

    Widget section(ProductType type, String title) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(title),
        for (final p in c.products.where((p) => p.type == type))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ProductCard(
              product: p,
              content: c,
              owned: !p.consumable && s.purchasedProducts.contains(p.id),
              onBuy: () => _buy(context, ref, p),
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('ショップ')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          section(ProductType.pack, '家具のセット'),
          section(ProductType.episode, 'プレミアムエピソード'),
          section(ProductType.tickets, '余白くじチケット'),
          section(ProductType.adFree, 'そのほか'),
          const SizedBox(height: 8),
          const Text(
            'これはモックです。実際の決済は行われません。',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: YohakuColors.rose),
          ),
        ],
      ),
    );
  }

  Future<void> _buy(BuildContext context, WidgetRef ref, ProductDef p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: YohakuColors.inkRaised,
        title: Text(p.name),
        content: Text('${yen(p.priceYen)} で購入します（モック：決済は発生しません）'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('やめる'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('購入する'),
          ),
        ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: YohakuColors.paperDim,
                      height: 1.6,
                    ),
                  ),
                  if (product.itemIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final id in product.itemIds)
                          TagPill(content.item(id).name),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            owned
                ? const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '購入済み',
                      style: TextStyle(fontSize: 12, color: YohakuColors.lamp),
                    ),
                  )
                : FilledButton(
                    onPressed: onBuy,
                    child: Text(yen(product.priceYen)),
                  ),
          ],
        ),
      ),
    );
  }
}
