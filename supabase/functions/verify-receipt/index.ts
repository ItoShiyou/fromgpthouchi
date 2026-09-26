// レシート検証（Supabase Edge Function / Deno）
//
// 端末の ReceiptVerifier から呼ぶ。検証できたら purchase_records に記録して ok: true を返す。
// 同じ transaction_id は一度しか記録しない（二重付与の防止はサーバー側でも行う）。
//
// 未実装：ストアへの問い合わせ（下の verifyWithStore）。
//   iOS     : App Store Server API（Transaction ID で取引を取得し、署名を検証）
//   Android : Google Play Developer API purchases.products.get（サービスアカウント）
// 秘密情報は `supabase secrets set` で入れ、コードには書かない。

import { createClient } from "npm:@supabase/supabase-js@2";

type Body = {
  title_id: string;
  product_id: string;
  transaction_id: string;
  platform: "ios" | "android";
  verification_data: string;
};

async function verifyWithStore(_b: Body): Promise<boolean> {
  // TODO: ストアの API で確認する。確認できるまでは false（＝付与しない）にしておく。
  return false;
}

Deno.serve(async (req) => {
  const auth = req.headers.get("Authorization");
  if (!auth) return new Response("unauthorized", { status: 401 });

  // 呼び出した人（匿名ユーザー）を特定する
  const userClient = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: auth } },
  });
  const { data: user } = await userClient.auth.getUser();
  if (!user.user) return new Response("unauthorized", { status: 401 });

  const body = (await req.json()) as Body;
  const ok = await verifyWithStore(body);
  if (!ok) return Response.json({ ok: false });

  // 記録は service role で（クライアントからは書けない表）
  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
  const { error } = await admin.from("purchase_records").upsert(
    {
      user_id: user.user.id,
      title_id: body.title_id,
      product_id: body.product_id,
      transaction_id: body.transaction_id,
      platform: body.platform,
      verified: true,
    },
    { onConflict: "transaction_id", ignoreDuplicates: true },
  );
  if (error) return Response.json({ ok: false, error: error.message }, { status: 500 });
  return Response.json({ ok: true });
});
