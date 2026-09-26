/// 『まちの余白：夜喫茶』のコンテンツ（プロトタイプ規模）。
///
/// 企画書「25. 最初の試作品」の規模に合わせている:
///   客 5 人（+プレミアム 1）/ 家具 10 個 / メニュー 5 個 / 出来事 5 つ / 放置 12 時間
/// 検証後に 客 20 / 家具 40 / メニュー 15 / 出来事 30 へ拡張する。
library;

import '../../core/models/content.dart';
import '../../core/models/world.dart';

// 雰囲気タグ
const _wood = '木';
const _green = '緑';
const _warm = '暖色';
const _retro = 'レトロ';
const _red = '赤';
const _neon = 'ネオン';
const _music = '音楽';
const _book = '本';
const _soft = 'やわらか';
const _moon = '月夜';
const _rainTag = '雨';

const yoruKissa = TitleContent(
  id: 'yoru_kissa',
  brandName: 'まちの余白',
  titleName: '夜喫茶',
  placeName: '喫茶 よはく',
  seed: 20260926,
  initialMoney: 3000,
  anonymousWeight: 2.5,
  visitChancePerTick: 0.17,
  openSlots: {
    TimeSlot.morning,
    TimeSlot.noon,
    TimeSlot.evening,
    TimeSlot.night,
    TimeSlot.lateNight,
  },
  initialPlacement: {
    PlacementSlot.table: 'round_table',
    PlacementSlot.window: 'lace_curtain',
  },
  items: _items,
  ambiences: _ambiences,
  menus: _menus,
  visitors: _visitors,
  stories: _stories,
  gacha: _gacha,
  products: _products,
);

// ---------------------------------------------------------------------------
// 家具・小物
// ---------------------------------------------------------------------------

