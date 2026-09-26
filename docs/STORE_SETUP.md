# 公開の準備（課金・広告・通知・ビルド）

## ビルドの切り替え

何も渡さずにビルドすると「試作版」になります（決済・広告はテスト用、クラウド無し）。

| 渡すもの | 意味 |
| --- | --- |
| `--dart-define=REAL_STORE=true` | App Store / Google Play の本物の課金を使う |
| `--dart-define=ADMOB_BANNER_ANDROID=...` | Android の広告ユニット ID（無ければ Google のテスト用） |
| `--dart-define=ADMOB_BANNER_IOS=...` | iOS の広告ユニット ID（無ければ Google のテスト用） |
| `--dart-define=SUPABASE_URL=...` / `SUPABASE_KEY=...` | クラウドのバックアップ・機種変更を有効にする（`supabase/README.md`） |
| `--dart-define=VERIFY_RECEIPTS=true` | レシートをサーバーで検証する（サーバー側の実装後に） |

例：

```bash
flutter build appbundle --release \
  --dart-define=REAL_STORE=true \
  --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-xxxx/yyyy \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_KEY=sb_publishable_xxxx
```

## 課金（App Store Connect / Google Play Console）

**商品 ID はアプリ内の ID と同じにします。**

| 商品 ID | 種類 | 価格 | 中身 |
| --- | --- | --- | --- |
| `ad_free` | 非消耗型 | ¥680 | 広告なし |
| `pack_moon` | 非消耗型 | ¥220 | 月夜の窓・月のランプ |
| `pack_rain` | 非消耗型 | ¥320 | 傘立て・窓の雨粒・BGM 雨音とピアノ |
| `pack_retro` | 非消耗型 | ¥680 | ステンドグラスのランプ・ジュークボックス・市松のテーブル |
| `ep_rain_three` | 非消耗型 | ¥320 | エピソード「雨の日の三人」 |
| `tickets_5` | 消耗型 | ¥160 | 余白くじチケット ×5 |
| `tickets_11` | 消耗型 | ¥320 | 余白くじチケット ×11 |

- 画面の価格表示はストアから取った地域の価格を使います（取れない時だけ上の円表示）
- 「購入を復元」はショップの一番下にあります（App Store の審査で必要）
- 余白くじの**提供割合はくじ画面の「提供割合」で常に見られます**（Apple・Google のルール）
- 「A+B+C を揃えたら報酬」のようなコンプリート要素はありません

## 広告（AdMob）

- 出すのは**お店の画面下のバナー 1 枚だけ**。「広告なし」を買うと出ません
- 同意（EU など）は Google の UMP で取り、必要な地域では設定画面に「広告の同意設定」が出ます
- 公開前に差し替えるもの：
  - `android/app/src/main/AndroidManifest.xml` の `com.google.android.gms.ads.APPLICATION_ID`
  - `ios/Runner/Info.plist` の `GADApplicationIdentifier`（今はどちらもテスト用 ID）
  - 必要なら `SKAdNetworkItems` を AdMob の最新の一覧に更新

## 通知

- 送るのは「出来事が起きる時」の 1 件だけ（ログインを促す通知・定時通知は無し）
- 時刻は放置計算で予測し、アプリが裏に回る時に予約、戻ったら取り消します
- 許可は、初めて出来事を見た直後（か、設定で通知をオンにした時）に聞きます
- Android：正確なアラームの権限は使いません（数分ずれてもよい）

## まだ手元で確かめていないこと

この環境には Android SDK / Xcode が無いため、**端末向けのビルドと実機での動作はまだ確認していません**。
Web 版と単体テストでは確認済みです。最初に実機で見ておきたいのは：

1. `flutter build apk` / `flutter build ios` が通るか（desugaring、各プラグインの設定）
2. 通知が予約した時刻に届くか（端末を再起動しても残るか）
3. テスト用 ID で広告が出るか、同意フォームの動き
4. サンドボックス／テスト購入で、購入・復元・消耗型の二重付与防止
