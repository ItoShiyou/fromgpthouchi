import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/core/models/content.dart';
import 'package:yoru_kissa/core/persistence/save_repository.dart';
import 'package:yoru_kissa/core/services/purchase_store.dart';
import 'package:yoru_kissa/core/state/game_controller.dart';
import 'package:yoru_kissa/core/state/game_state.dart';
import 'package:yoru_kissa/core/state/purchase_controller.dart';
import 'package:yoru_kissa/titles/yoru_kissa/content.dart';

class _NullStore implements SaveStore {
  @override
  Future<void> clear() async {}
  @override
  Future<GameState?> load() async => null;
  @override
  Future<void> save(GameState s) async {}
}

/// ストアの挙動を手で起こせる偽物。
class _FakeStore implements PurchaseStore {
  final _events = StreamController<StoreEvent>.broadcast();
  final finished = <String>[];

  void emit(StoreEvent e) => _events.add(e);

  @override
  bool get isMock => false;
  @override
  Stream<StoreEvent> get events => _events.stream;
  @override
  Future<bool> available() async => true;
  @override
  Future<Map<String, String>> localizedPrices(Iterable<String> ids) async => {
    'ad_free': '¥700',
  };
  @override
  Future<void> buy(ProductDef product) async {}
  @override
  Future<void> restore() async {}
  @override
  Future<void> finish(StorePurchased event) async =>
      finished.add(event.transactionId);
  @override
  void dispose() => _events.close();
}

class _Reject implements ReceiptVerifier {
  @override
  Future<bool> verify(StorePurchased event) async => false;
}

void main() {
  ProviderContainer make(_FakeStore store, {ReceiptVerifier? verifier}) =>
      ProviderContainer(
        overrides: [
          saveRepositoryProvider.overrideWithValue(
            SaveRepository(_NullStore()),
          ),
          initialGameStateProvider.overrideWithValue(
            GameState.initial(yoruKissa, DateTime(2026, 9, 26)),
          ),
          purchaseStoreProvider.overrideWithValue(store),
          receiptVerifierProvider.overrideWithValue(
            verifier ?? const TrustingVerifier(),
          ),
        ],
      );

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 10));

  test('購入が届いたら付与して、ストアに完了を伝える', () async {
    final store = _FakeStore();
    final c = make(store);
    c.read(purchaseProvider);
    store.emit(
      const StorePurchased('ad_free', transactionId: 'T1', restored: false),
    );
    await settle();
    expect(c.read(gameProvider).adFree, isTrue);
    expect(store.finished, ['T1']);
    c.dispose();
  });

  test('同じ取引が二度届いても、チケットは一度しか増えない', () async {
    final store = _FakeStore();
    final c = make(store);
    c.read(purchaseProvider);
    final before = c.read(gameProvider).tickets;
    for (var i = 0; i < 2; i++) {
      store.emit(
        const StorePurchased(
          'tickets_11',
          transactionId: 'T2',
          restored: false,
        ),
      );
      await settle();
    }
    expect(c.read(gameProvider).tickets, before + 11);
    expect(store.finished, ['T2', 'T2']);
    c.dispose();
  });

  test('別の取引なら、同じ商品でも毎回付与する', () async {
    final store = _FakeStore();
    final c = make(store);
    c.read(purchaseProvider);
    final before = c.read(gameProvider).tickets;
    store.emit(
      const StorePurchased('tickets_5', transactionId: 'A', restored: false),
    );
    store.emit(
      const StorePurchased('tickets_5', transactionId: 'B', restored: false),
    );
    await settle();
    expect(c.read(gameProvider).tickets, before + 10);
    c.dispose();
  });

  test('検証に通らなければ付与しない（完了も伝えない）', () async {
    final store = _FakeStore();
    final c = make(store, verifier: _Reject());
    c.read(purchaseProvider);
    store.emit(
      const StorePurchased('pack_moon', transactionId: 'X', restored: false),
    );
    await settle();
    expect(c.read(gameProvider).ownedItems.contains('moon_window'), isFalse);
    expect(store.finished, isEmpty);
    c.dispose();
  });

  test('ストアの表示価格を使う', () async {
    final store = _FakeStore();
    final c = make(store);
    c.read(purchaseProvider);
    await settle();
    expect(c.read(purchaseProvider).prices['ad_free'], '¥700');
    c.dispose();
  });

  test('試作用ストアでも同じ流れで付与される（Web）', () async {
    final c = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(SaveRepository(_NullStore())),
        initialGameStateProvider.overrideWithValue(
          GameState.initial(yoruKissa, DateTime(2026, 9, 26)),
        ),
      ],
    );
    await c
        .read(purchaseProvider.notifier)
        .buy(yoruKissa.product('ep_rain_three'));
    await settle();
    expect(c.read(gameProvider).episodes, contains('rain_three'));
    c.dispose();
  });
}
