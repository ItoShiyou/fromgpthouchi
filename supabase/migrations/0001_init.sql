-- まちの余白：サーバー側（Supabase）
--
-- 方針：ゲームの正本は端末（SQLite）。サーバーは
--   1. バックアップと機種変更（cloud_save / transfer_codes）
--   2. 課金の記録と検証（purchase_records）
--   3. あとから配るコンテンツ（*_master）
-- だけを持つ。リアルタイムのサーバー処理は無い（放置計算は端末で完結する）。
--
-- 認証は匿名サインイン（auth.signInAnonymously）。アカウント連携は後で足せる。

-- ---------------------------------------------------------------------------
-- 1. バックアップ
-- ---------------------------------------------------------------------------
create table public.cloud_save (
  user_id      uuid        not null default auth.uid() references auth.users on delete cascade,
  title_id     text        not null,
  data         jsonb       not null,        -- GameState.toJson()
  save_version int         not null default 1,
  updated_at   timestamptz not null default now(),
  primary key (user_id, title_id)
);

alter table public.cloud_save enable row level security;

create policy "自分のセーブだけ読める"   on public.cloud_save for select using (auth.uid() = user_id);
create policy "自分のセーブだけ書ける"   on public.cloud_save for insert with check (auth.uid() = user_id);
create policy "自分のセーブだけ更新できる" on public.cloud_save for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 機種変更：引き継ぎコード
-- 旧端末でコードを発行 → 新端末（別の匿名ユーザー）で入力すると、セーブが写される。
-- 表は直接触らせず、下の 2 つの関数からだけ使う。
-- ---------------------------------------------------------------------------
create table public.transfer_codes (
  code       text        primary key,
  user_id    uuid        not null references auth.users on delete cascade,
  title_id   text        not null,
  expires_at timestamptz not null
);

alter table public.transfer_codes enable row level security;
-- ポリシーを作らない＝クライアントからは読めない・書けない

create or replace function public.create_transfer_code(p_title text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  -- 読み間違えやすい文字（0/O, 1/I/L）は使わない
  alphabet constant text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  v_code text := '';
begin
  if auth.uid() is null then
    raise exception 'not signed in';
  end if;
  if not exists (select 1 from cloud_save where user_id = auth.uid() and title_id = p_title) then
    raise exception 'no backup';
  end if;
  delete from transfer_codes where user_id = auth.uid() and title_id = p_title;
  for i in 1..12 loop
    v_code := v_code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
  end loop;
  insert into transfer_codes(code, user_id, title_id, expires_at)
  values (v_code, auth.uid(), p_title, now() + interval '24 hours');
  return v_code;
end;
$$;

create or replace function public.claim_transfer_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  t transfer_codes%rowtype;
  v_data jsonb;
begin
  if auth.uid() is null then
    raise exception 'not signed in';
  end if;
  select * into t from transfer_codes where code = upper(replace(p_code, '-', '')) and expires_at > now();
  if not found then
    raise exception 'invalid code';
  end if;
  select data into v_data from cloud_save where user_id = t.user_id and title_id = t.title_id;
  insert into cloud_save(user_id, title_id, data, updated_at)
  values (auth.uid(), t.title_id, v_data, now())
  on conflict (user_id, title_id) do update set data = excluded.data, updated_at = now();
  -- コードは一度きり
  delete from transfer_codes where code = t.code;
  return v_data;
end;
$$;

revoke all on function public.create_transfer_code(text) from public;
revoke all on function public.claim_transfer_code(text) from public;
grant execute on function public.create_transfer_code(text) to authenticated;
grant execute on function public.claim_transfer_code(text) to authenticated;

-- ---------------------------------------------------------------------------
-- 2. 課金の記録（書き込みは Edge Function verify-receipt からだけ）
-- ---------------------------------------------------------------------------
create table public.purchase_records (
  id             bigint generated always as identity primary key,
  user_id        uuid        not null references auth.users on delete cascade,
  title_id       text        not null,
  product_id     text        not null,
  transaction_id text        not null unique,
  platform       text        not null check (platform in ('ios', 'android')),
  verified       boolean     not null default false,
  created_at     timestamptz not null default now()
);

alter table public.purchase_records enable row level security;
create policy "自分の購入記録だけ読める" on public.purchase_records for select using (auth.uid() = user_id);
-- insert / update のポリシーは作らない（service role の Edge Function だけが書く）

-- ---------------------------------------------------------------------------
-- 3. あとから配るコンテンツ（出来事・家具・くじの追加）
-- ---------------------------------------------------------------------------
create table public.event_master (
  id           text        not null,
  title_id     text        not null,
  data         jsonb       not null,
  published_at timestamptz not null default now(),
  primary key (title_id, id)
);
create table public.item_master (like public.event_master including all);
create table public.gacha_master (like public.event_master including all);

alter table public.event_master enable row level security;
alter table public.item_master  enable row level security;
alter table public.gacha_master enable row level security;
create policy "公開済みは誰でも読める" on public.event_master for select using (published_at <= now());
create policy "公開済みは誰でも読める" on public.item_master  for select using (published_at <= now());
create policy "公開済みは誰でも読める" on public.gacha_master for select using (published_at <= now());
