import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/brand/theme.dart';
import '../core/models/content.dart';

/// 通りすがりの客の見た目。来店時刻から決まるので、同じ客は同じ見た目。
VisitorLook anonymousLook(int seed) {
  const hairs = [0xFF2B2622, 0xFF5A3E2B, 0xFF8A6A4A, 0xFF3A3A40, 0xFFB9B2A8];
  const clothes = [
    0xFF7B8C9E,
    0xFFB48A6A,
    0xFF6E7F6A,
    0xFF9E6B6B,
    0xFF5E6478,
    0xFFC9B79C,
  ];
  const styles = [
    HairStyle.short,
    HairStyle.bob,
    HairStyle.long,
    HairStyle.short,
    HairStyle.cap,
  ];
  final r = math.Random(seed);
  return VisitorLook(
    hair: hairs[r.nextInt(hairs.length)],
    clothes: clothes[r.nextInt(clothes.length)],
    style: styles[r.nextInt(styles.length)],
  );
}

/// 四角い似顔絵カード。
class Portrait extends StatelessWidget {
  const Portrait({
    super.key,
    required this.look,
    this.size = 56,
    this.locked = false,
    this.background = const Color(0xFFE9DDC8),
  });

  final VisitorLook look;
  final double size;

  /// 未発見の時はシルエットで描く。
  final bool locked;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: locked ? YohakuColors.paperLine : background,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: PortraitPainter(look: look, silhouette: locked),
      ),
    );
  }
}

/// バストアップの人物。店内の客にも同じものを使う。
class PortraitPainter extends CustomPainter {
  const PortraitPainter({required this.look, this.silhouette = false});

  final VisitorLook look;
  final bool silhouette;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final dx = (size.width - s) / 2, dy = size.height - s;
    canvas.save();
    canvas.translate(dx, dy);
    Offset p(double x, double y) => Offset(x * s, y * s);

    const shadow = Color(0xFFB9A88F);
    final hair = silhouette ? shadow : Color(look.hair);
    final skin = silhouette ? shadow : Color(look.skin);
    final clothes = silhouette ? shadow : Color(look.clothes);
    final hairPaint = Paint()..color = hair;

    // 後ろ髪
    switch (look.style) {
      case HairStyle.long:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(0.27 * s, 0.26 * s, 0.73 * s, 0.8 * s),
            Radius.circular(0.18 * s),
          ),
          hairPaint,
        );
      case HairStyle.ponytail:
        canvas.drawOval(
          Rect.fromCenter(
            center: p(0.73, 0.5),
            width: 0.16 * s,
            height: 0.3 * s,
          ),
          hairPaint,
        );
      case HairStyle.bun:
        canvas.drawCircle(p(0.5, 0.17), 0.09 * s, hairPaint);
      default:
        break;
    }

    // 体
    final body = RRect.fromRectAndCorners(
      Rect.fromLTRB(0.14 * s, 0.7 * s, 0.86 * s, 1.08 * s),
      topLeft: Radius.circular(0.24 * s),
      topRight: Radius.circular(0.24 * s),
    );
    canvas.drawRRect(body, Paint()..color = clothes);
    // 首と襟
    canvas.drawRect(
      Rect.fromLTRB(0.44 * s, 0.56 * s, 0.56 * s, 0.72 * s),
      Paint()..color = skin,
    );
    if (!silhouette) {
      final collar = Path()
        ..moveTo(0.39 * s, 0.7 * s)
        ..lineTo(0.5 * s, 0.84 * s)
        ..lineTo(0.61 * s, 0.7 * s)
        ..close();
      canvas.drawPath(collar, Paint()..color = const Color(0xFFF7F2E8));
      if (look.accent != null) {
        final tie = Path()
          ..moveTo(0.47 * s, 0.74 * s)
          ..lineTo(0.53 * s, 0.74 * s)
          ..lineTo(0.55 * s, 0.95 * s)
          ..lineTo(0.5 * s, 1.0 * s)
          ..lineTo(0.45 * s, 0.95 * s)
          ..close();
        canvas.drawPath(tie, Paint()..color = Color(look.accent!));
      }
    }

    // 頭
    final head = p(0.5, 0.42);
    final r = 0.2 * s;
    canvas.drawOval(
      Rect.fromCenter(center: head, width: r * 2, height: r * 2.15),
      Paint()..color = skin,
    );

    // 前髪
    canvas.save();
    canvas.clipRect(
      Rect.fromLTRB(
        0,
        0,
        s,
        head.dy - r * (look.style == HairStyle.gray ? 0.55 : 0.2),
      ),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: head.translate(0, -r * 0.08),
        width: r * 2.2,
        height: r * 2.3,
      ),
      hairPaint,
    );
    canvas.restore();
    switch (look.style) {
      case HairStyle.long:
      case HairStyle.bob:
        for (final side in [-1.0, 1.0]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: head.translate(
                  side * r * 0.92,
                  r * (look.style == HairStyle.bob ? 0.15 : 0.35),
                ),
                width: r * 0.42,
                height: r * (look.style == HairStyle.bob ? 1.3 : 1.8),
              ),
              Radius.circular(r * 0.2),
            ),
            hairPaint,
          );
        }
      case HairStyle.ponytail:
      case HairStyle.short:
        for (final side in [-1.0, 1.0]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: head.translate(side * r * 0.9, -r * 0.1),
                width: r * 0.3,
                height: r * 0.7,
              ),
              Radius.circular(r * 0.15),
            ),
            hairPaint,
          );
        }
      case HairStyle.cap:
        final cap = Paint()
          ..color = silhouette ? shadow : const Color(0xFF3E4A5E);
        canvas.drawArc(
          Rect.fromCenter(
            center: head.translate(0, -r * 0.15),
            width: r * 2.2,
            height: r * 2.0,
          ),
          math.pi,
          math.pi,
          true,
          cap,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              head.dx - r * 0.2,
              head.dy - r * 0.3,
              r * 1.4,
              r * 0.22,
            ),
            Radius.circular(r * 0.1),
          ),
          cap,
        );
      case HairStyle.gray:
      case HairStyle.bun:
        break;
    }

    if (!silhouette) {
      // 顔
      final eye = Paint()..color = const Color(0xFF3A2A22);
      for (final side in [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: head.translate(side * r * 0.38, r * 0.1),
            width: r * 0.16,
            height: r * 0.24,
          ),
          eye,
        );
        canvas.drawCircle(
          head.translate(side * r * 0.55, r * 0.42),
          r * 0.14,
          Paint()..color = const Color(0x33E0706A),
        );
      }
      canvas.drawArc(
        Rect.fromCenter(
          center: head.translate(0, r * 0.45),
          width: r * 0.3,
          height: r * 0.18,
        ),
        0.2,
        math.pi - 0.4,
        false,
        Paint()
          ..color = const Color(0xFF9A5A4A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, r * 0.06),
      );
      if (look.glasses) {
        final g = Paint()
          ..color = const Color(0xFF3A2A22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, r * 0.07);
        for (final side in [-1.0, 1.0]) {
          canvas.drawCircle(
            head.translate(side * r * 0.38, r * 0.1),
            r * 0.26,
            g,
          );
        }
        canvas.drawLine(
          head.translate(-r * 0.12, r * 0.08),
          head.translate(r * 0.12, r * 0.08),
          g,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PortraitPainter old) =>
      old.look != look || old.silhouette != silhouette;
}
