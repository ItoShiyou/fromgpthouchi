/// プレイヤーのセーブデータ。ローカルファースト（端末に JSON で保存）。
///
/// 本実装では Drift(SQLite) のテーブル
/// player_state / inventory / furniture / visitor_state / event_state
/// に分割する想定。モックでは 1 つの JSON にまとめている。
library;

import '../models/content.dart';

class VisitorRecord {
  const VisitorRecord({
    required this.visits,
    required this.firstSeenAt,
    required this.lastSeenAt,
    this.favoriteKnown = false,
  });

  final int visits;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;

  /// 好物を注文するところを見たか。
  final bool favoriteKnown;

  VisitorRecord copyWith({
    int? visits,
    DateTime? lastSeenAt,
    bool? favoriteKnown,
  }) => VisitorRecord(
    visits: visits ?? this.visits,
    firstSeenAt: firstSeenAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    favoriteKnown: favoriteKnown ?? this.favoriteKnown,
  );

  Map<String, dynamic> toJson() => {
    'v': visits,
    'f': firstSeenAt.toIso8601String(),
    'l': lastSeenAt.toIso8601String(),
    'fav': favoriteKnown,
  };

  factory VisitorRecord.fromJson(Map<String, dynamic> j) => VisitorRecord(
    visits: j['v'] as int,
    firstSeenAt: DateTime.parse(j['f'] as String),
    lastSeenAt: DateTime.parse(j['l'] as String),
    favoriteKnown: j['fav'] as bool? ?? false,
  );
}

class StoryProgress {
  const StoryProgress({required this.nextStep, required this.lastStepAt});

  /// 次に発生する段階（= 発見済みの段階数）。
  final int nextStep;
  final DateTime? lastStepAt;

  Map<String, dynamic> toJson() => {
    'n': nextStep,
    'l': lastStepAt?.toIso8601String(),
  };

  factory StoryProgress.fromJson(Map<String, dynamic> j) => StoryProgress(
    nextStep: j['n'] as int,
    lastStepAt: j['l'] == null ? null : DateTime.parse(j['l'] as String),
  );
}

/// 発見した出来事の 1 段階。
class DiscoveredFragment {
  const DiscoveredFragment({
    required this.chainId,
    required this.step,
    required this.at,
  });

  final String chainId;
  final int step;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'c': chainId,
    's': step,
    'a': at.toIso8601String(),
  };

  factory DiscoveredFragment.fromJson(Map<String, dynamic> j) =>
      DiscoveredFragment(
        chainId: j['c'] as String,
        step: j['s'] as int,
        at: DateTime.parse(j['a'] as String),
      );
}

/// 1 回の来店。visitorId が null なら通りすがりの客。
class Visit {
  const Visit({required this.at, required this.menuId, this.visitorId});

  final DateTime at;
  final String? visitorId;
  final String menuId;

  Map<String, dynamic> toJson() => {
    'a': at.toIso8601String(),
    'v': visitorId,
    'm': menuId,
  };

  factory Visit.fromJson(Map<String, dynamic> j) => Visit(
    at: DateTime.parse(j['a'] as String),
    visitorId: j['v'] as String?,
    menuId: j['m'] as String,
  );
}

/// 店内に座っている客。タップすると売上を回収できる。
class SeatedGuest {
  const SeatedGuest({required this.visit, required this.bill, this.seat = -1});

  final Visit visit;
  final int bill;

  /// 座っている席の番号。-1 は未割り当て。
  /// 他の客が会計しても、残った客が席を移らないように保持する。
  final int seat;

  SeatedGuest withSeat(int seat) =>
      SeatedGuest(visit: visit, bill: bill, seat: seat);

  Map<String, dynamic> toJson() => {
    'visit': visit.toJson(),
    'bill': bill,
    'seat': seat,
  };

  factory SeatedGuest.fromJson(Map<String, dynamic> j) => SeatedGuest(
    visit: Visit.fromJson(j['visit'] as Map<String, dynamic>),
    bill: j['bill'] as int,
    seat: j['seat'] as int? ?? -1,
  );
}

