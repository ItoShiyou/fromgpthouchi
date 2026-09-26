import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../titles/yoru_kissa/content.dart';
import '../engine/ambience.dart';
import '../engine/gacha_engine.dart';
import '../engine/idle_engine.dart';
import '../engine/world_engine.dart';
import '../models/content.dart';
import '../models/world.dart';
import '../persistence/save_repository.dart';
import 'game_state.dart';

/// 遊ぶタイトル。第 2 作ではここを差し替える。
final contentProvider = Provider<TitleContent>((ref) => yoruKissa);

/// main() で SharedPreferences を読み込んでから override する。
final saveRepositoryProvider = Provider<SaveRepository>(
  (ref) => throw UnimplementedError('override in main()'),
);

final gameProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);

/// 画面下に一瞬出す通知（保存しない）。
final noticeProvider = NotifierProvider<NoticeController, String?>(
  NoticeController.new,
);

class NoticeController extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String message) => state = message;
  void clear() => state = null;
}

/// 「特別な出来事」ポップアップの順番待ち（保存しない）。
final eventQueueProvider =
    NotifierProvider<EventQueueController, List<DiscoveredFragment>>(
      EventQueueController.new,
    );

class EventQueueController extends Notifier<List<DiscoveredFragment>> {
  @override
  List<DiscoveredFragment> build() => const [];

  void addAll(Iterable<DiscoveredFragment> f) => state = [...state, ...f];

  void pop() => state = state.isEmpty ? state : state.sublist(1);
}

/// 試遊用：店の絵の天気だけを差し替えて見る（計算には影響しない）。
final weatherPreviewProvider = NotifierProvider<WeatherPreview, Weather?>(
  WeatherPreview.new,
);

class WeatherPreview extends Notifier<Weather?> {
  @override
  Weather? build() => null;

  void set(Weather? w) => state = w;
}

/// 店の「思い出」レベル。見た目の進み具合だけで、性能には影響しない。
class ShopLevel {
  const ShopLevel(this.level, this.progress);

  final int level;
  final double progress;

  static const pointsPerLevel = 20;

  factory ShopLevel.of(GameState s) {
    final pts =
        s.visitors.length * 4 +
        s.fragments.length * 5 +
        s.ownedItems.length * 2 +
        s.ownedMenus.length * 2 +
        s.visitors.values.fold<int>(0, (a, v) => a + (v.visits ~/ 5));
    return ShopLevel(
      1 + pts ~/ pointsPerLevel,
      (pts % pointsPerLevel) / pointsPerLevel,
    );
  }
}

/// 今、成立している雰囲気。
final ambiencesProvider = Provider<List<AmbienceDef>>((ref) {
  final content = ref.watch(contentProvider);
  final placement = ref.watch(gameProvider.select((s) => s.placement));
  return AmbienceResolver(content).resolve(placement.values);
});

class GameController extends Notifier<GameState> {
  late TitleContent _content;
  late SaveRepository _repo;
  late IdleEngine _idle;
  late GachaEngine _gacha;

  /// これより短い不在では「おかえりなさい」を出さない。
  static const reportThreshold = Duration(minutes: 10);

  @override
  GameState build() {
    _content = ref.watch(contentProvider);
    _repo = ref.watch(saveRepositoryProvider);
    _idle = IdleEngine(_content);
    _gacha = GachaEngine(_content.gacha);
    return _repo.load() ?? GameState.initial(_content, DateTime.now());
  }

  TitleContent get content => _content;

  void _set(GameState s) {
    state = s;
    _repo.save(s);
  }

  /// ゲーム内の現在時刻（デバッグの時間送りを含む）。
  DateTime now() =>
      DateTime.now().add(Duration(minutes: state.debugOffsetMinutes));

  WorldMoment currentMoment() {
    final m = WorldEngine(_content).momentAt(now());
    final preview = ref.read(weatherPreviewProvider);
    if (preview == null) return m;
    return WorldMoment(
      time: m.time,
      slot: m.slot,
      weather: preview,
      season: m.season,
    );
  }

  // ---------------------------------------------------------------------------
  // 放置
  // ---------------------------------------------------------------------------

  /// 前回からの時間を精算する。
  /// [showReport] が true なら、十分に時間が経っていれば「おかえりなさい」を出す。
  void catchUp({required bool showReport}) {
    final result = _idle.run(state, now());
    final r = result.report;
    var next = result.state;
    final longEnough = r.elapsed >= reportThreshold;
    if (showReport && longEnough) {
      next = next.copyWith(pendingReport: _merge(state.pendingReport, r));
    } else if (r.newFragments.isNotEmpty) {
      ref.read(eventQueueProvider.notifier).addAll(r.newFragments);
    } else if (r.newVisitorIds.isNotEmpty) {
      final v = _content.visitor(r.newVisitorIds.last);
      ref.read(noticeProvider.notifier).show('はじめてのお客さん：${v.silhouetteName}');
    }
    _set(next);
  }

