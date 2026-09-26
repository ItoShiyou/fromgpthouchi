import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// タイトル画面の「夜喫茶」の外観。
class ExteriorPainter extends CustomPainter {
  ExteriorPainter({required this.animation}) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final t = animation.value;
    Rect r(double l, double tp, double rr, double b) =>
        Rect.fromLTRB(l * w, tp * h, rr * w, b * h);

    // 夜空
    final sky = Offset.zero & size;
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F1A36), Color(0xFF263A6B), Color(0xFF3D4F7E)],
        ).createShader(sky),
    );
    final rnd = math.Random(4);
    for (var i = 0; i < 90; i++) {
      final o = Offset(rnd.nextDouble() * w, rnd.nextDouble() * h * 0.45);
      final tw =
          0.4 +
          0.6 * (0.5 + 0.5 * math.sin((t + rnd.nextDouble()) * math.pi * 2));
      canvas.drawCircle(
        o,
        0.5 + rnd.nextDouble() * 1.2,
        Paint()..color = Color.fromRGBO(255, 246, 220, tw * 0.9),
      );
    }
    final moon = Offset(w * 0.82, h * 0.12);
    canvas.drawCircle(moon, w * 0.1, Paint()..color = const Color(0x22FFF3C4));
    canvas.drawCircle(
      moon,
      w * 0.045,
      Paint()..color = const Color(0xFFFFF3C4),
    );

    // 遠くの家並み
    final far = Path()..moveTo(0, h * 0.44);
    final rr = math.Random(8);
    var x = 0.0;
    while (x < w) {
      final bw = w * (0.08 + rr.nextDouble() * 0.1);
      final bh = h * (0.03 + rr.nextDouble() * 0.06);
      far
        ..lineTo(x, h * 0.44 - bh)
        ..lineTo(x + bw, h * 0.44 - bh);
      x += bw;
    }
    far
      ..lineTo(w, h * 0.8)
      ..lineTo(0, h * 0.8)
      ..close();
    canvas.drawPath(far, Paint()..color = const Color(0xFF1A2442));

    // 建物
    final facade = r(0.06, 0.34, 0.94, 0.76);
    canvas.drawRect(facade, Paint()..color = const Color(0xFF5A3B2B));
    canvas.drawRect(
      r(0.04, 0.32, 0.96, 0.345),
      Paint()..color = const Color(0xFF3A2519),
    );
    // 板張り
    final board = Paint()
      ..color = const Color(0xFF4E3224)
      ..strokeWidth = 1;
    for (var y = facade.top + 8; y < facade.bottom; y += 9) {
      canvas.drawLine(Offset(facade.left, y), Offset(facade.right, y), board);
    }
    // 2 階の窓
    for (final l in [0.16, 0.66]) {
      final win = r(l, 0.37, l + 0.18, 0.45);
      canvas.drawRect(win.inflate(3), Paint()..color = const Color(0xFF3A2519));
      canvas.drawRect(
        win,
        Paint()
          ..color = l < 0.5 ? const Color(0xFFF2C979) : const Color(0xFF26304F),
      );
      canvas.drawLine(
        Offset(win.center.dx, win.top),
        Offset(win.center.dx, win.bottom),
        Paint()
          ..color = const Color(0xFF3A2519)
          ..strokeWidth = 2,
      );
    }

    // 大きな窓（店内の灯り）
    final shop = r(0.1, 0.55, 0.6, 0.73);
    canvas.drawRect(shop.inflate(4), Paint()..color = const Color(0xFF3A2519));
    canvas.drawRect(
      shop,
      Paint()
        ..shader = ui.Gradient.radial(shop.center, shop.width * 0.7, [
          const Color(0xFFFFD58A),
          const Color(0xFFD98A3E),
        ]),
    );
    final inside = Paint()..color = const Color(0x88693A1E);
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          shop.left + 6,
          shop.top + 10 + i * 12,
          shop.width * 0.35,
          2,
        ),
        inside,
      );
    }
    for (final (dx, c) in [(0.62, 0xFF6B4A3A), (0.8, 0xFF3E4A6B)]) {
      final head = Offset(
        shop.left + shop.width * dx,
        shop.top + shop.height * 0.5,
      );
      canvas.drawCircle(head, shop.height * 0.1, Paint()..color = Color(c));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: head.translate(0, shop.height * 0.28),
            width: shop.height * 0.36,
            height: shop.height * 0.4,
          ),
          const Radius.circular(8),
        ),
        Paint()..color = Color(c),
      );
    }
    canvas.drawRect(
      Rect.fromLTWH(
        shop.left,
        shop.bottom - shop.height * 0.18,
        shop.width,
        shop.height * 0.18,
      ),
      Paint()..color = const Color(0xAA5A3620),
    );
    final mullion = Paint()
      ..color = const Color(0xFF3A2519)
      ..strokeWidth = 3;
    for (final f in [1 / 3, 2 / 3]) {
      canvas.drawLine(
        Offset(shop.left + shop.width * f, shop.top),
        Offset(shop.left + shop.width * f, shop.bottom),
        mullion,
      );
    }

    // 日よけ（赤と生成りのストライプ）
    final awning = r(0.07, 0.49, 0.63, 0.545);
    const stripes = 9;
    for (var i = 0; i < stripes; i++) {
      final sw = awning.width / stripes;
      final path = Path()
        ..moveTo(awning.left + i * sw, awning.top)
        ..lineTo(awning.left + (i + 1) * sw, awning.top)
        ..lineTo(awning.left + (i + 1) * sw + 2, awning.bottom)
        ..arcToPoint(
          Offset(awning.left + i * sw - 2, awning.bottom),
          radius: Radius.circular(sw / 2),
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = i.isEven
              ? const Color(0xFFA5342E)
              : const Color(0xFFEFE2C8),
      );
    }

    // 扉
    final door = r(0.67, 0.53, 0.85, 0.76);
    canvas.drawRect(door.inflate(3), Paint()..color = const Color(0xFF3A2519));
    canvas.drawRect(door, Paint()..color = const Color(0xFF6B452A));
    canvas.drawRect(
      Rect.fromLTRB(
        door.left + 6,
        door.top + 6,
        door.right - 6,
        door.center.dy,
      ),
      Paint()..color = const Color(0xFFF2C979),
    );
    canvas.drawCircle(
      Offset(door.left + 8, door.center.dy + 12),
      2.5,
      Paint()..color = const Color(0xFFC9A04F),
    );
    // 吊り看板
    final sign = r(0.71, 0.47, 0.81, 0.515);
    canvas.drawLine(
      Offset(sign.left + 4, h * 0.45),
      sign.topLeft.translate(4, 0),
      Paint()..color = const Color(0xFF2B2A33),
    );
    canvas.drawLine(
      Offset(sign.right - 4, h * 0.45),
      sign.topRight.translate(-4, 0),
      Paint()..color = const Color(0xFF2B2A33),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(sign, const Radius.circular(3)),
      Paint()..color = const Color(0xFF2F3B33),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: '喫茶',
        style: TextStyle(
          color: const Color(0xFFF3EBDD),
          fontSize: sign.height * 0.55,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, sign.center - Offset(tp.width / 2, tp.height / 2));

    // 地面・階段
    canvas.drawRect(r(0, 0.76, 1, 1), Paint()..color = const Color(0xFF232B45));
    canvas.drawRect(
      r(0.64, 0.76, 0.88, 0.785),
      Paint()..color = const Color(0xFF7A6A5E),
    );
    canvas.drawRect(
      r(0.62, 0.785, 0.9, 0.81),
      Paint()..color = const Color(0xFF6A5A50),
    );
    // 灯りのにじみ
    canvas.drawCircle(
      shop.center.translate(0, shop.height),
      w * 0.5,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = ui.Gradient.radial(
          shop.center.translate(0, shop.height),
          w * 0.5,
          [const Color(0x55FFB866), const Color(0x00FFB866)],
        ),
    );

    // 鉢植え
    for (final (px, s) in [(0.05, 1.0), (0.6, 0.8), (0.9, 1.1)]) {
      final base = Offset(w * px, h * 0.76);
      canvas.drawRect(
        Rect.fromCenter(
          center: base.translate(0, -h * 0.018 * s),
          width: w * 0.06 * s,
          height: h * 0.036 * s,
        ),
        Paint()..color = const Color(0xFF9A5A3A),
      );
      final leaf = Paint()..color = const Color(0xFF3F6E4A);
      for (var i = 0; i < 5; i++) {
        final a = -1.2 + i * 0.6;
        canvas.drawCircle(
          base.translate(
            math.sin(a) * w * 0.03 * s,
            -h * 0.05 * s - math.cos(a) * h * 0.025 * s,
          ),
          w * 0.022 * s,
          leaf,
        );
      }
    }
    // 黒板スタンド
    final bb = r(0.12, 0.7, 0.22, 0.77);
    canvas.drawRect(bb.inflate(2), Paint()..color = const Color(0xFF6B452A));
    canvas.drawRect(bb, Paint()..color = const Color(0xFF2F3B33));
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(bb.left + 5, bb.top + 8 + i * 8),
        Offset(bb.right - 5 - i * 4, bb.top + 8 + i * 8),
        Paint()
          ..color = const Color(0xAAF3EBDD)
          ..strokeWidth = 1.2,
      );
    }
    // 街灯
    final lampTop = Offset(w * 0.97, h * 0.56);
    canvas.drawLine(
      lampTop,
      Offset(lampTop.dx, h * 0.8),
      Paint()
        ..color = const Color(0xFF15192A)
        ..strokeWidth = 4,
    );
    canvas.drawCircle(lampTop, 7, Paint()..color = const Color(0xFFFFE9B0));
    canvas.drawCircle(
      lampTop,
      w * 0.12,
      Paint()..color = const Color(0x22FFE9B0),
    );
  }

  @override
  bool shouldRepaint(ExteriorPainter old) => false;
}
