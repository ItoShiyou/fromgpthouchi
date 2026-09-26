import 'package:flutter/services.dart';

/// 本番イラストの置き場所と、今ある絵の一覧。
///
/// 絵が置いてあればそれを使い、無ければコードで描いた仮の絵を使う。
/// 置き方は docs/ART_GUIDE.md。ファイル名だけで差し替わるので、コードの変更は要らない。
///
/// ```text
/// assets/art/{title}/room/base.png         背景（壁・床・カウンター。窓の部分は透明）
/// assets/art/{title}/{slot}/{itemId}.png   家具（背景と同じ大きさ・同じ位置の透明 PNG）
/// assets/art/{title}/visitors/{id}.png     客の似顔絵（正方形・透明）
/// assets/art/{title}/icons/{id}.png        家具・メニュー・商品のしるし（正方形・透明）
/// ```
class ArtLibrary {
  ArtLibrary(this.titleId, Iterable<String> assetKeys)
    : _keys = assetKeys.toSet();

  /// 絵が 1 枚もない状態（テスト・仮の絵だけのビルド）。
  ArtLibrary.empty(this.titleId) : _keys = const {};

  final String titleId;
  final Set<String> _keys;

  static Future<ArtLibrary> load(String titleId, {AssetBundle? bundle}) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(
        bundle ?? rootBundle,
      );
      return ArtLibrary(
        titleId,
        manifest.listAssets().where(
          (k) => k.startsWith('assets/art/$titleId/'),
        ),
      );
    } catch (_) {
      return ArtLibrary.empty(titleId);
    }
  }

  String get _root => 'assets/art/$titleId';

  String? _ifExists(String path) => _keys.contains(path) ? path : null;

  /// 背景（壁・床・カウンター）。
  String? get roomBase => _ifExists('$_root/room/base.png');

  /// スロットに置いた家具の絵。
  String? furniture(String slot, String itemId) =>
      _ifExists('$_root/$slot/$itemId.png');

  String? visitor(String visitorId) =>
      _ifExists('$_root/visitors/$visitorId.png');

  String? icon(String id) => _ifExists('$_root/icons/$id.png');

  bool get isEmpty => _keys.isEmpty;
  int get count => _keys.length;
}

/// 起動時に読み込む（main）。テストでは空のまま。
abstract final class Art {
  static ArtLibrary current = ArtLibrary.empty('');
}
