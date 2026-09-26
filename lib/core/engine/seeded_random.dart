/// 時刻から決まる乱数。同じ時刻・同じシードなら必ず同じ結果になるので、
/// サーバーなしで「その時間に何が起きたか」を再現できる。
class SeededRandom {
  SeededRandom(int seed) : _state = _mix(seed) == 0 ? 0x9E3779B9 : _mix(seed);

  /// 複数の値からシードを作る（visitorSeed / eventSeed / weatherSeed など）。
  factory SeededRandom.of(List<int> parts) {
    var h = 0x811C9DC5;
    for (final p in parts) {
      h = _mix(h ^ p);
    }
    return SeededRandom(h);
  }

  int _state;

  /// 32bit の掛け算（JS の Math.imul 相当）。
  /// 素朴に掛けると Web(JS) では 2^53 を超えて精度が落ち、端末と結果がずれる。
  static int _imul(int a, int b) {
    final lo = a & 0xFFFF;
    final hi = (a >> 16) & 0xFFFF;
    return (lo * b + (((hi * b) & 0xFFFF) << 16)) & 0xFFFFFFFF;
  }

  static int _mix(int x) {
    x &= 0xFFFFFFFF;
    x = _imul(x ^ (x >> 16), 0x45D9F3B);
    x = _imul(x ^ (x >> 16), 0x45D9F3B);
    return (x ^ (x >> 16)) & 0xFFFFFFFF;
  }

  /// mulberry32。0 以上 1 未満。
  double nextDouble() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _state;
    t = _imul(t ^ (t >> 15), t | 1);
    t = (t ^ ((t + _imul(t ^ (t >> 7), t | 61)) & 0xFFFFFFFF)) & 0xFFFFFFFF;
    return ((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296.0;
  }

  int nextInt(int max) => (nextDouble() * max).floor().clamp(0, max - 1);

  T pick<T>(List<T> list) => list[nextInt(list.length)];

  /// 重み付き抽選。重みの合計が 0 なら null。
  T? weighted<T>(Map<T, double> weights) {
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return null;
    var r = nextDouble() * total;
    for (final e in weights.entries) {
      r -= e.value;
      if (r < 0) return e.key;
    }
    return weights.keys.last;
  }
}
