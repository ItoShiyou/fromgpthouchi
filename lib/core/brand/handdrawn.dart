import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';

/// 手描きの線。
///
/// 真円・定規で引いた直線・完全な角丸は、画面を「機械が作った」ように見せる。
/// 「まちの余白」では輪郭をすべて少しだけ揺らし、紙に粒を入れる。
/// 揺れは位置から決まる（毎フレーム同じ）ので、アニメーション中もちらつかない。
abstract final class Rough {
  /// なめらかな揺れ（-1〜1）。
  static double _noise(double t, double seed) =>
      math.sin(t * 0.83 + seed) * 0.55 +
      math.sin(t * 0.31 + seed * 2.1) * 0.35 +
      math.sin(t * 1.9 + seed * 0.7) * 0.1;

  /// 任意の閉じたパスの輪郭を揺らしたものを返す。
  static Path wobble(
    Path source, {
    double amount = 1.2,
    double seed = 0,
    double step = 5,
  }) {
    final out = Path();
    for (final m in source.computeMetrics()) {
      final n = math.max(8, (m.length / step).ceil());
      for (var i = 0; i <= n; i++) {
        final d = m.length * i / n;
        final tan = m.getTangentForOffset(d % m.length);
        if (tan == null) continue;
        final normal = Offset(-tan.vector.dy, tan.vector.dx);
        final p = tan.position + normal * (_noise(d / 7, seed) * amount);
        if (i == 0) {
          out.moveTo(p.dx, p.dy);
        } else {
          out.lineTo(p.dx, p.dy);
        }
      }
      if (m.isClosed) out.close();
    }
    return out;
  }

  static double seedOf(Rect r) =>
      (r.width * 0.37 + r.height * 0.91 + r.left * 0.13 + r.top * 0.07) % 97;

  static Path rrect(
    Rect r,
    double radius, {
    double amount = 1.2,
    double? seed,
  }) => wobble(
    Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(radius))),
    amount: amount,
    seed: seed ?? seedOf(r),
  );

  static Path oval(Rect r, {double amount = 1.0, double? seed}) =>
      wobble(Path()..addOval(r), amount: amount, seed: seed ?? seedOf(r));

  static Path line(
    Offset a,
    Offset b, {
    double amount = 0.8,
    double seed = 0,
  }) => wobble(
    Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy),
    amount: amount,
    seed: seed + a.dx * 0.1,
  );

  /// インクの線。1 本目の上に細い 2 本目を少しずらして重ね、ペンのかすれを出す。
  static void ink(
    Canvas canvas,
    Path path, {
    Color color = const Color(0xFF3B2C22),
    double width = 1.4,
    double opacity = 1,
  }) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color.withValues(alpha: 0.85 * opacity)
      ..strokeWidth = width;
    canvas.drawPath(path, p);
    canvas.drawPath(
      path.shift(Offset(width * 0.35, -width * 0.25)),
      p
        ..color = color.withValues(alpha: 0.3 * opacity)
        ..strokeWidth = width * 0.5,
    );
  }
}

/// 揺れた角丸の形。ボタン・カード・ダイアログ・パネルの縁に使う。
class RoughBorder extends OutlinedBorder {
  const RoughBorder({super.side, this.radius = 10, this.amount = 1.1});

  final double radius;
  final double amount;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Rough.rrect(rect, radius, amount: amount);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Rough.rrect(
    rect.deflate(side.width),
    math.max(0, radius - side.width),
    amount: amount,
  );

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;
    Rough.ink(
      canvas,
      getOuterPath(rect.deflate(side.width / 2)),
      color: side.color,
      width: side.width,
    );
  }

  @override
  RoughBorder copyWith({BorderSide? side, double? radius}) => RoughBorder(
    side: side ?? this.side,
    radius: radius ?? this.radius,
    amount: amount,
  );

  @override
  ShapeBorder scale(double t) =>
      RoughBorder(side: side.scale(t), radius: radius * t, amount: amount);
}

/// 紙の粒と繊維。静的なので RepaintBoundary の中で一度だけ描かれる。
class PaperGrain extends StatelessWidget {
  const PaperGrain({super.key, this.opacity = 1, this.dark = false});

  final double opacity;

  /// 夜の絵の上に重ねる時は明るい粒にする。
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _GrainPainter(opacity: opacity, dark: dark),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter({required this.opacity, required this.dark});

