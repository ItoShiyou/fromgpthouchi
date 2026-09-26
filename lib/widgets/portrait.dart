import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/art/art_library.dart';
import '../core/brand/handdrawn.dart';
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
  const skins = [0xFFF1D3BA, 0xFFE8C4A6, 0xFFF4DCC8, 0xFFD9B08E];
  final r = math.Random(seed);
  return VisitorLook(
    hair: hairs[r.nextInt(hairs.length)],
    clothes: clothes[r.nextInt(clothes.length)],
    skin: skins[r.nextInt(skins.length)],
    style: HairStyle.values[r.nextInt(HairStyle.values.length)],
    face: FaceShape.values[r.nextInt(FaceShape.values.length)],
    eyes: EyeStyle.values[r.nextInt(EyeStyle.values.length)],
    glasses: r.nextInt(6) == 0,
  );
}

/// 似顔絵のカード。
class Portrait extends StatelessWidget {
  const Portrait({
    super.key,
    this.visitorId,
    required this.look,
    this.size = 56,
    this.locked = false,
    this.background = const Color(0xFFE9DDC8),
  });

  final VisitorLook look;
  final double size;

  /// 本番の似顔絵があればそれを使う（assets/art/…/visitors/{id}.png）。
  final String? visitorId;

  /// 未発見の時はシルエットで描く。
  final bool locked;
  final Color background;

  Widget? get _picture {
    final path = visitorId == null ? null : Art.current.visitor(visitorId!);
    if (path == null) return null;
    final image = Image.asset(
      path,
      fit: BoxFit.contain,
      alignment: Alignment.bottomCenter,
    );
    // 未発見の人は、絵を影の色で塗りつぶしてシルエットにする
    return locked
        ? ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color(0xFFB9A88F),
              BlendMode.srcIn,
            ),
            child: image,
          )
        : image;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: locked
            ? YohakuColors.paperLine.withValues(alpha: 0.6)
            : background,
        shape: portraitBorder(size),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          _picture ??
          CustomPaint(
            painter: PortraitPainter(look: look, silhouette: locked),
          ),
    );
  }
}

RoughBorder portraitBorder(double size) =>
    RoughBorder(radius: size * 0.2, amount: math.max(0.6, size * 0.012));

/// バストアップの人物。インクの輪郭＋淡い塗り。店内の客にも同じものを使う。
class PortraitPainter extends CustomPainter {
  const PortraitPainter({required this.look, this.silhouette = false});

