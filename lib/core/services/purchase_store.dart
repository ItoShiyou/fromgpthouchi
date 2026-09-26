import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/content.dart';

/// ストアから届く出来事。
sealed class StoreEvent {
  const StoreEvent(this.productId);
  final String productId;
}

/// 支払いが済んだ（または復元された）。[transactionId] ごとに一度だけ付与する。
class StorePurchased extends StoreEvent {
  const StorePurchased(
    super.productId, {
    required this.transactionId,
    required this.restored,
    this.verificationData,
  });
  final String transactionId;
  final bool restored;

  /// レシート検証（Supabase Edge Function 等）に渡す生データ。
  final String? verificationData;
}

class StorePending extends StoreEvent {
  const StorePending(super.productId);
}

class StoreFailed extends StoreEvent {
  const StoreFailed(super.productId, {this.canceled = false, this.message});
  final bool canceled;
  final String? message;
}

/// 課金の窓口。ゲーム側はこのイベントだけを見て付与する。
abstract interface class PurchaseStore {
  Stream<StoreEvent> get events;

  /// ストアが使えるか。
  Future<bool> available();

  /// ストアに登録された表示価格（「¥320」など、地域の通貨）。取れなければ空。
  Future<Map<String, String>> localizedPrices(Iterable<String> productIds);

  Future<void> buy(ProductDef product);
  Future<void> restore();

  /// 付与が済んだことをストアに伝える（付与の後に呼ぶ）。
  Future<void> finish(StorePurchased event);

  /// true なら試作用。購入前に「実際の決済はありません」と確認を出す。
  bool get isMock;

  void dispose();
}

/// 試作用のストア。すぐに購入完了を返す。Web と、実ストア未設定のビルドで使う。
class MockPurchaseStore implements PurchaseStore {
  final _events = StreamController<StoreEvent>.broadcast();
  final _bought = <String>{};
  var _seq = 0;

  @override
  bool get isMock => true;

  @override
  Stream<StoreEvent> get events => _events.stream;

  @override
  Future<bool> available() async => true;

  @override
  Future<Map<String, String>> localizedPrices(
    Iterable<String> productIds,
  ) async => const {};

  @override
  Future<void> buy(ProductDef product) async {
    if (!product.consumable) _bought.add(product.id);
    _events.add(
      StorePurchased(
        product.id,
        transactionId:
            'mock-${DateTime.now().microsecondsSinceEpoch}-${_seq++}',
        restored: false,
      ),
    );
  }

  @override
  Future<void> restore() async {
    for (final id in _bought) {
      _events.add(
        StorePurchased(id, transactionId: 'mock-restore-$id', restored: true),
      );
    }
  }

  @override
  Future<void> finish(StorePurchased event) async {}

  @override
  void dispose() => _events.close();
}

/// App Store / Google Play（in_app_purchase）。
///
/// ストアの商品 ID は ProductDef.id と同じにしておく（docs/STORE_SETUP.md）。
class IapPurchaseStore implements PurchaseStore {
  IapPurchaseStore(this.products) {
    _sub = _iap.purchaseStream.listen(
      _onUpdates,
      onError: (Object e) => _events.add(StoreFailed('', message: '$e')),
    );
  }

  final List<ProductDef> products;
  final _iap = InAppPurchase.instance;
  final _events = StreamController<StoreEvent>.broadcast();
  late final StreamSubscription<List<PurchaseDetails>> _sub;
  final _details = <String, ProductDetails>{};
  final _pendingFinish = <String, PurchaseDetails>{};

  @override
  bool get isMock => false;

  @override
  Stream<StoreEvent> get events => _events.stream;

  @override
  Future<bool> available() => _iap.isAvailable();

  Future<void> _load(Iterable<String> ids) async {
    final missing = ids.where((id) => !_details.containsKey(id)).toSet();
    if (missing.isEmpty) return;
    final res = await _iap.queryProductDetails(missing);
    for (final d in res.productDetails) {
      _details[d.id] = d;
    }
  }

  @override
  Future<Map<String, String>> localizedPrices(
    Iterable<String> productIds,
  ) async {
    if (!await available()) return const {};
    await _load(productIds);
    return {
      for (final id in productIds)
        if (_details[id] != null) id: _details[id]!.price,
    };
  }

  @override
  Future<void> buy(ProductDef product) async {
    await _load([product.id]);
    final d = _details[product.id];
    if (d == null) {
      _events.add(StoreFailed(product.id, message: 'ストアに商品が見つかりません'));
      return;
    }
    final param = PurchaseParam(productDetails: d);
    if (product.consumable) {
      await _iap.buyConsumable(purchaseParam: param);
    } else {
      await _iap.buyNonConsumable(purchaseParam: param);
    }
  }

  @override
  Future<void> restore() => _iap.restorePurchases();

  void _onUpdates(List<PurchaseDetails> list) {
    for (final p in list) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _events.add(StorePending(p.productID));
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final id = p.purchaseID ?? '${p.productID}-${p.transactionDate}';
          if (p.pendingCompletePurchase) _pendingFinish[id] = p;
          _events.add(
            StorePurchased(
              p.productID,
              transactionId: id,
              restored: p.status == PurchaseStatus.restored,
              verificationData: p.verificationData.serverVerificationData,
            ),
          );
        case PurchaseStatus.canceled:
          _events.add(StoreFailed(p.productID, canceled: true));
          if (p.pendingCompletePurchase) _iap.completePurchase(p);
        case PurchaseStatus.error:
          _events.add(StoreFailed(p.productID, message: p.error?.message));
          if (p.pendingCompletePurchase) _iap.completePurchase(p);
      }
    }
  }

  @override
  Future<void> finish(StorePurchased event) async {
    final p = _pendingFinish.remove(event.transactionId);
    if (p != null) await _iap.completePurchase(p);
  }

  @override
  void dispose() {
    _sub.cancel();
    _events.close();
  }
}

/// 実ストアを使うのは `--dart-define=REAL_STORE=true` でビルドした端末だけ。
/// ストアに商品を登録するまでは試作用ストアで遊べるようにしておく。
const useRealStore = bool.fromEnvironment('REAL_STORE');

PurchaseStore createPurchaseStore(List<ProductDef> products) =>
    (!kIsWeb && useRealStore)
    ? IapPurchaseStore(products)
    : MockPurchaseStore();

/// レシートの検証。本番は Supabase Edge Function に投げて、
/// purchase_records に記録してから true を返す（supabase/README.md）。
abstract interface class ReceiptVerifier {
  Future<bool> verify(StorePurchased event);
}

/// 検証サーバーが無い間の既定。ストアが「購入済み」と言ったものを信じる。
class TrustingVerifier implements ReceiptVerifier {
  const TrustingVerifier();

  @override
  Future<bool> verify(StorePurchased event) async => true;
}