/// 起動時の「おかえりなさい」画面に出す放置結果。
class IdleReport {
  const IdleReport({
    required this.from,
    required this.to,
    required this.elapsed,
    required this.effective,
    required this.income,
    required this.visitCount,
    required this.newVisitorIds,
    required this.newFragments,
    required this.ticketsEarned,
    required this.itemsFound,
  });

  final DateTime from;
  final DateTime to;
  final Duration elapsed;

  /// 上限（12 時間）を適用した営業時間。
  final Duration effective;
  final int income;
  final int visitCount;
  final List<String> newVisitorIds;
  final List<DiscoveredFragment> newFragments;
  final int ticketsEarned;
  final List<String> itemsFound;

  bool get isCapped => elapsed > effective;
  bool get isEmpty => visitCount == 0 && newFragments.isEmpty;

  Map<String, dynamic> toJson() => {
    'from': from.toIso8601String(),
    'to': to.toIso8601String(),
    'el': elapsed.inSeconds,
    'ef': effective.inSeconds,
    'inc': income,
    'vc': visitCount,
    'nv': newVisitorIds,
    'nf': newFragments.map((e) => e.toJson()).toList(),
    't': ticketsEarned,
    'it': itemsFound,
  };

  factory IdleReport.fromJson(Map<String, dynamic> j) => IdleReport(
    from: DateTime.parse(j['from'] as String),
    to: DateTime.parse(j['to'] as String),
    elapsed: Duration(seconds: j['el'] as int),
    effective: Duration(seconds: j['ef'] as int),
    income: j['inc'] as int,
    visitCount: j['vc'] as int,
    newVisitorIds: (j['nv'] as List).cast<String>(),
    newFragments: (j['nf'] as List)
        .map((e) => DiscoveredFragment.fromJson(e as Map<String, dynamic>))
        .toList(),
    ticketsEarned: j['t'] as int,
    itemsFound: (j['it'] as List).cast<String>(),
  );
}

class GameSettings {
  const GameSettings({
    this.bgmOn = true,
    this.seOn = true,
    this.notificationsOn = true,
  });

  final bool bgmOn;
  final bool seOn;
  final bool notificationsOn;

  GameSettings copyWith({bool? bgmOn, bool? seOn, bool? notificationsOn}) =>
      GameSettings(
        bgmOn: bgmOn ?? this.bgmOn,
        seOn: seOn ?? this.seOn,
        notificationsOn: notificationsOn ?? this.notificationsOn,
      );

  Map<String, dynamic> toJson() => {
    'bgm': bgmOn,
    'se': seOn,
    'notif': notificationsOn,
  };

  factory GameSettings.fromJson(Map<String, dynamic> j) => GameSettings(
    bgmOn: j['bgm'] as bool? ?? true,
    seOn: j['se'] as bool? ?? true,
    notificationsOn: j['notif'] as bool? ?? true,
  );
}

class GameState {
  const GameState({
    required this.money,
    required this.register,
    required this.tickets,
    required this.ownedItems,
    required this.placement,
    required this.ownedMenus,
    required this.visitors,
    required this.stories,
    required this.fragments,
    required this.recentVisits,
    required this.seated,
    required this.lastSimulatedAt,
    required this.lastDailyTicketDate,
    required this.gachaPity,
    required this.gachaDraws,
    required this.adFree,
    required this.purchasedProducts,
    required this.episodes,
    required this.activeBgm,
    required this.activeEffects,
    required this.debugOffsetMinutes,
    required this.settings,
    this.pendingReport,
    this.grantedReceipts = const {},
  });

  /// 使える売上。
  final int money;

  /// レジに溜まっている未回収の売上。
  final int register;
  final int tickets;
  final Set<String> ownedItems;
  final Map<PlacementSlot, String> placement;
  final Set<String> ownedMenus;
  final Map<String, VisitorRecord> visitors;
  final Map<String, StoryProgress> stories;
  final List<DiscoveredFragment> fragments;