  final VisitorLook look;
  final bool silhouette;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - s) / 2, size.height - s);
    // 人ごとに少しだけ首をかしげる
    final seed = (look.hair ^ look.clothes ^ look.skin).toDouble() % 101;
    final tilt = ((seed % 7) - 3) * 0.018;
    canvas.translate(s * 0.5, s * 0.9);
    canvas.rotate(tilt);
    canvas.translate(-s * 0.5, -s * 0.9);

    Offset p(double x, double y) => Offset(x * s, y * s);
    const inkColor = Color(0xFF3B2C22);
    final lw = math.max(1.0, s * 0.016);
    final wob = math.max(0.5, s * 0.008);
    const shadow = Color(0xFFB9A88F);
    Color c(int v) => silhouette ? shadow : Color(v);
    void fill(Path path, Color color) =>
        canvas.drawPath(path, Paint()..color = color);
    void ink(Path path, {double w = 1}) {
      if (!silhouette) Rough.ink(canvas, path, color: inkColor, width: lw * w);
    }

    final hair = c(look.hair);
    final skin = c(look.skin);
    final clothes = c(look.clothes);

    // 顔の形
    final (fw, fh) = switch (look.face) {
      FaceShape.round => (0.42, 0.42),
      FaceShape.oval => (0.38, 0.44),
      FaceShape.long => (0.35, 0.47),
    };
    final head = p(0.5, 0.42);
    final faceRect = Rect.fromCenter(
      center: head,
      width: fw * s,
      height: fh * s,
    );

    // 後ろ髪
    Path? backHair;
    switch (look.style) {
      case HairStyle.long:
        backHair = Rough.rrect(
          Rect.fromLTRB(
            faceRect.left - s * 0.04,
            faceRect.top - s * 0.02,
            faceRect.right + s * 0.04,
            p(0, 0.8).dy,
          ),
          s * 0.16,
          amount: wob,
          seed: seed,
        );
      case HairStyle.ponytail:
        backHair = Rough.oval(
          Rect.fromCenter(
            center: p(0.75, 0.47),
            width: 0.15 * s,
            height: 0.3 * s,
          ),
          amount: wob,
          seed: seed,
        );
      case HairStyle.bun:
        backHair = Rough.oval(
          Rect.fromCircle(center: p(0.5, 0.16), radius: 0.09 * s),
          amount: wob,
          seed: seed,
        );
      default:
        break;
    }
    if (backHair != null) {
      fill(backHair, hair);
      ink(backHair);
    }

    // 体（肩は左右で少し高さを変える）
    final lean = ((seed % 5) - 2) * 0.01;
    final body = Path()
      ..moveTo(0.1 * s, 1.05 * s)
      ..cubicTo(
        0.12 * s,
        (0.78 - lean) * s,
        0.26 * s,
        (0.72 - lean) * s,
        0.42 * s,
        0.7 * s,
      )
      ..lineTo(0.58 * s, 0.7 * s)
      ..cubicTo(
        0.76 * s,
        (0.72 + lean) * s,
        0.88 * s,
        (0.78 + lean) * s,
        0.9 * s,
        1.05 * s,
      )
      ..close();
    final roughBody = Rough.wobble(body, amount: wob, seed: seed);
    fill(roughBody, clothes);
    // 服のしわ（陰）
    if (!silhouette) {
      canvas.drawPath(
        Rough.line(p(0.3, 0.86), p(0.34, 1.0), seed: seed),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = lw * 2
          ..color = Colors.black.withValues(alpha: 0.12),
      );
    }
    ink(roughBody);

    // 首
    final neck = Rough.rrect(
      Rect.fromLTRB(0.44 * s, faceRect.bottom - s * 0.04, 0.56 * s, 0.73 * s),
      s * 0.02,
      amount: wob * 0.5,
      seed: seed,
    );
    fill(neck, skin);
    if (!silhouette) {
      // 襟
      final collar = Path()
        ..moveTo(0.4 * s, 0.7 * s)
        ..lineTo(0.5 * s, 0.82 * s)
        ..lineTo(0.6 * s, 0.7 * s);
      fill(Path.from(collar)..close(), const Color(0xFFF3ECDF));
      ink(Rough.wobble(collar, amount: wob * 0.6, seed: seed));
      if (look.accent != null) {
        final tie = Rough.wobble(
          Path()
            ..moveTo(0.475 * s, 0.75 * s)
            ..lineTo(0.525 * s, 0.75 * s)
            ..lineTo(0.545 * s, 0.94 * s)
            ..lineTo(0.5 * s, 0.99 * s)
            ..lineTo(0.455 * s, 0.94 * s)
            ..close(),
          amount: wob * 0.5,
          seed: seed,
        );
        fill(tie, Color(look.accent!));
        ink(tie, w: 0.7);
      }
    }

    // 顔
    final face = Rough.oval(faceRect, amount: wob, seed: seed + 3);
    fill(face, skin);
    // 耳
    for (final side in [-1.0, 1.0]) {
      final ear = Rough.oval(
        Rect.fromCenter(
          center: head.translate(side * faceRect.width * 0.5, s * 0.02),
          width: s * 0.05,
          height: s * 0.08,
        ),
        amount: wob * 0.4,
        seed: seed + side,
      );
      fill(ear, skin);
      ink(ear, w: 0.7);
    }
    ink(face);

    // 前髪：頭の上を覆う楕円を、生え際の曲線より上だけ残す
    if (look.style != HairStyle.cap) {
      final gray = look.style == HairStyle.gray;
      final sideY =
          head.dy -
          faceRect.height * (gray ? 0.28 : 0.06) +
          (look.style == HairStyle.bob ? s * 0.05 : 0);
      final hairline = faceRect.top + faceRect.height * (gray ? 0.16 : 0.27);
      final part = ((seed % 3) - 1) * s * 0.04; // 分け目の位置
      final hairlinePath = Path()
        ..moveTo(faceRect.left - s * 0.04, sideY)
        ..quadraticBezierTo(
          faceRect.left + s * 0.05,
          hairline + s * 0.03,
          faceRect.center.dx + part,
          hairline,
        )
        ..quadraticBezierTo(
          faceRect.right - s * 0.05,
          hairline + s * 0.04,
          faceRect.right + s * 0.04,
          sideY,
        );
      final clip = Path()
        ..moveTo(0, -s)
        ..lineTo(s, -s)
        ..lineTo(s, sideY)
        ..lineTo(faceRect.right + s * 0.04, sideY)
        ..quadraticBezierTo(
          faceRect.right - s * 0.05,
          hairline + s * 0.04,
          faceRect.center.dx + part,
          hairline,
        )
        ..quadraticBezierTo(
          faceRect.left + s * 0.05,
          hairline + s * 0.03,
          faceRect.left - s * 0.04,
          sideY,
        )
        ..lineTo(0, sideY)
        ..close();
      final cap = Rough.oval(
        faceRect.inflate(s * 0.03),
        amount: wob,
        seed: seed + 5,
      );
      canvas.save();
      canvas.clipPath(clip);
      fill(cap, hair);
      ink(cap);
      canvas.restore();
      ink(Rough.wobble(hairlinePath, amount: wob * 0.6, seed: seed));
      // 髪の筋
      if (!silhouette) {
        for (var i = 0; i < 3; i++) {
          final x = faceRect.left + faceRect.width * (0.3 + i * 0.2);
          canvas.drawPath(
            Rough.line(
              Offset(x, faceRect.top),
              Offset(x + s * 0.02, hairline - s * 0.01),
              seed: seed + i,
            ),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = lw * 0.6
              ..color = Colors.black.withValues(alpha: 0.25),
          );
        }
      }
      if (look.style == HairStyle.bob || look.style == HairStyle.long) {
        for (final side in [-1.0, 1.0]) {
          final lock = Rough.rrect(
            Rect.fromCenter(
              center: Offset(
                head.dx + side * faceRect.width * 0.48,
                head.dy + s * 0.05,
              ),
              width: s * 0.07,
              height:
                  faceRect.height * (look.style == HairStyle.bob ? 0.6 : 0.85),
            ),
            s * 0.03,
            amount: wob * 0.6,
            seed: seed + side,
          );
          fill(lock, hair);
          ink(lock, w: 0.8);
        }
      }
    } else {
      final cap = Path()
        ..addArc(
          Rect.fromCenter(
            center: head.translate(0, -s * 0.04),
            width: faceRect.width * 1.1,
            height: faceRect.height * 0.9,
          ),
          math.pi,
          math.pi,
        )
        ..lineTo(head.dx + faceRect.width * 0.75, head.dy - s * 0.04)
        ..lineTo(head.dx - faceRect.width * 0.55, head.dy - s * 0.04)
        ..close();
      final rc = Rough.wobble(cap, amount: wob, seed: seed);
      fill(rc, c(0xFF3E4A5E));
      ink(rc);
    }

    if (silhouette) {
      canvas.restore();
      return;
    }

    // 目・眉・鼻・口
    final eyeY = head.dy + faceRect.height * 0.08;
    final gap = faceRect.width * 0.22;
    final eyePaint = Paint()..color = inkColor;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lw * 1.1
      ..color = inkColor;
    for (final side in [-1.0, 1.0]) {
      final e = Offset(head.dx + side * gap, eyeY);
      switch (look.eyes) {
        case EyeStyle.dot:
          canvas.drawOval(
            Rect.fromCenter(center: e, width: s * 0.03, height: s * 0.04),
            eyePaint,
          );
        case EyeStyle.line:
          canvas.drawLine(
            e.translate(-s * 0.025, 0),
            e.translate(s * 0.025, side * s * 0.003),
            stroke,
          );
        case EyeStyle.sleepy:
          canvas.drawArc(
            Rect.fromCenter(center: e, width: s * 0.05, height: s * 0.03),
            0.2,
            math.pi - 0.4,
            false,
            stroke,
          );
        case EyeStyle.round:
          canvas.drawCircle(e, s * 0.025, eyePaint);
          canvas.drawCircle(
            e.translate(-s * 0.007, -s * 0.008),
            s * 0.007,
            Paint()..color = Colors.white,
          );
      }
      // 眉（左右で角度を少し変える）
      final browY = eyeY - faceRect.height * 0.14;
      final slant = ((seed + side * 3) % 5 - 2) * 0.004 * s;
      canvas.drawLine(
        Offset(e.dx - s * 0.03, browY + slant),
        Offset(e.dx + s * 0.03, browY - slant),
        stroke..strokeWidth = lw * 0.9,
      );
    }
    // 鼻
    canvas.drawPath(
      Path()
        ..moveTo(head.dx + s * 0.005, eyeY + s * 0.02)
        ..quadraticBezierTo(
          head.dx - s * 0.012,
          eyeY + s * 0.055,
          head.dx + s * 0.01,
          eyeY + s * 0.06,
        ),
      stroke..strokeWidth = lw * 0.7,
    );
    // 口（人ごとに幅と向きを変える）
    final mouthY = eyeY + faceRect.height * 0.28;
    final mw = s * (0.035 + (seed % 3) * 0.01);
    final curve = ((seed % 4) - 1) * s * 0.006;
    canvas.drawPath(
      Path()
        ..moveTo(head.dx - mw, mouthY)
        ..quadraticBezierTo(
          head.dx,
          mouthY + curve,
          head.dx + mw,
          mouthY - s * 0.003,
        ),
      stroke
        ..strokeWidth = lw * 0.9
        ..color = const Color(0xFF7A3E34),
    );
    if (look.blush) {
      final b = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lw * 0.6
        ..color = const Color(0xAAC4574E);
      for (final side in [-1.0, 1.0]) {
        for (var i = 0; i < 3; i++) {
          final o = Offset(
            head.dx + side * gap * 1.25 + i * s * 0.012,
            eyeY + s * 0.045,
          );
          canvas.drawLine(o, o.translate(-s * 0.01, s * 0.015), b);
        }
      }
    }
    if (look.glasses) {
      final g = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lw
        ..color = inkColor;
      for (final side in [-1.0, 1.0]) {
        canvas.drawPath(
          Rough.oval(
            Rect.fromCircle(
              center: Offset(head.dx + side * gap, eyeY),
              radius: s * 0.045,
            ),
            amount: wob * 0.4,
            seed: seed + side,
          ),
          g,
        );
      }
      canvas.drawLine(
        Offset(head.dx - gap + s * 0.045, eyeY),
        Offset(head.dx + gap - s * 0.045, eyeY),
        g,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PortraitPainter old) =>
      old.look != look || old.silhouette != silhouette;
}
