import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/app.dart';
import 'package:yoru_kissa/core/models/content.dart';
import 'package:yoru_kissa/core/persistence/save_repository.dart';
import 'package:yoru_kissa/core/state/game_controller.dart';
import 'package:yoru_kissa/core/state/game_state.dart';
import 'package:yoru_kissa/titles/yoru_kissa/content.dart';

class _MemoryStore implements SaveStore {
  GameState? value;
  @override
  Future<void> clear() async => value = null;
  @override
  Future<GameState?> load() async => value;
  @override
  Future<void> save(GameState s) async => value = s;
}

/// 端末が無くても、画面をひと通りなぞって壊れていないことを確かめる。
void main() {
  late ProviderContainer container;

  Future<void> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // 9 時間前に閉じた店。家具もいくつか置いてある。
    final now = DateTime.now();
    final s =
        GameState.initial(
          yoruKissa,
          now.subtract(const Duration(hours: 9)),
        ).copyWith(
          money: 20000,
          tickets: 12,
          ownedItems: {
            ...GameState.initial(yoruKissa, now).ownedItems,
            'green_sofa',
            'stand_light',
          },
          placement: {
            PlacementSlot.table: 'round_table',
            PlacementSlot.window: 'lace_curtain',
            PlacementSlot.seat: 'green_sofa',
            PlacementSlot.light: 'stand_light',
          },
        );
    container = ProviderContainer(
      overrides: [
        saveRepositoryProvider.overrideWithValue(
          SaveRepository(_MemoryStore()),
        ),
        initialGameStateProvider.overrideWithValue(s),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const YohakuApp()),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> settle(WidgetTester tester) async {
    // 店の絵は動き続けるので pumpAndSettle は使わない
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  Future<void> closeAll(WidgetTester tester) async {
    // タイマー（20 秒ごとの精算）を止めるため、最後に画面を外す
    await tester.pumpWidget(const SizedBox());
    container.dispose();
  }

  Future<void> back(WidgetTester tester) async {
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await settle(tester);
  }

  testWidgets('はじめる → おかえりなさい → 出来事 → お店', (tester) async {
    await boot(tester);
    expect(find.text('はじめる'), findsOneWidget);
    await tester.tap(find.text('はじめる'));
    await settle(tester);

    expect(find.text('おかえりなさい'), findsOneWidget);
    expect(find.textContaining('経過しました'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await settle(tester);

    // 出来事があれば 1 つずつ閉じる
    for (var i = 0; i < 6 && find.text('できごと').evaluate().isNotEmpty; i++) {
      await tester.tap(find.text('OK'));
      await settle(tester);
    }
    expect(find.text('おかえりなさい'), findsNothing);
    expect(find.textContaining('レジ'), findsOneWidget);
    expect(container.read(gameProvider).pendingReport, isNull);
    await closeAll(tester);
  });

  testWidgets('下のしるしから各パネルを開ける', (tester) async {
    await boot(tester);
    await tester.tap(find.text('はじめる'));
    await settle(tester);
    while (find.text('OK').evaluate().isNotEmpty) {
      await tester.tap(find.text('OK').first);
      await settle(tester);
    }

    for (final (button, title) in const [
      ('お客様', '来店客一覧'),
      ('図鑑', '図鑑'),
      ('家具', '家具'),
      ('メニュー', 'メニュー'),
      ('くじ', '余白くじ'),
      ('ショップ', 'ショップ'),
    ]) {
      await tester.tap(find.text(button).last);
      await settle(tester);
      expect(find.text(title), findsWidgets, reason: button);
      await back(tester);
    }

    await tester.tap(find.byTooltip('設定'));
    await settle(tester);
    expect(find.text('設定'), findsWidgets);
    await back(tester);
    await closeAll(tester);
  });

  testWidgets('家具を買って置く・くじを引く・試作ストアで買う', (tester) async {
    await boot(tester);
    await tester.tap(find.text('はじめる'));
    await settle(tester);
    while (find.text('OK').evaluate().isNotEmpty) {
      await tester.tap(find.text('OK').first);
      await settle(tester);
    }

    // 家具：モンステラを選んで、買って置く
    await tester.tap(find.text('家具').last);
    await settle(tester);
    await tester.tap(find.text('モンステラ'));
    await settle(tester);
    final money = container.read(gameProvider).money;
    await tester.tap(find.textContaining('購入して配置'));
    await settle(tester);
    expect(
      container.read(gameProvider).placement[PlacementSlot.corner],
      'monstera',
    );
    expect(container.read(gameProvider).money, money - 3000);
    await back(tester);

    // くじ：1 回引くとチケットが 1 枚減り、結果が出る
    await tester.tap(find.text('くじ').last);
    await settle(tester);
    final tickets = container.read(gameProvider).tickets;
    await tester.tap(find.text('1回引く'));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(container.read(gameProvider).tickets, tickets - 1);
    expect(find.text('お店に戻す'), findsOneWidget);
    await tester.tap(find.text('お店に戻す'));
    await settle(tester);
    await back(tester);

    // ショップ：試作ストアで「広告なし」を買う
    await tester.tap(find.text('ショップ').last);
    await settle(tester);
    await tester.tap(find.text('広告なし'));
    await settle(tester);
    expect(find.textContaining('実際の決済はありません'), findsOneWidget);
    await tester.tap(find.text('購入する'));
    await settle(tester);
    expect(container.read(gameProvider).adFree, isTrue);
    expect(find.text('購入済み'), findsWidgets);
    await back(tester);
    await closeAll(tester);
  });
}
