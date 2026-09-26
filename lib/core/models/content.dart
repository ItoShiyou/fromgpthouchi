/// タイトルごとのコンテンツ定義（マスタデータ）の型。
///
/// 共通エンジンはこれらの型だけを知っていて、
/// 「夜喫茶」「古本屋」などの中身は titles/ 以下で差し替える。
library;

import 'world.dart';

// ---------------------------------------------------------------------------
// アイテム（家具・小物・BGM・演出）
// ---------------------------------------------------------------------------

enum ItemKind {
  furniture('家具'),
  bgm('BGM'),
  effect('演出');

  const ItemKind(this.label);
  final String label;
}

/// 家具を置ける場所。背景に対するレイヤー位置と対応する。
enum PlacementSlot {
  window('窓'),
  wall('壁'),
  light('照明'),
  seat('ソファ席'),
  table('テーブル'),
  corner('店の隅'),
  counter('カウンターの上');

  const PlacementSlot(this.label);
  final String label;
}

enum ItemSource {
  initial('はじめから'),
  coin('売上で購入'),
  gacha('余白くじ'),
  pack('セット販売'),
  story('出来事のあとに');

  const ItemSource(this.label);
  final String label;
}

class ItemDef {
  const ItemDef({
    required this.id,
    required this.name,
    required this.kind,
    required this.description,
    this.slot,
    this.tags = const [],
    this.price,
    this.source = ItemSource.coin,
    this.icon = '物',
  });

  final String id;
  final String name;
  final ItemKind kind;

  /// 図鑑・家具一覧の「しるし」（一文字）。
  final String icon;
  final PlacementSlot? slot;

  /// 雰囲気タグの材料。家具に「性能」は持たせず、タグだけ持たせる。
  final List<String> tags;

  /// 売上（ゲーム内通貨）での価格。null なら売上では買えない。
  final int? price;
  final ItemSource source;
  final String description;
}

// ---------------------------------------------------------------------------
// 雰囲気（家具の組み合わせから生まれるタグ）
// ---------------------------------------------------------------------------

class TagRequirement {
  const TagRequirement(this.tag, [this.count = 1]);
  final String tag;
  final int count;
}

class AmbienceDef {
  const AmbienceDef({
    required this.id,
    required this.name,
    required this.description,
    required this.requirements,
    this.requiredCount,
  });

  final String id;
  final String name;
  final String description;
  final List<TagRequirement> requirements;

  /// requirements のうち何個満たせば成立するか。null ならすべて。
  final int? requiredCount;

  int get minSatisfied => requiredCount ?? requirements.length;
}

// ---------------------------------------------------------------------------
// メニュー
// ---------------------------------------------------------------------------

enum MenuCategory {
  drink('ドリンク'),
  food('フード'),
  sweets('スイーツ');

  const MenuCategory(this.label);
  final String label;
}

class MenuDef {
  const MenuDef({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.icon,
    this.unlockCost = 0,
  });

  final String id;
  final String name;

  /// 1 杯（1 皿）の売上。
  final int price;

  /// レシピを覚えるコスト。0 なら最初から出せる。
  final int unlockCost;
  final String description;
  final MenuCategory category;
  final String icon;
}

// ---------------------------------------------------------------------------
// 客
// ---------------------------------------------------------------------------

enum HairStyle { short, long, bob, bun, ponytail, gray, cap }

enum FaceShape { round, oval, long }

enum EyeStyle { dot, line, sleepy, round }

/// 似顔絵の見た目。コードで描く（本番でイラストに差し替えても構造はそのまま）。
class VisitorLook {
  const VisitorLook({
    required this.hair,
    required this.clothes,
    this.style = HairStyle.short,
    this.skin = 0xFFF4D6BE,
    this.accent,
    this.glasses = false,
    this.face = FaceShape.oval,
    this.eyes = EyeStyle.dot,
    this.blush = false,
  });

  final FaceShape face;
  final EyeStyle eyes;