const _items = <ItemDef>[
  // はじめから（2）
  ItemDef(
    id: 'round_table',
    icon: '卓',
    name: '木の丸テーブル',
    kind: ItemKind.furniture,
    slot: PlacementSlot.table,
    tags: [_wood],
    source: ItemSource.initial,
    description: '天板の角がすこし丸くなっている。前の店主の頃からある。',
  ),
  ItemDef(
    id: 'lace_curtain',
    icon: '帳',
    name: 'レースのカーテン',
    kind: ItemKind.furniture,
    slot: PlacementSlot.window,
    tags: [_soft],
    source: ItemSource.initial,
    description: '外の光をやわらかくする。夜は街灯がにじんで見える。',
  ),
  // 売上で買える（8）
  ItemDef(
    id: 'green_sofa',
    icon: '緑',
    name: '緑色のソファ',
    kind: ItemKind.furniture,
    slot: PlacementSlot.seat,
    tags: [_green, _retro],
    price: 6000,
    description: '座ると少し沈む。昼寝をしたくなる色。',
  ),
  ItemDef(
    id: 'red_sofa',
    icon: '紅',
    name: '赤いソファ',
    kind: ItemKind.furniture,
    slot: PlacementSlot.seat,
    tags: [_red],
    price: 9000,
    description: '夜の照明の下で、いちばん映える。',
  ),
  ItemDef(
    id: 'pendulum_clock',
    icon: '時',
    name: '古い振り子時計',
    kind: ItemKind.furniture,
    slot: PlacementSlot.wall,
    tags: [_retro],
    price: 4500,
    description: '5 分だけ遅れている。誰も直そうとしない。',
  ),
  ItemDef(
    id: 'bookshelf',
    icon: '書',
    name: '壁の本棚',
    kind: ItemKind.furniture,
    slot: PlacementSlot.wall,
    tags: [_book, _wood],
    price: 8000,
    description: '客が置いていった本が、いつの間にか増えていく。',
  ),
  ItemDef(
    id: 'neon_sign',
    icon: '光',
    name: 'ネオン管の看板',
    kind: ItemKind.furniture,
    slot: PlacementSlot.wall,
    tags: [_neon],
    price: 10000,
    description: '「COFFEE」の「F」がひとつだけ点滅する。',
  ),
  ItemDef(
    id: 'stand_light',
    icon: '灯',
    name: '暖色のスタンドライト',
    kind: ItemKind.furniture,
    slot: PlacementSlot.light,
    tags: [_warm],
    price: 3500,
    description: '店の隅を、夕方の色にする。',
  ),
  ItemDef(
    id: 'monstera',
    icon: '葉',
    name: 'モンステラ',
    kind: ItemKind.furniture,
    slot: PlacementSlot.corner,
    tags: [_green],
    price: 3000,
    description: '葉の穴から、窓の光がこぼれる。',
  ),
  ItemDef(
    id: 'record_player',
    icon: '盤',
    name: 'レコードプレーヤー',
    kind: ItemKind.furniture,
    slot: PlacementSlot.corner,
    tags: [_music, _retro],
    price: 8500,
    description: '針を落とすと、店の時間が少し遅くなる。',
  ),
  // 余白くじ
  ItemDef(
    id: 'old_poster',
    icon: '映',
    name: '古い映画のポスター',
    kind: ItemKind.furniture,
    slot: PlacementSlot.wall,
    tags: [_retro],
    source: ItemSource.gacha,
    description: '誰も観たことのない映画。',
  ),
  ItemDef(
    id: 'flower_vase',
    icon: '花',
    name: '一輪挿し',
    kind: ItemKind.furniture,
    slot: PlacementSlot.counter,
    tags: [_green],
    source: ItemSource.gacha,
    description: '花は、常連さんがときどき替えてくれる。',
  ),
  ItemDef(
    id: 'goldfish_bowl',
    icon: '魚',
    name: '金魚鉢',
    kind: ItemKind.furniture,
    slot: PlacementSlot.counter,
    tags: [_soft],
    source: ItemSource.gacha,
    description: '一匹だけ。名前はまだない。',
  ),
  ItemDef(
    id: 'cat_figure',
    icon: '猫',
    name: '招き猫（小）',
    kind: ItemKind.furniture,
    slot: PlacementSlot.counter,
    tags: [_retro],
    source: ItemSource.gacha,
    description: '招いているのか、手を振っているのか。',
  ),
  ItemDef(
    id: 'moon_window',
    icon: '月',
    name: '月夜の窓',
    kind: ItemKind.furniture,
    slot: PlacementSlot.window,
    tags: [_moon],
    source: ItemSource.gacha,
    description: 'どんな夜でも、窓に月が浮かぶ。',
  ),
  ItemDef(
    id: 'bgm_rain_jazz',
    icon: '琴',
    name: 'BGM：雨音とピアノ',
    kind: ItemKind.bgm,
    source: ItemSource.gacha,
    description: '雨の日にかけたくなる、遅めのピアノ。',
  ),
  ItemDef(
    id: 'bgm_midnight_radio',
    icon: '電',
    name: 'BGM：深夜ラジオ',
    kind: ItemKind.bgm,
    source: ItemSource.gacha,
    description: '小さな音量のラジオ。ときどき誰かのお便りが読まれる。',
  ),
  ItemDef(
    id: 'fx_steam',
    icon: '湯',
    name: '演出：カップの湯気',
    kind: ItemKind.effect,
    source: ItemSource.gacha,
    description: 'テーブルのカップから、湯気が立ちのぼる。',
  ),
  // セット販売
  ItemDef(
    id: 'night_lamp',
    icon: '望',
    name: '月のランプ',
    kind: ItemKind.furniture,
    slot: PlacementSlot.light,
    tags: [_warm, _moon],
    source: ItemSource.pack,
    description: '満ち欠けする、丸いランプ。',
  ),
  ItemDef(
    id: 'umbrella_stand',
    icon: '傘',
    name: '傘立て',
    kind: ItemKind.furniture,
    slot: PlacementSlot.corner,
    tags: [_rainTag],
    source: ItemSource.pack,
    description: '忘れ物の傘が、一本だけささっている。',
  ),
  ItemDef(
    id: 'fx_window_rain',
    icon: '滴',
    name: '演出：窓の雨粒',
    kind: ItemKind.effect,
    source: ItemSource.pack,
    description: '晴れた日も、窓に雨粒が残る。',
  ),
  ItemDef(
    id: 'stained_lamp',
    icon: '彩',
    name: 'ステンドグラスのランプ',
    kind: ItemKind.furniture,
    slot: PlacementSlot.light,
    tags: [_warm, _retro],
    source: ItemSource.pack,
    description: '赤と緑の光が、天井に模様をつくる。',
  ),
  ItemDef(
    id: 'jukebox',
    icon: '曲',
    name: 'ジュークボックス',
    kind: ItemKind.furniture,
    slot: PlacementSlot.corner,
    tags: [_music, _retro, _red],
    source: ItemSource.pack,
    description: '百円玉を入れると、決まって同じ曲が流れる。',
  ),
  ItemDef(
    id: 'checkered_table',
    icon: '碁',
    name: '市松模様のテーブル',
    kind: ItemKind.furniture,
    slot: PlacementSlot.table,
    tags: [_wood, _retro],
    source: ItemSource.pack,
    description: 'チェスをする客が来るかもしれない。',
  ),
  // 出来事のあとに
  ItemDef(
    id: 'red_umbrella',
    icon: '朱',
    name: '赤い傘',
    kind: ItemKind.furniture,
    slot: PlacementSlot.corner,
    tags: [_rainTag, _red],
    source: ItemSource.story,
    description: '「お礼に」と置いていかれた傘。',
  ),
  ItemDef(
    id: 'photo_frame',
    icon: '写',
    name: '三人の写真',
    kind: ItemKind.furniture,
    slot: PlacementSlot.wall,
    tags: [_retro],
    source: ItemSource.story,
    description: '雨の日に撮られた、三人の写真。',
  ),
];