  /// 客一覧用の直近の来店ログ（新しい順、最大 60 件）。
  final List<Visit> recentVisits;
  final List<SeatedGuest> seated;
  final DateTime lastSimulatedAt;
  final String? lastDailyTicketDate;

  /// 未所持が出ていない連続回数（天井カウンタ）。
  final int gachaPity;
  final int gachaDraws;
  final bool adFree;
  final Set<String> purchasedProducts;
  final Set<String> episodes;
  final String? activeBgm;
  final Set<String> activeEffects;

  /// デバッグ用の時間送り（分）。
  final int debugOffsetMinutes;
  final GameSettings settings;
  final IdleReport? pendingReport;

  /// 付与済みの購入（ストアの取引 ID）。同じ購入が二度届いても二重に渡さない。
  final Set<String> grantedReceipts;

  factory GameState.initial(TitleContent c, DateTime now) => GameState(
    money: c.initialMoney,
    register: 0,
    tickets: 1,
    ownedItems: {
      for (final i in c.items)
        if (i.source == ItemSource.initial) i.id,
    },
    placement: Map.of(c.initialPlacement),
    ownedMenus: {
      for (final m in c.menus)
        if (m.unlockCost == 0) m.id,
    },
    visitors: const {},
    stories: const {},
    fragments: const [],
    recentVisits: const [],
    seated: const [],
    lastSimulatedAt: now,
    lastDailyTicketDate: null,
    gachaPity: 0,
    gachaDraws: 0,
    adFree: false,
    purchasedProducts: const {},
    episodes: const {},
    activeBgm: null,
    activeEffects: const {},
    debugOffsetMinutes: 0,
    settings: const GameSettings(),
  );

  int get uncollected =>
      register + seated.fold<int>(0, (sum, g) => sum + g.bill);

  static const _unset = Object();

