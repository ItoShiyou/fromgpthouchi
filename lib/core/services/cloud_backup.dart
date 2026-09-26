import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'purchase_store.dart';

import '../state/game_state.dart';

/// クラウドのバックアップと機種変更（Supabase）。
///
/// 正本は端末の SQLite。クラウドは「預けておく」場所で、自動では上書きしない。
/// ビルド時に URL とキーを渡した時だけ有効になる（無ければ設定画面にも出ない）。
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co
///   --dart-define=SUPABASE_KEY=（publishable / anon key）
abstract interface class CloudBackup {
  bool get enabled;

  Future<DateTime?> lastBackupAt(String titleId);
  Future<void> upload(String titleId, GameState s);
  Future<GameState?> download(String titleId);

  /// 旧端末で発行する、24 時間有効・一度きりのコード。
  Future<String> createTransferCode(String titleId);

  /// 新端末で入力する。セーブが写され、その内容が返る。
  Future<GameState> claimTransferCode(String code);
}

class DisabledCloudBackup implements CloudBackup {
  const DisabledCloudBackup();

  @override
  bool get enabled => false;

  @override
  Future<DateTime?> lastBackupAt(String titleId) async => null;

  @override
  Future<void> upload(String titleId, GameState s) =>
      throw UnsupportedError('cloud disabled');

  @override
  Future<GameState?> download(String titleId) async => null;

  @override
  Future<String> createTransferCode(String titleId) =>
      throw UnsupportedError('cloud disabled');

  @override
  Future<GameState> claimTransferCode(String code) =>
      throw UnsupportedError('cloud disabled');
}

class SupabaseCloudBackup implements CloudBackup {
  SupabaseCloudBackup(this.client);

  final SupabaseClient client;

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const key = String.fromEnvironment('SUPABASE_KEY');
  static bool get configured => url.isNotEmpty && key.isNotEmpty;

  @override
  bool get enabled => true;

  /// 端末ごとの匿名ユーザー。初回だけサインインする。
  Future<void> _signIn() async {
    if (client.auth.currentSession == null) {
      await client.auth.signInAnonymously();
    }
  }

  @override
  Future<DateTime?> lastBackupAt(String titleId) async {
    await _signIn();
    final row = await client
        .from('cloud_save')
        .select('updated_at')
        .eq('title_id', titleId)
        .maybeSingle();
    return row == null
        ? null
        : DateTime.parse(row['updated_at'] as String).toLocal();
  }

  @override
  Future<void> upload(String titleId, GameState s) async {
    await _signIn();
    await client.from('cloud_save').upsert({
      'user_id': client.auth.currentUser!.id,
      'title_id': titleId,
      'data': s.toJson(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<GameState?> download(String titleId) async {
    await _signIn();
    final row = await client
        .from('cloud_save')
        .select('data')
        .eq('title_id', titleId)
        .maybeSingle();
    return row == null
        ? null
        : GameState.fromJson(row['data'] as Map<String, dynamic>);
  }

  @override
  Future<String> createTransferCode(String titleId) async {
    await _signIn();
    return await client.rpc<String>(
      'create_transfer_code',
      params: {'p_title': titleId},
    );
  }

  @override
  Future<GameState> claimTransferCode(String code) async {
    await _signIn();
    final data = await client.rpc<Map<String, dynamic>>(
      'claim_transfer_code',
      params: {'p_code': code},
    );
    return GameState.fromJson(data);
  }
}

/// main() から呼ぶ。設定が無ければ無効のまま。
Future<CloudBackup> createCloudBackup() async {
  if (!SupabaseCloudBackup.configured) return const DisabledCloudBackup();
  final s = await Supabase.initialize(
    url: SupabaseCloudBackup.url,
    publishableKey: SupabaseCloudBackup.key,
  );
  return SupabaseCloudBackup(s.client);
}

/// レシートをサーバー（Edge Function verify-receipt）で確かめる。
/// サーバー側のストア照会を実装してから、`--dart-define=VERIFY_RECEIPTS=true` で有効にする。
class SupabaseReceiptVerifier implements ReceiptVerifier {
  SupabaseReceiptVerifier(this.client, this.titleId);

  final SupabaseClient client;
  final String titleId;

  static const enabledByBuild = bool.fromEnvironment('VERIFY_RECEIPTS');

  @override
  Future<bool> verify(StorePurchased event) async {
    if (client.auth.currentSession == null) {
      await client.auth.signInAnonymously();
    }
    final res = await client.functions.invoke(
      'verify-receipt',
      body: {
        'title_id': titleId,
        'product_id': event.productId,
        'transaction_id': event.transactionId,
        'platform': defaultTargetPlatform == TargetPlatform.iOS
            ? 'ios'
            : 'android',
        'verification_data': event.verificationData ?? '',
      },
    );
    return res.data is Map && (res.data as Map)['ok'] == true;
  }
}