// ---------------------------------------------------------------------------
// 雰囲気
// ---------------------------------------------------------------------------

const _ambiences = <AmbienceDef>[
  AmbienceDef(
    id: 'calm',
    name: '落ち着いた店',
    description: '植物と暖かい灯り、木の手ざわり。長居したくなる。',
    requirements: [
      TagRequirement(_green),
      TagRequirement(_warm),
      TagRequirement(_wood),
    ],
  ),
  AmbienceDef(
    id: 'night',
    name: '夜の店',
    description: 'ネオンと音楽と赤。遅い時間の客が増える。',
    requirements: [
      TagRequirement(_neon),
      TagRequirement(_music),
      TagRequirement(_red),
      TagRequirement(_moon),
    ],
    requiredCount: 3,
  ),
  AmbienceDef(
    id: 'retro',
    name: '昔ながらの店',
    description: '古いものが二つ以上。時間がゆっくり流れる。',
    requirements: [TagRequirement(_retro, 2)],
  ),
  AmbienceDef(
    id: 'books',
    name: '本の匂いがする店',
    description: '本と灯り。読みかけの客が増える。',
    requirements: [TagRequirement(_book), TagRequirement(_warm)],
  ),
  AmbienceDef(
    id: 'rainy',
    name: '雨宿りの店',
    description: '傘の置き場と、やわらかい窓。雨の日の客が寄っていく。',
    requirements: [TagRequirement(_rainTag), TagRequirement(_soft)],
  ),
];

// ---------------------------------------------------------------------------
// メニュー
// ---------------------------------------------------------------------------

const _menus = <MenuDef>[
  MenuDef(
    id: 'blend',
    name: 'ブレンドコーヒー',
    icon: '珈',
    category: MenuCategory.drink,
    price: 450,
    description: '深煎り。朝いちばんの一杯だけ、少し薄めに淹れる。',
  ),
  MenuDef(
    id: 'iced_coffee',
    name: 'アイスコーヒー',
    icon: '氷',
    category: MenuCategory.drink,
    price: 500,
    description: '前の晩に仕込む。氷もコーヒーで作ってある。',
  ),
  MenuDef(
    id: 'cream_soda',
    name: 'クリームソーダ',
    icon: '泡',
    category: MenuCategory.drink,
    price: 600,
    unlockCost: 10000,
    description: 'メロンシロップ多め。さくらんぼは缶詰のもの。',
  ),
  MenuDef(
    id: 'napolitan',
    name: 'ナポリタン',
    icon: '麺',
    category: MenuCategory.food,
    price: 850,
    unlockCost: 15000,
    description: '鉄板で出す。玉ねぎは太め、ピーマンは細め。',
  ),
  MenuDef(
    id: 'pudding',
    name: '固めのプリン',
    icon: '匙',
    category: MenuCategory.sweets,
    price: 400,
    unlockCost: 6000,
    description: '固め。カラメルは焦がしすぎたくらいがいい。',
  ),
  MenuDef(
    id: 'hotcake',
    name: 'ホットケーキ',
    icon: '焼',
    category: MenuCategory.sweets,
    price: 700,
    unlockCost: 8000,
    description: '二枚重ね。焼き上がるまで十五分かかる。',
  ),
];

// ---------------------------------------------------------------------------
// 客
// ---------------------------------------------------------------------------