  /// 頬の斜線（照れ・寒さ）。全員につけると記号的になるので一部だけ。
  final bool blush;

  final int hair;
  final int clothes;
  final HairStyle style;
  final int skin;

  /// ネクタイ・スカーフなどの差し色。
  final int? accent;
  final bool glasses;
}

class VisitorDef {
  const VisitorDef({
    required this.look,
    required this.id,
    required this.name,
    required this.silhouetteName,
    required this.profile,
    required this.lines,
    required this.slots,
    this.favoriteMenuId,
    this.weathers,
    this.baseWeight = 1.0,
    this.weatherBoost = const {},
    this.ambienceBoost = const {},
    this.weekdayBoost = 1.0,
    this.fridayBoost = 1.0,
    this.weekendBoost = 1.0,
    this.requiredAmbience,
    this.premiumEpisodeId,
    this.special = false,
  });

  final VisitorLook look;

  /// 天気や条件が揃わないと来ない「特別」な客。
  final bool special;

  final String id;

  /// 図鑑で正式に表示される名前（何度か来るとわかる）。
  final String name;

  /// 初見時の呼び名。「窓際の人」など。
  final String silhouetteName;

  /// 来店回数に応じて開放されるプロフィール（[来店回数, 文章]）。
  final List<(int, String)> profile;

  /// 客をタップした時のひとこと。
  final List<String> lines;

  /// 来店する時間帯。
  final Set<TimeSlot> slots;

  /// 来店する天気。null ならどの天気でも来る。
  final Set<Weather>? weathers;

  final String? favoriteMenuId;
  final double baseWeight;
  final Map<Weather, double> weatherBoost;
  final Map<String, double> ambienceBoost;
  final double weekdayBoost;
  final double fridayBoost;
  final double weekendBoost;

  /// この雰囲気が無いと来ない（特殊客用）。
  final String? requiredAmbience;

  /// プレミアムエピソード購入で初めて登場する客。
  final String? premiumEpisodeId;
}

// ---------------------------------------------------------------------------
// 出来事（時間を跨いで進む小さな物語）
// ---------------------------------------------------------------------------

class StoryCondition {
  const StoryCondition({
    this.slots,
    this.weathers,
    this.ambience,
    this.visitorId,
    this.menuId,
    this.minDaysSincePrevious = 0,
    this.chancePerTick = 0.04,
  });

  final Set<TimeSlot>? slots;
  final Set<Weather>? weathers;
  final String? ambience;

  /// この客がその tick に来店した時だけ発生する。
  final String? visitorId;

  /// このメニューを出せる時だけ発生する。
  final String? menuId;

  /// 前の段階から何営業日空けるか。
  final int minDaysSincePrevious;

  /// 条件を満たした tick ごとの発生確率。
  /// visitorId 指定時は「その客が来た時に」この確率で発生。
  final double chancePerTick;
}

class StoryStep {
  const StoryStep({required this.text, required this.condition, this.hint});

  /// 図鑑に記録される一文。説明しすぎない。
  final String text;
  final StoryCondition condition;

  /// 図鑑で未発見の時に出すヒント。
  final String? hint;
}

class StoryChainDef {
  const StoryChainDef({
    required this.id,
    required this.title,
    required this.steps,
    this.relatedVisitorIds = const [],
    this.rewardTickets = 0,
    this.rewardItemId,
    this.premiumEpisodeId,
  });

  final String id;
  final String title;
  final List<StoryStep> steps;
  final List<String> relatedVisitorIds;

  /// 最後まで見届けた時にもらえる余白くじチケット。
  final int rewardTickets;

  /// 最後まで見届けた時に店に残るもの（例：赤い傘）。
  final String? rewardItemId;
  final String? premiumEpisodeId;
}

// ---------------------------------------------------------------------------
// 課金まわり（ガチャ・セット・エピソード）
// ---------------------------------------------------------------------------

