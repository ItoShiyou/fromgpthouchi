# まちの余白：夜喫茶（モック）

「まちの余白」シリーズ第 1 作『夜喫茶』のモックです（Flutter、スマホ向け）。
住宅街の端の小さな喫茶店を、アプリを閉じている間も営業させておき、
ときどき覗いて、客と小さな出来事を集めるゲームです。

| タイトル | お店（ホーム） | おかえりなさい | 特別な出来事 |
| --- | --- | --- | --- |
| ![](docs/screenshots/00_title.png) | ![](docs/screenshots/01_home.png) | ![](docs/screenshots/02_report.png) | ![](docs/screenshots/02b_event_0.png) |

| 来店客一覧 | 客詳細 | 客の出来事 | 図鑑 |
| --- | --- | --- | --- |
| ![](docs/screenshots/03_visitors.png) | ![](docs/screenshots/04_visitor_detail.png) | ![](docs/screenshots/04b_visitor_events.png) | ![](docs/screenshots/05_zukan.png) |

| 家具 | メニュー | 余白くじ | ショップ |
| --- | --- | --- | --- |
| ![](docs/screenshots/06b_furniture_selected.png) | ![](docs/screenshots/07_menu.png) | ![](docs/screenshots/08_gacha.png) | ![](docs/screenshots/09_shop.png) |

| 雨の日 | 雪の日 | 設定 |
| --- | --- | --- |
| ![](docs/screenshots/11_weather_rain.png) | ![](docs/screenshots/11_weather_snow.png) | ![](docs/screenshots/10_settings.png) |

## 動かす

```bash
flutter pub get
flutter run            # 実機・シミュレータ
flutter run -d chrome  # ブラウザで確認
flutter test           # 放置計算・天井・雰囲気などのテスト
```

待たずに試すには **設定 → 試遊用（デバッグ）** の「+8 時間」などで時間を進めてください。

## 中身

- 規模は企画書の「最初の試作品」: 客 5 人・家具 10 個・メニュー 6 個・出来事 5 つ・放置上限 12 時間
  （＋有料エピソード 1 本、くじ・セット販売のアイテム）
- 画面 10 枚：ホーム／放置結果／客一覧／客詳細／図鑑／家具／メニュー／余白くじ／ショップ／設定
  ＋ タイトル・特別な出来事・シリーズ一覧
- デザインは「夜の紺地 × クリーム色の紙パネル × 焦げ茶のボタン」。お店を基点に、下のアイコン列から各パネルを開く
- 画像素材なし。店・外観・くじ機・客の似顔絵は `CustomPainter` で描き、
  輪郭はすべて手描きの揺れた線、紙には粒と繊維を入れている（既製・自動生成っぽさを避けるため）
- 家具・メニュー・商品のアイコンは判子風の一文字（「卓」「珈」など）。絵文字は使わない
- 課金はモック（決済は発生しません）
- ローカル保存（shared_preferences）。本実装では Drift + Supabase へ移行予定

仕様の詳細は [docs/SPEC.md](docs/SPEC.md) を参照してください。

## 構成

```text
lib/core/            シリーズ共通のエンジン（放置・天気・雰囲気・出来事・くじ・セーブ）
lib/titles/yoru_kissa/  夜喫茶のコンテンツ定義と店の描画
lib/features/        10 画面
test/                エンジンのテスト
```

第 2 作（古本屋・銭湯・海辺…）は `lib/titles/` にコンテンツを追加し、
`contentProvider` を差し替えて作る想定です。