const _visitors = <VisitorDef>[
  VisitorDef(
    id: 'nurse',
    look: VisitorLook(
      hair: 0xFF5E4332,
      clothes: 0xFF9DB8C0,
      style: HairStyle.long,
      accent: 0xFFEDE3D0,
      face: FaceShape.long,
      eyes: EyeStyle.sleepy,
    ),
    name: '夜勤明けの女性',
    silhouetteName: '朝いちばんの人',
    slots: {TimeSlot.morning},
    favoriteMenuId: 'blend',
    ambienceBoost: {'calm': 1.6},
    profile: [
      (1, '開店と同時に来る。まだ外は少し青い。'),
      (3, '胸ポケットにペンが三本。いつも一本だけインクの色が違う。'),
      (6, '近くの病院で夜勤をしているらしい。帰ってからが、やっと夜。'),
    ],
    lines: [
      'おはようございます。……あ、私はこれから寝るんですけど。',
      'いつもの、お願いします。',
      '今日は救急が静かでした。めずらしく。',
    ],
  ),
  VisitorDef(
    id: 'window_man',
    look: VisitorLook(
      hair: 0xFF2E2A2A,
      clothes: 0xFF3A4258,
      accent: 0xFF7E3B36,
      face: FaceShape.long,
      eyes: EyeStyle.line,
      skin: 0xFFEBC9AC,
    ),
    name: '会社員の男性',
    silhouetteName: '窓際の人',
    slots: {TimeSlot.evening, TimeSlot.night},
    favoriteMenuId: 'blend',
    ambienceBoost: {'retro': 1.6, 'books': 1.4},
    fridayBoost: 1.5,
    weekendBoost: 0.6,
    profile: [
      (1, 'いつも窓際の席に座る。'),
      (3, '新聞は、いつも同じページで止まっている。'),
      (6, '仕事帰りらしい。金曜日は少しだけ長く居る。'),
    ],
    lines: ['どうも。', '窓際、空いてます？', '最近、日が短くなりましたね。'],
  ),
  VisitorDef(
    id: 'student',
    look: VisitorLook(
      hair: 0xFF2B2622,
      clothes: 0xFF3A4570,
      style: HairStyle.ponytail,
      accent: 0xFFB9483F,
      face: FaceShape.round,
      eyes: EyeStyle.round,
      blush: true,
    ),
    name: '参考書の高校生',
    silhouetteName: '制服の人',
    slots: {TimeSlot.evening, TimeSlot.night},
    favoriteMenuId: 'cream_soda',
    weatherBoost: {Weather.rain: 2.0, Weather.shower: 2.0},
    ambienceBoost: {'books': 1.5},
    weekendBoost: 0.4,
    profile: [
      (1, '参考書を開いたまま、ずっと窓の外を見ている。'),
      (3, '雨の日によく来る。傘を持っていないことが多い。'),
      (6, '志望校は、この街から遠いところらしい。'),
    ],
    lines: ['ここ、コンセントありますか。', '雨やむまで、いてもいいですか。', 'あと一問だけ解いたら帰ります。'],
  ),
  VisitorDef(
    id: 'dog_student',
    look: VisitorLook(
      hair: 0xFF9A6B3E,
      clothes: 0xFF74906A,
      style: HairStyle.bob,
      face: FaceShape.round,
      eyes: EyeStyle.dot,
    ),
    name: '犬を連れた大学生',
    silhouetteName: '犬を連れた人',
    slots: {TimeSlot.morning, TimeSlot.noon, TimeSlot.evening},
    weathers: {Weather.sunny, Weather.cloudy},
    favoriteMenuId: 'iced_coffee',
    ambienceBoost: {'calm': 1.8},
    weekendBoost: 1.5,
    profile: [
      (1, '店の前で犬を待たせて、テイクアウトを頼む。'),
      (3, '犬の名前は「むぎ」。飼い主より有名。'),
      (6, '晴れた日しか散歩に出ない。むぎが雨を嫌がるから。'),
    ],
    lines: ['むぎ、ちょっと待っててね。すぐだから。', '外、けっこう暑いですよ。', 'いつものアイスで。氷少なめで。'],
  ),
  VisitorDef(
    id: 'rain_person',
    look: VisitorLook(
      hair: 0xFF1F2430,
      clothes: 0xFF55636F,
      style: HairStyle.long,
      accent: 0xFFA7B8C0,
      face: FaceShape.oval,
      eyes: EyeStyle.line,
      skin: 0xFFEFD8C6,
    ),
    name: '雨の日だけ来る人',
    silhouetteName: '傘の人',
    slots: {TimeSlot.night, TimeSlot.lateNight},
    weathers: {Weather.rain, Weather.shower, Weather.snow},
    favoriteMenuId: 'pudding',
    ambienceBoost: {'night': 2.0, 'rainy': 2.0},
    baseWeight: 1.4,
    special: true,
    profile: [
      (1, '雨の夜にだけ現れる。'),
      (3, '晴れの日に見かけた人は、まだいない。'),
      (6, '雨音を聞きに来ている、と言っていた。'),
    ],
    lines: ['傘、ここに置いていいですか。', '閉店まで、いいですか。', '雨の日は、なんとなくここに来ちゃうんです。'],
  ),
  // プレミアムエピソード「雨の日の三人」で登場
  VisitorDef(
    id: 'photographer',
    look: VisitorLook(
      hair: 0xFFC4BEB4,
      clothes: 0xFF7A5C45,
      style: HairStyle.gray,
      glasses: true,
      face: FaceShape.long,
      eyes: EyeStyle.sleepy,
      skin: 0xFFE8C4A6,
    ),
    name: '古いカメラの老人',
    silhouetteName: 'カメラの人',
    slots: {TimeSlot.noon, TimeSlot.evening},
    weathers: {Weather.rain, Weather.cloudy},
    favoriteMenuId: 'napolitan',
    premiumEpisodeId: 'rain_three',
    special: true,
    profile: [
      (1, 'フィルムのカメラを首から下げている。'),
      (3, '一日に一枚しか撮らない、と決めているらしい。'),
      (6, '昔、この店の写真を撮ったことがあるという。'),
    ],
    lines: ['一枚だけ、撮ってもいいですか。', 'ガラスが濡れてると、よく写るんです。', '昔、この辺にも似た店がありましてね。'],
  ),
];