  IdleReport _merge(IdleReport? a, IdleReport b) {
    if (a == null) return b;
    return IdleReport(
      from: a.from,
      to: b.to,
      elapsed: a.elapsed + b.elapsed,
      effective: a.effective + b.effective,
      income: a.income + b.income,
      visitCount: a.visitCount + b.visitCount,
      newVisitorIds: [...a.newVisitorIds, ...b.newVisitorIds],
      newFragments: [...a.newFragments, ...b.newFragments],
      ticketsEarned: a.ticketsEarned + b.ticketsEarned,
      itemsFound: [...a.itemsFound, ...b.itemsFound],
    );
  }

  void dismissReport() => _set(state.copyWith(pendingReport: null));

  /// 座っている客をタップして会計する。
  SeatedGuest? collectGuest(int index) {
    if (index < 0 || index >= state.seated.length) return null;
    final guest = state.seated[index];
    final seated = List.of(state.seated)..removeAt(index);
    _set(state.copyWith(money: state.money + guest.bill, seated: seated));
    return guest;
  }

  int collectRegister() {
    final amount = state.register;
    if (amount == 0) return 0;
    _set(state.copyWith(money: state.money + amount, register: 0));
    return amount;
  }

  int collectAll() {
    final amount = state.uncollected;
    _set(state.copyWith(money: state.money + amount, register: 0, seated: []));
    return amount;
  }

  // ---------------------------------------------------------------------------
  // 家具・メニュー
  // ---------------------------------------------------------------------------

  bool buyItem(String itemId) {
    final item = _content.item(itemId);
    final price = item.price;
    if (price == null || state.money < price) return false;
    if (state.ownedItems.contains(itemId)) return false;
    _set(
      state.copyWith(
        money: state.money - price,
        ownedItems: {...state.ownedItems, itemId},
      ),
    );
    return true;
  }

  void place(String itemId) {
    final slot = _content.item(itemId).slot;
    if (slot == null || !state.ownedItems.contains(itemId)) return;
    _set(state.copyWith(placement: {...state.placement, slot: itemId}));
  }

  void clearSlot(PlacementSlot slot) {
    final placement = Map.of(state.placement)..remove(slot);
    _set(state.copyWith(placement: placement));
  }

  bool unlockMenu(String menuId) {
    final m = _content.menu(menuId);
    if (state.ownedMenus.contains(menuId) || state.money < m.unlockCost) {
      return false;
    }
    _set(
      state.copyWith(
        money: state.money - m.unlockCost,
        ownedMenus: {...state.ownedMenus, menuId},
      ),
    );
    return true;
  }

  void setBgm(String? itemId) => _set(state.copyWith(activeBgm: itemId));

  void toggleEffect(String itemId) {
    final fx = Set.of(state.activeEffects);
    if (!fx.remove(itemId)) fx.add(itemId);
    _set(state.copyWith(activeEffects: fx));
  }

  // ---------------------------------------------------------------------------
  // 余白くじ・ショップ（IAP はモック）
  // ---------------------------------------------------------------------------

  GachaOutcome? drawGacha(int times) {
    if (state.tickets < times) return null;
    final out = _gacha.draw(
      times: times,
      owned: state.ownedItems,
      pity: state.gachaPity,
    );
    _set(
      state.copyWith(
        tickets: state.tickets - times,
        ownedItems: {
          ...state.ownedItems,
          for (final d in out.draws) d.entry.itemId,
        },
        gachaPity: out.pityAfter,
        gachaDraws: state.gachaDraws + times,
        money: state.money + out.refund,
      ),
    );
    return out;
  }

  /// 実装時は in_app_purchase の購入完了コールバックからここを呼ぶ。
  void completePurchase(String productId) {
    final p = _content.product(productId);
    var s = state.copyWith(
      purchasedProducts: {...state.purchasedProducts, productId},
    );
    switch (p.type) {
      case ProductType.adFree:
        s = s.copyWith(adFree: true);
      case ProductType.pack:
        s = s.copyWith(ownedItems: {...s.ownedItems, ...p.itemIds});
      case ProductType.episode:
        s = s.copyWith(episodes: {...s.episodes, p.episodeId!});
      case ProductType.tickets:
        s = s.copyWith(tickets: s.tickets + p.tickets);
    }
    _set(s);
  }

  // ---------------------------------------------------------------------------
  // 設定・デバッグ
  // ---------------------------------------------------------------------------

  void updateSettings(GameSettings settings) =>
      _set(state.copyWith(settings: settings));

  /// 時間を進めて、アプリを閉じていたのと同じ状態を作る。
  void debugAdvance(Duration d) {
    _set(
      state.copyWith(
        debugOffsetMinutes: state.debugOffsetMinutes + d.inMinutes,
      ),
    );
    catchUp(showReport: true);
  }

  void debugAddMoney(int amount) =>
      _set(state.copyWith(money: state.money + amount));

  void debugAddTickets(int n) =>
      _set(state.copyWith(tickets: state.tickets + n));

  Future<void> reset() async {
    await _repo.clear();
    state = GameState.initial(_content, DateTime.now());
  }

  String exportSave() => _repo.export(state);
}
