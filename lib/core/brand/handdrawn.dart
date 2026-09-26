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

enum Sketch {
  back,
  forward,
  close,
  check,
  plus,
  coin,
  ticket,
  gear,
  upload,
  book,
}

/// 手描きの小さなアイコン。Material の既製アイコンの代わりに使う。
class SketchIcon extends StatelessWidget {
  const SketchIcon(
    this.kind, {
    super.key,
    this.size = 24,
    this.color = YohakuColors.ink,
  });

  final Sketch kind;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _SketchPainter(kind, color)),
  );
}

class _SketchPainter extends CustomPainter {
  _SketchPainter(this.kind, this.color);

  final Sketch kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    Offset p(double x, double y) => Offset(x * s, y * s);
    final w = math.max(1.3, s * 0.085);
    void stroke(Path path) => Rough.ink(
      canvas,
      Rough.wobble(path, amount: s * 0.02, seed: s + kind.index),
      color: color,
      width: w,
    );
    Path poly(List<Offset> pts) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      return path;
    }

    switch (kind) {
      case Sketch.back:
        stroke(poly([p(0.62, 0.2), p(0.34, 0.5), p(0.63, 0.8)]));
      case Sketch.forward:
        stroke(poly([p(0.38, 0.2), p(0.66, 0.5), p(0.37, 0.8)]));
      case Sketch.close:
        stroke(poly([p(0.25, 0.24), p(0.76, 0.77)]));
        stroke(poly([p(0.74, 0.23), p(0.26, 0.76)]));
      case Sketch.check:
        stroke(poly([p(0.2, 0.52), p(0.42, 0.74), p(0.82, 0.24)]));
      case Sketch.plus:
        stroke(
          Path()
            ..addOval(Rect.fromCircle(center: p(0.5, 0.5), radius: s * 0.4)),
        );
        stroke(poly([p(0.5, 0.3), p(0.5, 0.7)]));
        stroke(poly([p(0.3, 0.5), p(0.7, 0.5)]));
      case Sketch.coin:
        final c = Rect.fromCircle(center: p(0.5, 0.5), radius: s * 0.4);
        canvas.drawPath(
          Rough.oval(c, amount: s * 0.02, seed: 3),
          Paint()..color = YohakuColors.lamp,
        );
        stroke(Path()..addOval(c));
        stroke(poly([p(0.37, 0.32), p(0.5, 0.5), p(0.63, 0.32)]));
        stroke(poly([p(0.5, 0.5), p(0.5, 0.72)]));
        stroke(poly([p(0.38, 0.55), p(0.62, 0.55)]));
      case Sketch.ticket:
        final r = Rect.fromLTRB(0.12 * s, 0.28 * s, 0.88 * s, 0.72 * s);
        canvas.drawPath(
          Rough.rrect(r, s * 0.06, amount: s * 0.02, seed: 5),
          Paint()..color = const Color(0xFF9FC3CF),
        );
        stroke(
          Path()
            ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(s * 0.06))),
        );
        for (var y = 0.34; y < 0.7; y += 0.1) {
          canvas.drawCircle(p(0.34, y), s * 0.02, Paint()..color = color);
        }
      case Sketch.gear:
        stroke(
          Path()
            ..addOval(Rect.fromCircle(center: p(0.5, 0.5), radius: s * 0.24)),
        );
        stroke(
          Path()
            ..addOval(Rect.fromCircle(center: p(0.5, 0.5), radius: s * 0.08)),
        );
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          stroke(
            poly([
              p(0.5 + math.cos(a) * 0.26, 0.5 + math.sin(a) * 0.26),
              p(0.5 + math.cos(a) * 0.4, 0.5 + math.sin(a) * 0.4),
            ]),
          );
        }
      case Sketch.upload:
        stroke(poly([p(0.2, 0.62), p(0.2, 0.8), p(0.8, 0.8), p(0.8, 0.62)]));
        stroke(poly([p(0.5, 0.66), p(0.5, 0.2)]));
        stroke(poly([p(0.33, 0.36), p(0.5, 0.2), p(0.67, 0.36)]));
      case Sketch.book:
        stroke(poly([p(0.5, 0.26), p(0.5, 0.8)]));
        stroke(
          poly([
            p(0.5, 0.26),
            p(0.14, 0.2),
            p(0.14, 0.74),
            p(0.5, 0.8),
            p(0.86, 0.74),
            p(0.86, 0.2),
            p(0.5, 0.26),
          ]),
        );
    }
  }

  @override
  bool shouldRepaint(_SketchPainter old) =>
      old.kind != kind || old.color != color;
}
