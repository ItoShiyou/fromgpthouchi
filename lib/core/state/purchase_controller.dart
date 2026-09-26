import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/content.dart';
import '../services/purchase_store.dart';
import 'game_controller.dart';

/// 課金の窓口。main() で端末用の実装に差し替える。
final purchaseStoreProvider = Provider<PurchaseStore>((ref) {
  final store = MockPurchaseStore();
  ref.onDispose(store.dispose);
  return store;
});

final receiptVerifierProvider = Provider<ReceiptVerifier>(
  (ref) => const TrustingVerifier(),
);

class PurchaseUiState {
  const PurchaseUiState({this.prices = const {}, this.busy = const {}});

  /// ストアの表示価格。取れない間は ProductDef.priceYen を出す。
  final Map<String, String> prices;

  /// 支払い中の商品。
  final Set<String> busy;

  PurchaseUiState copyWith({Map<String, String>? prices, Set<String>? busy}) =>
      PurchaseUiState(prices: prices ?? this.prices, busy: busy ?? this.busy);
}

final purchaseProvider = NotifierProvider<PurchaseController, PurchaseUiState>(
  PurchaseController.new,
);

/// ストアの出来事を受けて、検証 → 付与（取引ごとに一度だけ）→ ストアに完了を伝える。
class PurchaseController extends Notifier<PurchaseUiState> {
  late PurchaseStore _store;

  @override
  PurchaseUiState build() {
    _store = ref.watch(purchaseStoreProvider);
    final sub = _store.events.listen(_onEvent);
    ref.onDispose(sub.cancel);
    unawaited(_loadPrices());
    return const PurchaseUiState();
  }

  bool get isMock => _store.isMock;

  Future<void> _loadPrices() async {
    final ids = ref.read(contentProvider).products.map((p) => p.id);
    final prices = await _store.localizedPrices(ids);
    if (prices.isNotEmpty) state = state.copyWith(prices: prices);
  }

  Future<void> buy(ProductDef p) async {
    state = state.copyWith(busy: {...state.busy, p.id});
    try {
      await _store.buy(p);
    } catch (e) {
      _done(p.id);
      _notice('購入できませんでした');
    }
  }

  Future<void> restore() async {
    await _store.restore();
    _notice('購入の記録を確認しています');
  }

  Future<void> _onEvent(StoreEvent e) async {
    final content = ref.read(contentProvider);
    switch (e) {
      case StorePurchased():
        final game = ref.read(gameProvider.notifier);
        if (ref.read(gameProvider).grantedReceipts.contains(e.transactionId)) {
          await _store.finish(e);
          _done(e.productId);
          return;
        }
        if (!await ref.read(receiptVerifierProvider).verify(e)) {
          _done(e.productId);
          _notice('購入を確認できませんでした。時間をおいて「購入を復元」を試してください');
          return;
        }
        final granted = game.completePurchase(
          e.productId,
          transactionId: e.transactionId,
        );
        await _store.finish(e);
        _done(e.productId);
        if (granted) {
          ref
              .read(analyticsProvider)
              .purchased(e.productId, restored: e.restored);
          final name = content.product(e.productId).name;
          _notice(e.restored ? '「$name」を復元しました' : '「$name」を購入しました');
        }
      case StorePending():
        _notice('支払いの確認を待っています');
      case StoreFailed():
        _done(e.productId);
        if (!e.canceled) _notice('購入できませんでした');
    }
  }

  void _done(String id) =>
      state = state.copyWith(busy: {...state.busy}..remove(id));

  void _notice(String m) => ref.read(noticeProvider.notifier).show(m);
}