  GameState copyWith({
    int? money,
    int? register,
    int? tickets,
    Set<String>? ownedItems,
    Map<PlacementSlot, String>? placement,
    Set<String>? ownedMenus,
    Map<String, VisitorRecord>? visitors,
    Map<String, StoryProgress>? stories,
    List<DiscoveredFragment>? fragments,
    List<Visit>? recentVisits,
    List<SeatedGuest>? seated,
    DateTime? lastSimulatedAt,
    String? lastDailyTicketDate,
    int? gachaPity,
    int? gachaDraws,
    bool? adFree,
    Set<String>? purchasedProducts,
    Set<String>? episodes,
    Object? activeBgm = _unset,
    Set<String>? activeEffects,
    int? debugOffsetMinutes,
    GameSettings? settings,
    Object? pendingReport = _unset,
    Set<String>? grantedReceipts,
  }) => GameState(
    money: money ?? this.money,
    register: register ?? this.register,
    tickets: tickets ?? this.tickets,
    ownedItems: ownedItems ?? this.ownedItems,
    placement: placement ?? this.placement,
    ownedMenus: ownedMenus ?? this.ownedMenus,
    visitors: visitors ?? this.visitors,
    stories: stories ?? this.stories,
    fragments: fragments ?? this.fragments,
    recentVisits: recentVisits ?? this.recentVisits,
    seated: seated ?? this.seated,
    lastSimulatedAt: lastSimulatedAt ?? this.lastSimulatedAt,
    lastDailyTicketDate: lastDailyTicketDate ?? this.lastDailyTicketDate,
    gachaPity: gachaPity ?? this.gachaPity,
    gachaDraws: gachaDraws ?? this.gachaDraws,
    adFree: adFree ?? this.adFree,
    purchasedProducts: purchasedProducts ?? this.purchasedProducts,
    episodes: episodes ?? this.episodes,
    activeBgm: identical(activeBgm, _unset)
        ? this.activeBgm
        : activeBgm as String?,
    activeEffects: activeEffects ?? this.activeEffects,
    debugOffsetMinutes: debugOffsetMinutes ?? this.debugOffsetMinutes,
    settings: settings ?? this.settings,
    pendingReport: identical(pendingReport, _unset)
        ? this.pendingReport
        : pendingReport as IdleReport?,
    grantedReceipts: grantedReceipts ?? this.grantedReceipts,
  );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'money': money,
    'register': register,
    'tickets': tickets,
    'ownedItems': ownedItems.toList(),
    'placement': {for (final e in placement.entries) e.key.name: e.value},
    'ownedMenus': ownedMenus.toList(),
    'visitors': {for (final e in visitors.entries) e.key: e.value.toJson()},
    'stories': {for (final e in stories.entries) e.key: e.value.toJson()},
    'fragments': fragments.map((e) => e.toJson()).toList(),
    'recentVisits': recentVisits.map((e) => e.toJson()).toList(),
    'seated': seated.map((e) => e.toJson()).toList(),
    'lastSimulatedAt': lastSimulatedAt.toIso8601String(),
    'lastDailyTicketDate': lastDailyTicketDate,
    'gachaPity': gachaPity,
    'gachaDraws': gachaDraws,
    'adFree': adFree,
    'purchasedProducts': purchasedProducts.toList(),
    'episodes': episodes.toList(),
    'activeBgm': activeBgm,
    'activeEffects': activeEffects.toList(),
    'debugOffsetMinutes': debugOffsetMinutes,
    'settings': settings.toJson(),
    'pendingReport': pendingReport?.toJson(),
    'grantedReceipts': grantedReceipts.toList(),
  };

  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
    money: j['money'] as int,
    register: j['register'] as int,
    tickets: j['tickets'] as int,
    ownedItems: (j['ownedItems'] as List).cast<String>().toSet(),
    placement: {
      for (final e in (j['placement'] as Map<String, dynamic>).entries)
        PlacementSlot.values.byName(e.key): e.value as String,
    },
    ownedMenus: (j['ownedMenus'] as List).cast<String>().toSet(),
    visitors: {
      for (final e in (j['visitors'] as Map<String, dynamic>).entries)
        e.key: VisitorRecord.fromJson(e.value as Map<String, dynamic>),
    },
    stories: {
      for (final e in (j['stories'] as Map<String, dynamic>).entries)
        e.key: StoryProgress.fromJson(e.value as Map<String, dynamic>),
    },
    fragments: (j['fragments'] as List)
        .map((e) => DiscoveredFragment.fromJson(e as Map<String, dynamic>))
        .toList(),
    recentVisits: (j['recentVisits'] as List)
        .map((e) => Visit.fromJson(e as Map<String, dynamic>))
        .toList(),
    seated: (j['seated'] as List)
        .map((e) => SeatedGuest.fromJson(e as Map<String, dynamic>))
        .toList(),
    lastSimulatedAt: DateTime.parse(j['lastSimulatedAt'] as String),
    lastDailyTicketDate: j['lastDailyTicketDate'] as String?,
    gachaPity: j['gachaPity'] as int,
    gachaDraws: j['gachaDraws'] as int? ?? 0,
    adFree: j['adFree'] as bool,
    purchasedProducts: (j['purchasedProducts'] as List).cast<String>().toSet(),
    episodes: (j['episodes'] as List).cast<String>().toSet(),
    activeBgm: j['activeBgm'] as String?,
    activeEffects: (j['activeEffects'] as List).cast<String>().toSet(),
    debugOffsetMinutes: j['debugOffsetMinutes'] as int? ?? 0,
    settings: GameSettings.fromJson(
      (j['settings'] as Map<String, dynamic>?) ?? const {},
    ),
    pendingReport: j['pendingReport'] == null
        ? null
        : IdleReport.fromJson(j['pendingReport'] as Map<String, dynamic>),
    grantedReceipts: ((j['grantedReceipts'] as List?) ?? const [])
        .cast<String>()
        .toSet(),
  );
}
