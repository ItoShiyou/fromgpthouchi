import 'package:audioplayers/audioplayers.dart';

/// 効果音。鳴らすのは手応えが欲しい所だけ（会計・判子・くじ・紙をめくる）。
enum Se {
  coin('audio/se_coin.wav'),
  stamp('audio/se_stamp.wav'),
  gacha('audio/se_gacha.wav'),
  paper('audio/se_paper.wav');

  const Se(this.asset);
  final String asset;
}

/// 音を実際に鳴らす部分。テストでは何もしない実装に差し替える。
abstract interface class SoundOutput {
  Future<void> loop(String asset, double volume);
  Future<void> stopLoop();
  Future<void> pauseLoop();
  Future<void> resumeLoop();
  Future<void> oneShot(String asset, double volume);
}

class SilentSoundOutput implements SoundOutput {
  const SilentSoundOutput();
  @override
  Future<void> loop(String asset, double volume) async {}
  @override
  Future<void> stopLoop() async {}
  @override
  Future<void> pauseLoop() async {}
  @override
  Future<void> resumeLoop() async {}
  @override
  Future<void> oneShot(String asset, double volume) async {}
}

class AudioplayersOutput implements SoundOutput {
  final _bgm = AudioPlayer(playerId: 'bgm');
  final _se = [for (var i = 0; i < 3; i++) AudioPlayer(playerId: 'se$i')];
  var _next = 0;

  @override
  Future<void> loop(String asset, double volume) async {
    await _bgm.setReleaseMode(ReleaseMode.loop);
    await _bgm.setVolume(volume);
    await _bgm.play(AssetSource(asset));
  }

  @override
  Future<void> stopLoop() => _bgm.stop();

  @override
  Future<void> pauseLoop() => _bgm.pause();

  @override
  Future<void> resumeLoop() => _bgm.resume();

  @override
  Future<void> oneShot(String asset, double volume) async {
    // 何本か用意して順に使う（連続で鳴っても前の音を切らない）
    final p = _se[_next];
    _next = (_next + 1) % _se.length;
    await p.stop();
    await p.play(AssetSource(asset), volume: volume);
  }
}

/// BGM と効果音の指揮役。設定（BGM・効果音のオン／オフ）と、選んでいる BGM に従う。
class SoundDirector {
  SoundDirector(this.out);

  final SoundOutput out;

  String? _current;
  bool _bgmOn = true;
  bool _seOn = true;
  bool _paused = false;

  /// 裏に回っている間に曲が変わった（戻った時に新しい曲から始める）。
  bool _pendingStart = false;

  static const bgmVolume = 0.6;
  static const seVolume = 0.8;

  /// 今どの BGM が鳴っているか（止まっていれば null）。
  String? get current => _current;

  Future<void> apply({
    required String asset,
    required bool bgmOn,
    required bool seOn,
  }) async {
    _seOn = seOn;
    _bgmOn = bgmOn;
    if (!bgmOn) {
      if (_current != null) await out.stopLoop();
      _current = null;
      return;
    }
    if (_current == asset) return;
    _current = asset;
    if (_paused) {
      _pendingStart = true;
    } else {
      await _safe(() => out.loop(asset, bgmVolume));
    }
  }

  Future<void> play(Se se) async {
    if (!_seOn || _paused) return;
    await _safe(() => out.oneShot(se.asset, seVolume));
  }

  /// アプリが裏に回った時。
  Future<void> pause() async {
    _paused = true;
    if (_current != null) await _safe(out.pauseLoop);
  }

  Future<void> resume() async {
    _paused = false;
    final asset = _current;
    if (asset == null || !_bgmOn) return;
    if (_pendingStart) {
      _pendingStart = false;
      await _safe(() => out.loop(asset, bgmVolume));
    } else {
      await _safe(out.resumeLoop);
    }
  }

  /// 音が出せない環境（自動再生の制限など）でも、ゲームは止めない。
  Future<void> _safe(Future<void> Function() f) async {
    try {
      await f();
    } catch (_) {}
  }
}
