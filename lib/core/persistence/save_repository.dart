import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../state/game_state.dart';

/// ローカル保存。モックでは shared_preferences に JSON を 1 本だけ置く。
/// 本実装では Drift(SQLite) に置き換え、Supabase の cloud_save へ
/// バックアップする（設定画面の「バックアップ」）。
class SaveRepository {
  SaveRepository(this._prefs, this.titleId);

  final SharedPreferences _prefs;
  final String titleId;

  String get _key => 'save.$titleId';

  GameState? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      return GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // 壊れたセーブは読み捨てる（モックなので移行処理は持たない）。
      return null;
    }
  }

  Future<void> save(GameState s) => _prefs.setString(_key, jsonEncode(s));

  Future<void> clear() => _prefs.remove(_key);

  /// バックアップ用の書き出し（モック）。
  String export(GameState s) => base64Encode(utf8.encode(jsonEncode(s)));
}
