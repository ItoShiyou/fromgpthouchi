import 'package:flutter_test/flutter_test.dart';
import 'package:yoru_kissa/core/art/art_library.dart';

void main() {
  test('置いてある絵だけが使われる', () {
    final art = ArtLibrary('yoru_kissa', const [
      'assets/art/yoru_kissa/room/base.png',
      'assets/art/yoru_kissa/seat/red_sofa.png',
      'assets/art/yoru_kissa/visitors/nurse.png',
      'assets/art/yoru_kissa/icons/blend.png',
      'assets/art/yoru_kissa/seat/.gitkeep',
    ]);
    expect(art.roomBase, 'assets/art/yoru_kissa/room/base.png');
    expect(
      art.furniture('seat', 'red_sofa'),
      'assets/art/yoru_kissa/seat/red_sofa.png',
    );
    expect(art.furniture('seat', 'green_sofa'), isNull);
    expect(art.visitor('nurse'), isNotNull);
    expect(art.visitor('student'), isNull);
    expect(art.icon('blend'), isNotNull);
    expect(art.icon('pudding'), isNull);
  });

  test('絵が無ければ、すべてコードの絵にもどる', () {
    final art = ArtLibrary.empty('yoru_kissa');
    expect(art.roomBase, isNull);
    expect(art.furniture('seat', 'red_sofa'), isNull);
    expect(art.isEmpty, isTrue);
  });
}
