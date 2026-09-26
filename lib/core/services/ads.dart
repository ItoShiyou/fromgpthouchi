import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 広告。出すのはお店の画面下のバナー 1 枚だけ（全画面広告・動画広告は出さない）。
/// 「広告なし」を買えば出ない。
///
/// 広告ユニット ID はビルド時に渡す。渡さなければ Google のテスト用 ID を使う。
///   --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-xxx/yyy
///   --dart-define=ADMOB_BANNER_IOS=ca-app-pub-xxx/zzz
/// アプリ ID は AndroidManifest.xml / Info.plist に書く（docs/STORE_SETUP.md）。
abstract final class Ads {
  static const _androidBanner = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111', // テスト用
  );
  static const _iosBanner = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716', // テスト用
  );

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get bannerUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS ? _iosBanner : _androidBanner;

  static bool _ready = false;
  static Completer<void>? _starting;

  /// 同意（EU などで必要な場合だけフォームが出る）→ SDK の初期化。
  /// 広告を出す直前に一度だけ行う。「広告なし」の人には何もしない。
  static Future<bool> ensureReady() async {
    if (!supported) return false;
    if (_ready) return true;
    if (_starting != null) {
      await _starting!.future;
      return _ready;
    }
    final c = _starting = Completer<void>();
    try {
      final info = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => ConsentForm.loadAndShowConsentFormIfRequired(
          (_) => info.complete(),
        ),
        (_) => info.complete(),
      );
      await info.future;
      if (await ConsentInformation.instance.canRequestAds()) {
        await MobileAds.instance.initialize();
        _ready = true;
      }
    } catch (_) {
      _ready = false;
    } finally {
      c.complete();
    }
    return _ready;
  }
}

/// 設定画面から、広告の同意をやり直す（同意が必要な地域でだけ出す）。
Future<void> showAdPrivacyOptions() async {
  if (!Ads.supported) return;
  final done = Completer<void>();
  ConsentForm.showPrivacyOptionsForm((_) => done.complete());
  await done.future;
}

Future<bool> adPrivacyOptionsRequired() async {
  if (!Ads.supported) return false;
  return await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus() ==
      PrivacyOptionsRequirementStatus.required;
}

/// お店の画面下のバナー。端末では AdMob、Web では枠だけ出す。
class ShopBanner extends StatefulWidget {
  const ShopBanner({super.key, required this.placeholder});

  /// 広告が出せない時（Web・読み込み失敗・同意なし）に代わりに置くもの。
  final Widget placeholder;

  @override
  State<ShopBanner> createState() => _ShopBannerState();
}

class _ShopBannerState extends State<ShopBanner> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!await Ads.ensureReady() || !mounted) return;
    final ad = BannerAd(
      adUnitId: Ads.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _ad = null);
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return widget.placeholder;
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
