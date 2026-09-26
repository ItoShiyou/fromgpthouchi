import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/core/engine/seeded_random.dart';

/// 端末（ネイティブ）と Web(JS) で同じ乱数列になることを保証する。
/// `flutter test --platform chrome test/seeded_random_test.dart` でも通ること。
void main() {
  test('時刻シードの乱数はプラットフォームに依存しない', () {
    final r = SeededRandom.of([20260926, 0x71517, 5900000]);
    expect(
      [for (var i = 0; i < 4; i++) r.nextDouble()],
      [
        0.464435062604025,
        0.6131905184593052,
        0.6632595281116664,
        0.08859577169641852,
      ],
    );
    expect(SeededRandom.of([1, 2, 3]).nextInt(1000000), 411028);
  });
}