  final double opacity;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(11);
    var n = (size.width * size.height / 45).clamp(0, 20000).toInt();
    n -= n % 2;
    // 偶数番目を暗い粒、奇数番目を明るい粒にする（それぞれ x,y の組が n/2 個）。
    final a = Float32List(n), b = Float32List(n);
    for (var i = 0; i < n; i++) {
      final x = rnd.nextDouble() * size.width,
          y = rnd.nextDouble() * size.height;
      if (i.isEven) {
        a[i] = x;
        a[i + 1] = y;
      } else {
        b[i - 1] = x;
        b[i] = y;
      }
    }
    final base = dark ? Colors.white : const Color(0xFF6B5237);
    canvas.drawRawPoints(
      ui.PointMode.points,
      a,
      Paint()
        ..color = base.withValues(alpha: 0.10 * opacity)
        ..strokeWidth = 1,
    );
    canvas.drawRawPoints(
      ui.PointMode.points,
      b,
      Paint()
        ..color = (dark ? Colors.black : Colors.white).withValues(
          alpha: 0.18 * opacity,
        )
        ..strokeWidth = 1.2,
    );
    // 繊維
    final fiber = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..color = base.withValues(alpha: 0.07 * opacity);
    for (var i = 0; i < size.width * size.height / 9000; i++) {
      final p = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height,
      );
      final a = rnd.nextDouble() * math.pi;
      final l = 6 + rnd.nextDouble() * 14;
      canvas.drawPath(
        Path()
          ..moveTo(p.dx, p.dy)
          ..quadraticBezierTo(
            p.dx + math.cos(a) * l / 2 + 2,
            p.dy + math.sin(a) * l / 2 - 2,
            p.dx + math.cos(a) * l,
            p.dy + math.sin(a) * l,
          ),
        fiber,
      );
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) =>
      old.opacity != opacity || old.dark != dark;
}

/// 判子のような一文字のしるし。家具・メニュー・商品のアイコン。
///
/// 絵文字は端末ごとに絵柄が違い、既製品の印象が強いので使わない。
/// 本番ではここを手描きイラストに差し替えてもよいが、しるしのままでもブランドになる。
class InkGlyph extends StatelessWidget {
  const InkGlyph(
    this.glyph, {
    super.key,
    this.size = 52,
    this.locked = false,
    this.color = YohakuColors.woodDark,
  });

  final String glyph;
  final double size;
  final bool locked;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GlyphFramePainter(
          seed: glyph.isEmpty ? 0 : glyph.codeUnitAt(0).toDouble(),
          color: locked ? YohakuColors.paperLine : color,
          square: glyph.isNotEmpty && glyph.codeUnitAt(0).isEven,
        ),
        child: Center(
          child: Transform.rotate(
            angle: glyph.isEmpty ? 0 : ((glyph.codeUnitAt(0) % 7) - 3) * 0.025,
            child: Text(
              locked ? '？' : glyph,
              style: TextStyle(
                fontSize: size * 0.46,
                height: 1,
                fontWeight: FontWeight.w600,
                color: locked ? YohakuColors.paperLine : color,
                fontFamilyFallback: const [
                  'Hiragino Mincho ProN',
                  'Yu Mincho',
                  'Noto Serif JP',
                  'Noto Serif CJK JP',
                  'serif',
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlyphFramePainter extends CustomPainter {
  _GlyphFramePainter({
    required this.seed,
    required this.color,
    required this.square,
  });

  final double seed;
  final Color color;
  final bool square;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(size.width * 0.1);
    final path = square
        ? Rough.rrect(
            r,
            size.width * 0.12,
            amount: size.width * 0.02,
            seed: seed,
          )
        : Rough.oval(r, amount: size.width * 0.025, seed: seed);
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.07));
    Rough.ink(
      canvas,
      path,
      color: color,
      width: math.max(1.2, size.width * 0.035),
    );
  }

  @override
  bool shouldRepaint(_GlyphFramePainter old) =>
      old.seed != seed || old.color != color;
}

/// 筆でさっと引いた下線（選択中のタブ・見出し）。
class BrushUnderline extends StatelessWidget {
  const BrushUnderline({
    super.key,
    required this.width,
    this.color = YohakuColors.lamp,
    this.thickness = 5,
  });

  final double width;
  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, thickness + 2),
    painter: _BrushPainter(color: color, thickness: thickness),
  );
}

class _BrushPainter extends CustomPainter {
  _BrushPainter({required this.color, required this.thickness});

  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final path = Path()
      ..moveTo(2, y + 1)
      ..quadraticBezierTo(
        size.width * 0.5,
        y - thickness * 0.35,
        size.width - 2,
        y - 0.5,
      );
    canvas.drawPath(
      Rough.wobble(path, amount: 0.8, seed: size.width),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = thickness
        ..color = color.withValues(alpha: 0.75),
    );
  }

  @override
  bool shouldRepaint(_BrushPainter old) => old.color != color;
}
