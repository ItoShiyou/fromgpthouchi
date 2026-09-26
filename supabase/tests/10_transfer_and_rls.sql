\set ON_ERROR_STOP 0
insert into auth.users values ('00000000-0000-0000-0000-00000000000a'), ('00000000-0000-0000-0000-00000000000b');
insert into public.event_master(id, title_id, data, published_at) values ('e1','yoru_kissa','{}', now()), ('e2','yoru_kissa','{}', now() + interval '1 day');

-- A（旧端末）
set role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000000a', false);
insert into public.cloud_save(title_id, data) values ('yoru_kissa', '{"money": 12345}');
select 'A code' as step, length(public.create_transfer_code('yoru_kissa')) as code_len;
select 'A reads codes table (should fail/empty)' as step, count(*) from public.transfer_codes;
reset role;
select code as the_code from public.transfer_codes \gset

-- B（新端末）
set role authenticated;
select set_config('request.jwt.claim.sub', '00000000-0000-0000-0000-00000000000b', false);
select 'B sees A save (expect 0)' as step, count(*) from public.cloud_save;
select 'B claims' as step, public.claim_transfer_code(:'the_code') ->> 'money' as money;
select 'B now has save' as step, data->>'money' as money from public.cloud_save;
select 'B claims again (expect error)' as step, public.claim_transfer_code(:'the_code');
select 'bad code (expect error)' as step, public.claim_transfer_code('WRONGCODE123');
insert into public.purchase_records(user_id, title_id, product_id, transaction_id, platform) values ('00000000-0000-0000-0000-00000000000b','yoru_kissa','tickets_11','fake-1','ios');
select 'published masters visible (expect 1)' as step, count(*) from public.event_master;
update public.cloud_save set data = '{"money": 1}' where user_id = '00000000-0000-0000-0000-00000000000a';
reset role;
select 'A save untouched by B (expect 12345)' as step, data->>'money' from public.cloud_save where user_id = '00000000-0000-0000-0000-00000000000a';
select 'purchase rows (expect 0)' as step, count(*) from public.purchase_records;

-- 未ログインでは発行できない
set role anon;
select set_config('request.jwt.claim.sub', '', false);
select 'anon create code (expect error)' as step, public.create_transfer_code('yoru_kissa');