enum Rarity {
  common('ふつう'),
  rare('めずらしい'),
  superRare('とくべつ');

  const Rarity(this.label);
  final String label;
}

class GachaEntry {
  const GachaEntry(this.itemId, this.rarity);
  final String itemId;
  final Rarity rarity;
}

class GachaDef {
  const GachaDef({
    required this.name,
    required this.entries,
    required this.rarityRates,
    this.pityCount = 10,
    this.duplicateRefund = 500,
  });

  final String name;
  final List<GachaEntry> entries;

  /// レアリティごとの排出率（合計 1.0）。画面に必ず表示する。
  final Map<Rarity, double> rarityRates;

  /// この回数引く間に未所持が出なければ、次は必ず未所持。
  final int pityCount;

  /// 所持済みが出た時に売上へ還元する額。
  final int duplicateRefund;

  /// アイテム単位の排出率。レアリティ内は均等。
  double rateOf(GachaEntry e) {
    final sameRarity = entries.where((x) => x.rarity == e.rarity).length;
    return (rarityRates[e.rarity] ?? 0) / sameRarity;
  }
}

enum ProductType {
  adFree('広告削除'),
  pack('セット'),
  episode('プレミアムエピソード'),
  tickets('余白くじチケット');

  const ProductType(this.label);
  final String label;
}

class ProductDef {
  const ProductDef({
    required this.id,
    required this.name,
    required this.type,
    required this.priceYen,
    required this.description,
    this.itemIds = const [],
    this.tickets = 0,
    this.episodeId,
    this.consumable = false,
    this.icon = '品',
    this.recommended = false,
  });

  final String icon;

  /// ショップの「おすすめ」に出すか。
  final bool recommended;

  final String id;
  final String name;
  final ProductType type;
  final int priceYen;
  final String description;
  final List<String> itemIds;
  final int tickets;
  final String? episodeId;
  final bool consumable;
}

// ---------------------------------------------------------------------------
// タイトル
// ---------------------------------------------------------------------------

/// 1 タイトル分のコンテンツ。第 2 作以降はこれを差し替えるだけで
/// 放置・図鑑・家具・出来事・課金のエンジンを使い回せる。
class TitleContent {
  const TitleContent({
    required this.id,
    required this.brandName,
    required this.titleName,
    required this.placeName,
    required this.seed,
    required this.items,
    required this.ambiences,
    required this.menus,
    required this.visitors,
    required this.stories,
    required this.gacha,
    required this.products,
    required this.openSlots,
    required this.initialMoney,
    required this.initialPlacement,
    required this.anonymousWeight,
    required this.visitChancePerTick,
    this.maxIdle = const Duration(hours: 12),
    this.tick = const Duration(minutes: 5),
  });

  final String id;
  final String brandName;
  final String titleName;
  final String placeName;
  final int seed;
  final List<ItemDef> items;
  final List<AmbienceDef> ambiences;
  final List<MenuDef> menus;
  final List<VisitorDef> visitors;
  final List<StoryChainDef> stories;
  final GachaDef gacha;
  final List<ProductDef> products;

  /// 営業している時間帯。
  final Set<TimeSlot> openSlots;
  final int initialMoney;
  final Map<PlacementSlot, String> initialPlacement;

  /// 図鑑に載らない「通りすがりの客」の重み。売上の土台。
  final double anonymousWeight;

  /// 1 tick あたりの来店確率。
  final double visitChancePerTick;
  final Duration maxIdle;
  final Duration tick;

  ItemDef item(String id) => items.firstWhere((e) => e.id == id);
  MenuDef menu(String id) => menus.firstWhere((e) => e.id == id);
  VisitorDef visitor(String id) => visitors.firstWhere((e) => e.id == id);
  StoryChainDef story(String id) => stories.firstWhere((e) => e.id == id);
  AmbienceDef ambience(String id) => ambiences.firstWhere((e) => e.id == id);
  ProductDef product(String id) => products.firstWhere((e) => e.id == id);
}
