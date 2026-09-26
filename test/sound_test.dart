import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/core/services/sound.dart';

class _Rec implements SoundOutput {
  final log = <String>[];
  @override
  Future<void> loop(String asset, double volume) async =>
      log.add('loop $asset');
  @override
  Future<void> stopLoop() async => log.add('stop');
  @override
  Future<void> pauseLoop() async => log.add('pause');
  @override
  Future<void> resumeLoop() async => log.add('resume');
  @override
  Future<void> oneShot(String asset, double volume) async =>
      log.add('se $asset');
}

void main() {
  test('BGM は変わった時だけ流し直す', () async {
    final o = _Rec();
    final d = SoundDirector(o);
    await d.apply(asset: 'a', bgmOn: true, seOn: true);
    await d.apply(asset: 'a', bgmOn: true, seOn: true);
    await d.apply(asset: 'b', bgmOn: true, seOn: true);
    expect(o.log, ['loop a', 'loop b']);
  });

  test('BGM をオフにすると止まり、オンで戻る', () async {
    final o = _Rec();
    final d = SoundDirector(o);
    await d.apply(asset: 'a', bgmOn: true, seOn: true);
    await d.apply(asset: 'a', bgmOn: false, seOn: true);
    await d.apply(asset: 'a', bgmOn: true, seOn: true);
    expect(o.log, ['loop a', 'stop', 'loop a']);
  });

  test('効果音をオフにすると鳴らない。裏に回っている間も鳴らない', () async {
    final o = _Rec();
    final d = SoundDirector(o);
    await d.apply(asset: 'a', bgmOn: false, seOn: false);
    await d.play(Se.coin);
    await d.apply(asset: 'a', bgmOn: false, seOn: true);
    await d.pause();
    await d.play(Se.coin);
    await d.resume();
    await d.play(Se.coin);
    expect(o.log, ['se ${Se.coin.asset}']);
  });

  test('裏に回っている間に曲が変わったら、戻った時に新しい曲から始める', () async {
    final o = _Rec();
    final d = SoundDirector(o);
    await d.apply(asset: 'a', bgmOn: true, seOn: true);
    await d.pause();
    await d.apply(asset: 'b', bgmOn: true, seOn: true);
    await d.resume();
    await d.pause();
    await d.resume();
    expect(o.log, ['loop a', 'pause', 'loop b', 'pause', 'resume']);
  });

  test('音が出せない環境でも例外で止まらない', () async {
    final d = SoundDirector(_Throwing());
    await d.apply(asset: 'a', bgmOn: true, seOn: true);
    await d.play(Se.stamp);
  });
}

class _Throwing implements SoundOutput {
  @override
  Future<void> loop(String asset, double volume) => Future.error('blocked');
  @override
  Future<void> stopLoop() async {}
  @override
  Future<void> pauseLoop() async {}
  @override
  Future<void> resumeLoop() async {}
  @override
  Future<void> oneShot(String asset, double volume) => Future.error('blocked');
}
