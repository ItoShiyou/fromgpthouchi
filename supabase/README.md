# サーバー（Supabase）

ゲームの正本は端末の SQLite です。サーバーが持つのは次の 3 つだけ。

| 用途 | 表・関数 |
| --- | --- |
| バックアップ・機種変更 | `cloud_save`, `transfer_codes`, `create_transfer_code()`, `claim_transfer_code()` |
| 課金の記録と検証 | `purchase_records`, Edge Function `verify-receipt` |
| あとから配るコンテンツ | `event_master`, `item_master`, `gacha_master` |

放置計算は端末で完結するので、常時動くサーバー処理はありません。

## 用意するもの

1. Supabase のプロジェクトを作る
2. **Authentication → Sign In / Providers → Anonymous sign-ins を有効にする**（端末ごとの匿名ユーザーで使う）
3. 表を作る

   ```bash
   supabase link --project-ref <ref>
   supabase db push            # migrations/0001_init.sql
   ```

4. アプリをビルドする時に URL と publishable key を渡す

   ```bash
   flutter run --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
               --dart-define=SUPABASE_KEY=<publishable key>
   ```

   渡さなければクラウド機能は無効のまま（設定画面にも出ません）。

## 機種変更の流れ

1. 前の端末：設定 →「引き継ぎコードを出す」（その時点のセーブを預けてから、24 時間・一度きりのコードを出す）
2. 新しい端末：設定 →「引き継ぎコードを入れる」
3. サーバーが前のユーザーのセーブを新しいユーザーに写し、コードを消す

コードの表はクライアントから読めません（関数の中でだけ使う）。

## レシート検証（未完成）

`functions/verify-receipt/index.ts` の `verifyWithStore` は、ストアへの問い合わせが未実装で、今は常に false を返します。
実装したら：

```bash
supabase functions deploy verify-receipt
supabase secrets set APPLE_... GOOGLE_...     # ストア API の認証情報
flutter run ... --dart-define=VERIFY_RECEIPTS=true
```

`VERIFY_RECEIPTS` を付けない間は、端末はストアが「購入済み」と言ったものを信じて付与します
（同じ取引の二重付与は端末側で防いでいます）。

## 手元での確認

Supabase の auth スキーマの代役（`tests/00_auth_stub.sql`）を使えば、素の PostgreSQL でも確かめられます。

```bash
createdb yohaku
psql -d yohaku -f tests/00_auth_stub.sql
psql -d yohaku -f migrations/0001_init.sql
psql -d yohaku -f tests/10_transfer_and_rls.sql
```

`10_transfer_and_rls.sql` で確かめていること：

- 引き継ぎコードで、別のユーザーにセーブが写る
- コードは一度きり、間違ったコードは弾かれる
- 他人のセーブは読めない・書き換えられない
- コードの表・購入記録はクライアントから書けない
- 公開前のコンテンツは見えない
- 未ログインではコードを出せない