// ---------------------------------------------------------------------------
// 出来事
// ---------------------------------------------------------------------------

const _nightSlots = {TimeSlot.night, TimeSlot.lateNight};
const _wet = {Weather.rain, Weather.shower, Weather.snow};

const _stories = <StoryChainDef>[
  StoryChainDef(
    id: 'red_umbrella',
    title: '赤い傘',
    relatedVisitorIds: ['rain_person'],
    rewardTickets: 1,
    rewardItemId: 'red_umbrella',
    steps: [
      StoryStep(
        text: '雨の夜、傘を持たずに駆け込んできた人がいた。帰りぎわ、店の傘を貸した。',
        hint: '雨の夜に、誰かが駆け込んでくるかもしれない。',
        condition: StoryCondition(visitorId: 'rain_person', chancePerTick: 0.6),
      ),
      StoryStep(
        text: '店先に、見覚えのない赤い傘が立てかけてある。店の傘は、まだ返ってきていない。',
        hint: '次の日、店先を見てみよう。',
        condition: StoryCondition(
          slots: {TimeSlot.morning, TimeSlot.noon},
          minDaysSincePrevious: 1,
          chancePerTick: 0.05,
        ),
      ),
      StoryStep(
        text: 'よく晴れた夕方、店の傘を返しに来た人がいた。赤い傘は「お礼に」と置いていった。',
        hint: '晴れた日に、何かが返ってくるかもしれない。',
        condition: StoryCondition(
          weathers: {Weather.sunny},
          slots: {TimeSlot.evening, TimeSlot.night},
          minDaysSincePrevious: 2,
          chancePerTick: 0.05,
        ),
      ),
    ],
  ),
  StoryChainDef(
    id: 'window_two',
    title: '窓際の二人',
    relatedVisitorIds: ['window_man'],
    rewardTickets: 2,
    steps: [
      StoryStep(
        text: 'いつも窓際の席。新聞を広げて、ブレンドを一杯。',
        condition: StoryCondition(visitorId: 'window_man', chancePerTick: 0.5),
      ),
      StoryStep(
        text: '今日は新聞ではなく、文庫本を読んでいた。',
        condition: StoryCondition(
          visitorId: 'window_man',
          minDaysSincePrevious: 2,
          chancePerTick: 0.5,
        ),
      ),
      StoryStep(
        text: '隣の席に、誰かが座った。二人とも、何も話さなかった。',
        hint: '本の匂いがする店なら、誰かが隣に座るかもしれない。',
        condition: StoryCondition(
          visitorId: 'window_man',
          ambience: 'books',
          minDaysSincePrevious: 3,
          chancePerTick: 0.6,
        ),
      ),
      StoryStep(
        text: '二人が、同じ時間に来た。',
        condition: StoryCondition(
          visitorId: 'window_man',
          minDaysSincePrevious: 4,
          chancePerTick: 0.5,
        ),
      ),
      StoryStep(
        text: '今日は、片方だけ。ずっと窓の外を見ていた。',
        condition: StoryCondition(
          visitorId: 'window_man',
          minDaysSincePrevious: 3,
          chancePerTick: 0.5,
        ),
      ),
      StoryStep(
        text: '二人が、また一緒に来た。窓の外は、よく晴れていた。',
        hint: '晴れた日を待とう。',
        condition: StoryCondition(
          visitorId: 'window_man',
          weathers: {Weather.sunny},
          minDaysSincePrevious: 5,
          chancePerTick: 0.6,
        ),
      ),
    ],
  ),
  StoryChainDef(
    id: 'night_shift',
    title: '夜勤明け',
    relatedVisitorIds: ['nurse'],
    rewardTickets: 1,
    steps: [
      StoryStep(
        text: '夜勤明けの人が、ブレンドを一杯だけ飲んで帰っていった。',
        condition: StoryCondition(visitorId: 'nurse', chancePerTick: 0.5),
      ),
      StoryStep(
        text: '今日は二杯目を頼んだ。「今日は、休みなんです」',
        hint: '曇りや雨の朝は、少しゆっくりしていくかもしれない。',
        condition: StoryCondition(
          visitorId: 'nurse',
          weathers: {Weather.cloudy, ..._wet},
          minDaysSincePrevious: 2,
          chancePerTick: 0.5,
        ),
      ),
      StoryStep(
        text: 'カウンターで、少しだけ眠っていた。起こさないでおいた。',
        hint: '落ち着いた店なら、もう少し長く居てくれるかもしれない。',
        condition: StoryCondition(
          visitorId: 'nurse',
          ambience: 'calm',
          minDaysSincePrevious: 2,
          chancePerTick: 0.6,
        ),
      ),
    ],
  ),
  StoryChainDef(
    id: 'sticky_notes',
    title: '付箋の色',
    relatedVisitorIds: ['student'],
    rewardTickets: 1,
    steps: [
      StoryStep(
        text: '参考書に、付箋がびっしり貼ってある。',
        condition: StoryCondition(visitorId: 'student', chancePerTick: 0.5),
      ),
      StoryStep(
        text: '付箋の色が、ぜんぶ変わっていた。',
        condition: StoryCondition(
          visitorId: 'student',
          minDaysSincePrevious: 3,
          chancePerTick: 0.5,
        ),
      ),
      StoryStep(
        text: '今日は参考書を持っていない。クリームソーダを二つ頼んで、誰かを待っていた。',
        hint: 'クリームソーダがあれば……。',
        condition: StoryCondition(
          visitorId: 'student',
          menuId: 'cream_soda',
          minDaysSincePrevious: 4,
          chancePerTick: 0.6,
        ),
      ),
    ],
  ),
  StoryChainDef(
    id: 'midnight_request',
    title: '深夜のリクエスト',
    rewardTickets: 1,
    steps: [
      StoryStep(
        text: '閉店まぎわ、知らない曲をリクエストされた。そのレコードは、店になかった。',
        hint: '「夜の店」の深夜に、何かが起きるかもしれない。',
        condition: StoryCondition(
          slots: {TimeSlot.lateNight},
          ambience: 'night',
          chancePerTick: 0.05,
        ),
      ),
      StoryStep(
        text: '商店街のどこかから、あの曲が聞こえた。',
        condition: StoryCondition(
          slots: {TimeSlot.evening, ..._nightSlots},
          minDaysSincePrevious: 2,
          chancePerTick: 0.04,
        ),
      ),
    ],
  ),
  // プレミアムエピソード
  StoryChainDef(
    id: 'rain_three',
    title: '雨の日の三人',
    premiumEpisodeId: 'rain_three',
    relatedVisitorIds: ['photographer', 'rain_person', 'student'],
    rewardTickets: 2,
    rewardItemId: 'photo_frame',
    steps: [
      StoryStep(
        text: '古いカメラを持った人が、雨の窓を一枚だけ撮っていった。',
        condition: StoryCondition(
          visitorId: 'photographer',
          weathers: _wet,
          chancePerTick: 0.6,
        ),
      ),
      StoryStep(
        text: '雨宿りの三人が、同じテーブルに座った。誰も知り合いではなかった。',
        condition: StoryCondition(
          weathers: _wet,
          slots: {TimeSlot.evening, ..._nightSlots},
          minDaysSincePrevious: 1,
          chancePerTick: 0.05,
        ),
      ),
      StoryStep(
        text: '現像した写真を見せてくれた。三人とも、笑っていた。',
        condition: StoryCondition(
          visitorId: 'photographer',
          minDaysSincePrevious: 2,
          chancePerTick: 0.6,
        ),
      ),
      StoryStep(
        text: '晴れた日、店に一枚の絵はがきが届いた。差出人の名前はなかった。',
        condition: StoryCondition(
          weathers: {Weather.sunny},
          minDaysSincePrevious: 3,
          chancePerTick: 0.04,
        ),
      ),
      StoryStep(
        text: '雨の夜、また三人が揃った。今度は、名前を呼び合っていた。',
        condition: StoryCondition(
          weathers: _wet,
          slots: _nightSlots,
          minDaysSincePrevious: 2,
          chancePerTick: 0.05,
        ),
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// 余白くじ・ショップ
// ---------------------------------------------------------------------------

const _gacha = GachaDef(
  name: '余白くじ',
  rarityRates: {Rarity.common: 0.70, Rarity.rare: 0.25, Rarity.superRare: 0.05},
  entries: [
    GachaEntry('old_poster', Rarity.common),
    GachaEntry('flower_vase', Rarity.common),
    GachaEntry('goldfish_bowl', Rarity.common),
    GachaEntry('cat_figure', Rarity.common),
    GachaEntry('bgm_rain_jazz', Rarity.rare),
    GachaEntry('bgm_midnight_radio', Rarity.rare),
    GachaEntry('fx_steam', Rarity.rare),
    GachaEntry('moon_window', Rarity.superRare),
  ],
);

const _products = <ProductDef>[
  ProductDef(
    id: 'ad_free',
    icon: '静',
    recommended: true,
    name: '広告なし',
    type: ProductType.adFree,
    priceYen: 680,
    description: '店の下の広告が出なくなります。買い切り。',
  ),
  ProductDef(
    id: 'pack_moon',
    icon: '月',
    recommended: true,
    name: '月夜の窓セット',
    type: ProductType.pack,
    priceYen: 220,
    itemIds: ['moon_window', 'night_lamp'],
    description: 'くじの「とくべつ」の窓と、月のランプ。',
  ),
  ProductDef(
    id: 'pack_rain',
    icon: '雨',
    recommended: true,
    name: '雨の日セット',
    type: ProductType.pack,
    priceYen: 320,
    itemIds: ['umbrella_stand', 'fx_window_rain', 'bgm_rain_jazz'],
    description: '傘立て、窓の雨粒、雨の日の BGM。',
  ),
  ProductDef(
    id: 'pack_retro',
    icon: '昔',
    recommended: true,
    name: 'レトロ喫茶セット',
    type: ProductType.pack,
    priceYen: 680,
    itemIds: ['stained_lamp', 'jukebox', 'checkered_table'],
    description: 'ステンドグラスのランプ、ジュークボックス、市松のテーブル。',
  ),
  ProductDef(
    id: 'ep_rain_three',
    icon: '写',
    name: 'エピソード「雨の日の三人」',
    type: ProductType.episode,
    priceYen: 320,
    episodeId: 'rain_three',
    description: 'カメラを持った人が来るようになります。出来事 5 つ。',
  ),
  ProductDef(
    id: 'tickets_5',
    icon: '札',
    name: '余白くじチケット ×5',
    type: ProductType.tickets,
    priceYen: 160,
    tickets: 5,
    consumable: true,
    description: '余白くじを 5 回引けます。',
  ),
  ProductDef(
    id: 'tickets_11',
    icon: '札',
    recommended: true,
    name: '余白くじチケット ×11',
    type: ProductType.tickets,
    priceYen: 320,
    tickets: 11,
    consumable: true,
    description: '余白くじを 11 回引けます。',
  ),
];
