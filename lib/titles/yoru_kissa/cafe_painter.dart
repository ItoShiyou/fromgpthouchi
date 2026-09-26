import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/brand/handdrawn.dart';
import '../../core/models/content.dart';
import '../../core/models/world.dart';

/// 喫茶店の一枚絵を「レイヤーの重ね合わせ」で描く。
///
/// ```text
/// 背景（壁・床）
/// ＋ 窓（空・天気）
/// ＋ 家具レイヤー（スロットごと）
/// ＋ 照明（時間帯の暗さ＋灯りのにじみ）
/// ＋ 演出（湯気・雨粒）
/// ```
/// 客はこの上に Widget として重ねる（タップさせるため）。
/// 本番ではここを PNG レイヤーに差し替えるだけで、構造はそのまま使える。
class CafePainter extends CustomPainter {
  CafePainter({
    required this.moment,
    required this.placement,
    required this.effects,
    required this.animation,
  }) : super(repaint: animation);

  final WorldMoment moment;
  final Map<PlacementSlot, String> placement;
  final Set<String> effects;
  final Animation<double> animation;

  // 客・カウンターの配置（Widget 側と共有する）。
  static const windowRect = Rect.fromLTRB(0.06, 0.08, 0.46, 0.44);
  static const floorTop = 0.66;
  static const counterRect = Rect.fromLTRB(0.66, 0.54, 1.0, 0.84);
  static const guestAnchors = [
    Offset(0.16, 0.50), // ソファ
    Offset(0.47, 0.54), // テーブルの向かい
    Offset(0.80, 0.40), // カウンター
  ];

  bool get _dark =>
      moment.slot == TimeSlot.night ||
      moment.slot == TimeSlot.lateNight ||
      moment.slot == TimeSlot.closed;

  String? _at(PlacementSlot s) => placement[s];

  /// 縦長の画面では、部屋（4:5）の上に天井、下に床を足して全面に描く。
  static double roomHeight(Size size) =>
      math.min(size.height, size.width * 1.25);
  static double roomTop(Size size) => (size.height - roomHeight(size)) * 0.42;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final rs = Size(w, roomHeight(size));
    final top = roomTop(size);
    Rect r(Rect f) => Rect.fromLTRB(
      f.left * w,
      f.top * rs.height,
      f.right * w,
      f.bottom * rs.height,
    );
    final t = animation.value;

    _paintExtensions(canvas, size, top, rs.height);
    canvas.save();
    canvas.translate(0, top);
    _paintRoom(canvas, rs);
    _paintWindow(canvas, r(windowRect), t);
    _paintWallItem(canvas, rs, t);
    _paintCorner(canvas, rs);
    _paintSeat(canvas, rs);
    _paintTable(canvas, rs, t);
    _paintCounter(canvas, r(counterRect), rs);
    _paintLight(canvas, rs);
    _paintCat(canvas, rs, t);
    _paintLinework(canvas, rs, r);
    _paintLighting(canvas, rs, top, size.height);
    canvas.restore();
  }

  /// 天井（梁・吊りランプ・黒板メニュー）と、手前の床。
  void _paintExtensions(Canvas canvas, Size size, double top, double roomH) {
    final w = size.width;
    if (top > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, top + 1),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFCDB894), Color(0xFFE9DCC4)],
          ).createShader(Rect.fromLTWH(0, 0, w, top + 1)),
      );
      final ceiling = top * 0.28;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, ceiling),
        Paint()..color = const Color(0xFF4A2F1C),
      );
      final beam = Paint()..color = const Color(0xFF3A2414);
      canvas.drawRect(Rect.fromLTWH(0, ceiling - 6, w, 8), beam);
      for (var i = 0; i < 5; i++) {
        canvas.drawRect(
          Rect.fromLTWH(w * (0.1 + i * 0.2) - 4, 0, 8, ceiling),
          beam,
        );
      }
      // 吊りランプ
      for (final x in [0.16, 0.84]) {
        final end = Offset(w * x, top * 0.62);
        canvas.drawLine(
          Offset(end.dx, ceiling),
          end,
          Paint()
            ..color = const Color(0xFF2B2A33)
            ..strokeWidth = 1.2,
        );
        final shade = Path()
          ..moveTo(end.dx - w * 0.06, end.dy + w * 0.05)
          ..quadraticBezierTo(
            end.dx,
            end.dy - w * 0.035,
            end.dx + w * 0.06,
            end.dy + w * 0.05,
          )
          ..close();
        canvas.drawPath(shade, Paint()..color = const Color(0xFF2F4A3A));
        canvas.drawCircle(
          end.translate(0, w * 0.05),
          w * 0.018,
          Paint()..color = const Color(0xFFFFE3B0),
        );
      }
      // 黒板メニュー
      final board = Rect.fromLTWH(w * 0.34, top * 0.4, w * 0.32, top * 0.52);
      if (board.height > 40) {
        canvas.drawLine(
          Offset(board.left + 8, ceiling),
          board.topLeft.translate(8, 0),
          Paint()..color = const Color(0xFF6B452A),
        );
        canvas.drawLine(
          Offset(board.right - 8, ceiling),
          board.topRight.translate(-8, 0),
          Paint()..color = const Color(0xFF6B452A),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(board.inflate(4), const Radius.circular(4)),
          Paint()..color = const Color(0xFF6B452A),
        );
        canvas.drawRect(board, Paint()..color = const Color(0xFF2F3B33));
        final tp = TextPainter(
          text: TextSpan(
            style: TextStyle(
              fontSize: board.height * 0.13,
              color: const Color(0xDDF3EBDD),
              height: 1.35,
            ),
            children: const [
              TextSpan(
                text: 'MENU\n',
                style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 2),
              ),
              TextSpan(text: 'コーヒー 450\nプリン 400\nパスタ 850'),
            ],
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: board.width);
        tp.paint(
          canvas,
          Offset(
            board.center.dx - tp.width / 2,
            board.center.dy - tp.height / 2,
          ),
        );
      }
      // 部屋の天井電球のコード
      canvas.drawLine(
        Offset(w * 0.5, ceiling),
        Offset(w * 0.5, top),
        Paint()
          ..color = const Color(0xFF2B2A33)
          ..strokeWidth = 1.2,
      );
    }
    final bottom = top + roomH;
    if (bottom < size.height) {
      final floor = Rect.fromLTRB(0, bottom - 1, w, size.height);
      canvas.drawRect(floor, Paint()..color = const Color(0xFF6E4A33));
      final plank = Paint()
        ..color = const Color(0xFF5C3D2A)
        ..strokeWidth = 1.2;
      for (var y = bottom + 24.0; y < size.height; y += 26) {
        canvas.drawLine(Offset(0, y), Offset(w, y), plank);
      }
    }
  }

  /// 塗りの上に、手で引いたインクの輪郭を重ねる。
  /// 塗りだけのベクター画は「作られた絵」に見えるので、線で絵にする。
  void _paintLinework(Canvas canvas, Size s, Rect Function(Rect) r) {
    final w = s.width, h = s.height;
    const ink = Color(0xFF3B2C22);
    void line(Path p, {double width = 1.3, double opacity = 0.75}) =>
        Rough.ink(canvas, p, color: ink, width: width, opacity: opacity);
    Path rect(Rect x, [double radius = 2]) =>
        Rough.rrect(x, radius, amount: 1.0);

    // 壁と床の境目・腰壁
    line(
      Rough.line(Offset(0, h * 0.515), Offset(w, h * 0.515), amount: 1.2),
      opacity: 0.5,
    );
    line(
      Rough.line(Offset(0, h * floorTop), Offset(w, h * floorTop), amount: 1.2),
      opacity: 0.5,
    );

    // 窓
    final win = r(windowRect);
    line(rect(win.inflate(win.width * 0.035), 4), width: 1.6);
    line(rect(win), opacity: 0.5);

    // 壁のもの
    switch (_at(PlacementSlot.wall)) {
      case 'pendulum_clock':
        final body = Rect.fromLTWH(w * 0.60, h * 0.08, w * 0.12, h * 0.36);
        line(rect(body, 6));
        line(
          Rough.oval(
            Rect.fromCircle(
              center: Offset(body.center.dx, body.top + body.width * 0.62),
              radius: body.width * 0.36,
            ),
          ),
          width: 1.1,
        );
      case 'bookshelf':
        line(rect(Rect.fromLTWH(w * 0.54, h * 0.08, w * 0.38, h * 0.36)));
      case 'old_poster':
        line(rect(Rect.fromLTWH(w * 0.62, h * 0.08, w * 0.22, h * 0.3)));
      case 'photo_frame':
        line(rect(Rect.fromLTWH(w * 0.64, h * 0.12, w * 0.2, h * 0.16)));
    }

    // 席
    if (_at(PlacementSlot.seat) != null) {
      line(
        rect(Rect.fromLTWH(w * 0.03, h * 0.54, w * 0.34, h * 0.14), 10),
        width: 1.5,
      );
      line(
        rect(Rect.fromLTWH(w * 0.02, h * 0.64, w * 0.36, h * 0.09), 8),
        width: 1.5,
      );
    }

    // テーブル
    if (_at(PlacementSlot.table) != null) {
      line(
        Rough.oval(
          Rect.fromCenter(
            center: Offset(w * 0.47, h * 0.72),
            width: w * 0.24,
            height: h * 0.05,
          ),
        ),
        width: 1.5,
      );
      line(
        Rough.line(Offset(w * 0.463, h * 0.745), Offset(w * 0.463, h * 0.86)),
        opacity: 0.6,
      );
      line(
        Rough.line(Offset(w * 0.477, h * 0.745), Offset(w * 0.477, h * 0.86)),
        opacity: 0.6,
      );
    }

    // 隅
    final base = Offset(w * 0.585, h * 0.80);
    switch (_at(PlacementSlot.corner)) {
      case 'monstera':
        line(
          rect(
            Rect.fromCenter(
              center: base.translate(0, -h * 0.04),
              width: w * 0.08,
              height: h * 0.08,
            ),
          ),
        );
      case 'record_player':
        line(
          rect(
            Rect.fromLTWH(
              base.dx - w * 0.07,
              base.dy - h * 0.14,
              w * 0.14,
              h * 0.14,
            ),
          ),
        );
    }

    // カウンターとスツール
    final c = r(counterRect);
    line(rect(c), width: 1.6);
    line(
      rect(
        Rect.fromLTWH(
          c.left - w * 0.02,
          c.top - h * 0.02,
          c.width + w * 0.02,
          h * 0.025,
        ),
      ),
      width: 1.2,
    );
    for (final x in [0.74, 0.88]) {
      line(
        Rough.oval(
          Rect.fromCenter(
            center: Offset(w * x + w * 0.006, c.bottom),
            width: w * 0.08,
            height: h * 0.02,
          ),
        ),
        width: 1.1,
      );
    }
    // 板のすじ（床）
    for (var i = 0; i < 6; i++) {
      final y = h * (floorTop + 0.05 + i * 0.055);
      final x0 = w * ((i * 0.37) % 1.0);
      line(
        Rough.line(Offset(x0, y), Offset(x0 + w * 0.12, y + 0.5)),
        width: 0.8,
        opacity: 0.35,
      );
    }
  }

  /// 店の猫。いつも同じあたりで寝ている。
  void _paintCat(Canvas canvas, Size s, double t) {
    final w = s.width, h = s.height;
    final c = Offset(w * 0.64, h * 0.935);
    final breathe = 1 + math.sin(t * math.pi * 2 * 3) * 0.03;
    final fur = Paint()..color = const Color(0xFFE2A25E);
    final dark = Paint()..color = const Color(0xFFB9763A);
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.scale(1, breathe);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.05),
      fur,
    );
    for (var i = -1; i <= 1; i++) {
      canvas.drawLine(
        Offset(i * w * 0.025, -h * 0.022),
        Offset(i * w * 0.025 + w * 0.008, h * 0.005),
        dark..strokeWidth = 2,
      );
    }
    canvas.restore();
    // しっぽ
    canvas.drawArc(
      Rect.fromCenter(
        center: c.translate(-w * 0.07, h * 0.008),
        width: w * 0.08,
        height: h * 0.04,
      ),
      math.pi * 0.2,
      math.pi * 1.1,
      false,
      Paint()
        ..color = const Color(0xFFE2A25E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.014
        ..strokeCap = StrokeCap.round,
    );
    // 頭
    final head = c.translate(w * 0.075, -h * 0.008);
    for (final side in [-1.0, 1.0]) {
      final ear = Path()
        ..moveTo(head.dx + side * w * 0.03, head.dy - h * 0.008)
        ..lineTo(head.dx + side * w * 0.022, head.dy - h * 0.034)
        ..lineTo(head.dx + side * w * 0.005, head.dy - h * 0.018)
        ..close();
      canvas.drawPath(ear, fur);
    }
    canvas.drawOval(
      Rect.fromCenter(center: head, width: w * 0.07, height: h * 0.04),
      fur,
    );
    final eye = Paint()
      ..color = const Color(0xFF5A3A22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final side in [-1.0, 1.0]) {
      canvas.drawArc(
        Rect.fromCenter(
          center: head.translate(side * w * 0.013, 0),
          width: w * 0.014,
          height: h * 0.008,
        ),
        0,
        math.pi,
        false,
        eye,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 背景
  // ---------------------------------------------------------------------------

  void _paintRoom(Canvas canvas, Size s) {
    final wallRect = Rect.fromLTWH(0, 0, s.width, s.height * floorTop);
    canvas.drawRect(
      wallRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE9DCC4), Color(0xFFD8C6A6)],
        ).createShader(wallRect),
    );
    // 腰壁
    final wainscot = Rect.fromLTWH(
      0,
      s.height * 0.52,
      s.width,
      s.height * (floorTop - 0.52),
    );
    canvas.drawRect(wainscot, Paint()..color = const Color(0xFF8A5E3C));
    canvas.drawRect(
      Rect.fromLTWH(0, s.height * 0.515, s.width, s.height * 0.012),
      Paint()..color = const Color(0xFF6B452A),
    );
    // 床
    final floor = Rect.fromLTWH(
      0,
      s.height * floorTop,
      s.width,
      s.height * (1 - floorTop),
    );
    canvas.drawRect(floor, Paint()..color = const Color(0xFF6E4A33));
    final plank = Paint()
      ..color = const Color(0xFF5C3D2A)
      ..strokeWidth = 1.2;
    for (var i = 1; i < 6; i++) {
      final y = s.height * floorTop + floor.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(s.width, y), plank);
    }
  }

  // ---------------------------------------------------------------------------
  // 窓（空・天気）
  // ---------------------------------------------------------------------------

  (Color, Color) _sky() {
    var (top, bottom) = switch (moment.slot) {
      TimeSlot.morning => (const Color(0xFF9EC5E0), const Color(0xFFF6E3C4)),
      TimeSlot.noon => (const Color(0xFF7FB6E6), const Color(0xFFCFE6F5)),
      TimeSlot.evening => (const Color(0xFF3E4A7A), const Color(0xFFF0A36B)),
      TimeSlot.night => (const Color(0xFF0E1330), const Color(0xFF2B2F55)),
      _ => (const Color(0xFF05070F), const Color(0xFF141833)),
    };
    if (moment.weather != Weather.sunny) {
      final gray = moment.weather == Weather.cloudy ? 0.35 : 0.55;
      final g = _dark ? const Color(0xFF1C1F28) : const Color(0xFF8E96A0);
      top = Color.lerp(top, g, gray)!;
      bottom = Color.lerp(bottom, g, gray)!;
    }
    return (top, bottom);
  }

  void _paintWindow(Canvas canvas, Rect win, double t) {
    final moonWindow = _at(PlacementSlot.window) == 'moon_window';
    // 枠
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        win.inflate(win.width * 0.035),
        const Radius.circular(4),
      ),
      Paint()
        ..color = moonWindow
            ? const Color(0xFF3B3350)
            : const Color(0xFF5A3B25),
    );
    canvas.save();
    canvas.clipRect(win);
    final (top, bottom) = _sky();
    canvas.drawRect(
      win,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(win),
    );

    // 向かいの家並み（シルエット）
    final city = Path()..moveTo(win.left, win.bottom);
    final rnd = math.Random(7);
    var x = win.left;
    while (x < win.right) {
      final bw = win.width * (0.12 + rnd.nextDouble() * 0.12);
      final bh = win.height * (0.18 + rnd.nextDouble() * 0.22);
      city
        ..lineTo(x, win.bottom - bh)
        ..lineTo(x + bw, win.bottom - bh);
      x += bw;
    }
    city
      ..lineTo(win.right, win.bottom)
      ..close();
    canvas.drawPath(
      city,
      Paint()
        ..color = _dark ? const Color(0xFF0A0C16) : const Color(0x553A4252),
    );
    if (_dark) {
      // 窓明かり
      final lit = Paint()..color = const Color(0xFFF2C979);
      final r2 = math.Random(11);
      for (var i = 0; i < 9; i++) {
        final lx = win.left + win.width * r2.nextDouble();
        final ly = win.bottom - win.height * (0.05 + r2.nextDouble() * 0.15);
        canvas.drawRect(
          Rect.fromLTWH(lx, ly, win.width * 0.025, win.height * 0.03),
          lit,
        );
      }
    }

    // 月
    final showMoon =
        moonWindow ||
        (_dark &&
            (moment.weather == Weather.sunny ||
                moment.weather == Weather.cloudy));
    if (showMoon) {
      final c = Offset(
        win.left + win.width * 0.72,
        win.top + win.height * 0.26,
      );
      final rad = win.width * (moonWindow ? 0.11 : 0.07);
      canvas.drawCircle(c, rad * 2.2, Paint()..color = const Color(0x22FFF3C4));
      canvas.drawCircle(c, rad, Paint()..color = const Color(0xFFFFF3C4));
      if (moonWindow) {
        final star = Paint()..color = const Color(0xCCFFFFFF);
        for (final p in const [
          Offset(0.2, 0.2),
          Offset(0.35, 0.12),
          Offset(0.5, 0.3),
          Offset(0.15, 0.42),
        ]) {
          canvas.drawCircle(
            Offset(win.left + win.width * p.dx, win.top + win.height * p.dy),
            win.width * 0.008,
            star,
          );
        }
      }
    }

    // 天気
    switch (moment.weather) {
      case Weather.cloudy:
        _clouds(canvas, win, t, const Color(0x66FFFFFF));
      case Weather.rain:
      case Weather.shower:
        _clouds(canvas, win, t, const Color(0x55A0A8B4));
        _rain(canvas, win, t, heavy: moment.weather == Weather.shower);
      case Weather.snow:
        _snow(canvas, win, t);
      case Weather.sunny:
        break;
    }
    if (effects.contains('fx_window_rain') || moment.weather.isWet) {
      _droplets(canvas, win);
    }
    canvas.restore();

    // 桟
    final bar = Paint()
      ..color = moonWindow ? const Color(0xFF3B3350) : const Color(0xFF5A3B25)
      ..strokeWidth = win.width * 0.02;
    canvas.drawLine(
      Offset(win.center.dx, win.top),
      Offset(win.center.dx, win.bottom),
      bar,
    );
    canvas.drawLine(
      Offset(win.left, win.center.dy),
      Offset(win.right, win.center.dy),
      bar,
    );

    // カーテン
    if (_at(PlacementSlot.window) == 'lace_curtain') {
      final lace = Paint()..color = const Color(0xB3FFFFFF);
      for (final left in [true, false]) {
        final path = Path();
        final x0 = left ? win.left - 4 : win.right + 4;
        final x1 = left
            ? win.left + win.width * 0.16
            : win.right - win.width * 0.16;
        path
          ..moveTo(x0, win.top - 6)
          ..lineTo(x1, win.top - 6)
          ..quadraticBezierTo(
            left ? x1 - win.width * 0.08 : x1 + win.width * 0.08,
            win.center.dy,
            x1 + (left ? -win.width * 0.02 : win.width * 0.02),
            win.bottom + 4,
          )
          ..lineTo(x0, win.bottom + 4)
          ..close();
        canvas.drawPath(path, lace);
      }
    }
    // 窓台
    canvas.drawRect(
      Rect.fromLTWH(
        win.left - win.width * 0.06,
        win.bottom + win.width * 0.03,
        win.width * 1.12,
        win.height * 0.04,
      ),
      Paint()..color = const Color(0xFF6B452A),
    );
  }

  void _clouds(Canvas canvas, Rect win, double t, Color color) {
    final p = Paint()..color = color;
    for (var i = 0; i < 3; i++) {
      final dx = ((t * 0.3 + i * 0.37) % 1.2 - 0.1) * win.width;
      final c = Offset(win.left + dx, win.top + win.height * (0.15 + i * 0.12));
      canvas.drawOval(
        Rect.fromCenter(
          center: c,
          width: win.width * 0.4,
          height: win.height * 0.1,
        ),
        p,
      );
    }
  }

  void _rain(Canvas canvas, Rect win, double t, {required bool heavy}) {
    final p = Paint()
      ..color = const Color(0x99D6E2F0)
      ..strokeWidth = heavy ? 1.6 : 1.1;
    final n = heavy ? 60 : 36;
    final rnd = math.Random(3);
    for (var i = 0; i < n; i++) {
      final x = win.left + win.width * rnd.nextDouble();
      final phase = rnd.nextDouble();
      final y = win.top + ((t * (heavy ? 6 : 4) + phase) % 1.0) * win.height;
      final len = win.height * (heavy ? 0.09 : 0.06);
      canvas.drawLine(Offset(x, y), Offset(x - len * 0.25, y + len), p);
    }
  }

  void _snow(Canvas canvas, Rect win, double t) {
    final p = Paint()..color = const Color(0xDDFFFFFF);
    final rnd = math.Random(5);
    for (var i = 0; i < 40; i++) {
      final phase = rnd.nextDouble();
      final x0 = win.left + win.width * rnd.nextDouble();
      final y = win.top + ((t * 1.2 + phase) % 1.0) * win.height;
      final x = x0 + math.sin((t + phase) * math.pi * 4) * win.width * 0.02;
      canvas.drawCircle(Offset(x, y), 1.2 + rnd.nextDouble() * 1.6, p);
    }
  }

  void _droplets(Canvas canvas, Rect win) {
    final p = Paint()..color = const Color(0x66FFFFFF);
    final rnd = math.Random(9);
    for (var i = 0; i < 18; i++) {
      final c = Offset(
        win.left + win.width * rnd.nextDouble(),
        win.top + win.height * rnd.nextDouble(),
      );
      canvas.drawOval(Rect.fromCenter(center: c, width: 3, height: 4.5), p);
    }
  }

  // ---------------------------------------------------------------------------
  // 家具レイヤー
  // ---------------------------------------------------------------------------

  void _paintWallItem(Canvas canvas, Size s, double t) {
    final id = _at(PlacementSlot.wall);
    if (id == null) return;
    final w = s.width, h = s.height;
    switch (id) {
      case 'pendulum_clock':
        final body = Rect.fromLTWH(w * 0.60, h * 0.08, w * 0.12, h * 0.36);
        canvas.drawRRect(
          RRect.fromRectAndRadius(body, const Radius.circular(6)),
          Paint()..color = const Color(0xFF5A3620),
        );
        final face = Offset(body.center.dx, body.top + body.width * 0.62);
        canvas.drawCircle(
          face,
          body.width * 0.36,
          Paint()..color = const Color(0xFFF3E9D2),
        );
        final hand = Paint()
          ..color = const Color(0xFF2B2A33)
          ..strokeWidth = 1.6;
        canvas.drawLine(face, face + Offset(0, -body.width * 0.26), hand);
        canvas.drawLine(face, face + Offset(body.width * 0.18, 0), hand);
        final swing = math.sin(t * math.pi * 2 * 4) * 0.35;
        final pivot = Offset(body.center.dx, body.top + body.height * 0.45);
        final bob =
            pivot +
            Offset(
              math.sin(swing) * body.height * 0.4,
              math.cos(swing) * body.height * 0.4,
            );
        canvas.drawLine(
          pivot,
          bob,
          Paint()
            ..color = const Color(0xFFC9A04F)
            ..strokeWidth = 1.4,
        );
        canvas.drawCircle(
          bob,
          body.width * 0.12,
          Paint()..color = const Color(0xFFC9A04F),
        );
      case 'bookshelf':
        final shelf = Rect.fromLTWH(w * 0.54, h * 0.08, w * 0.38, h * 0.36);
        canvas.drawRect(shelf, Paint()..color = const Color(0xFF6B452A));
        const spines = [
          Color(0xFF8C3B3B),
          Color(0xFF3B5A8C),
          Color(0xFFC9A04F),
          Color(0xFF4F7A5A),
          Color(0xFFD8C6A6),
          Color(0xFF5A3B6B),
        ];
        final rnd = math.Random(2);
        for (var row = 0; row < 3; row++) {
          final y0 = shelf.top + shelf.height * (0.05 + row * 0.32);
          var x = shelf.left + shelf.width * 0.04;
          while (x < shelf.right - shelf.width * 0.08) {
            final bw = shelf.width * (0.035 + rnd.nextDouble() * 0.03);
            final bh = shelf.height * (0.2 + rnd.nextDouble() * 0.07);
            canvas.drawRect(
              Rect.fromLTWH(x, y0 + shelf.height * 0.27 - bh, bw, bh),
              Paint()..color = spines[rnd.nextInt(spines.length)],
            );
            x += bw + 1;
          }
          canvas.drawRect(
            Rect.fromLTWH(
              shelf.left,
              y0 + shelf.height * 0.27,
              shelf.width,
              shelf.height * 0.025,
            ),
            Paint()..color = const Color(0xFF4A2F1C),
          );
        }
      case 'neon_sign':
        final c = Offset(w * 0.74, h * 0.2);
        final on =
            !(moment.slot == TimeSlot.morning || moment.slot == TimeSlot.noon);
        final flick = on && (t * 8 % 1.0) > 0.12;
        _neonText(
          canvas,
          'COFFEE',
          c,
          w * 0.07,
          on ? const Color(0xFFFF7FB0) : const Color(0xFF9B6E80),
          glow: on,
        );
        _neonText(
          canvas,
          'NIGHT',
          c + Offset(0, w * 0.1),
          w * 0.05,
          flick ? const Color(0xFF7FE3FF) : const Color(0xFF557A88),
          glow: flick,
        );
      case 'old_poster':
        final poster = Rect.fromLTWH(w * 0.62, h * 0.08, w * 0.22, h * 0.3);
        canvas.drawRect(poster, Paint()..color = const Color(0xFFE2C48F));
        canvas.drawRect(
          poster.deflate(poster.width * 0.08),
          Paint()..color = const Color(0xFF3A5068),
        );
        canvas.drawCircle(
          poster.center.translate(0, -poster.height * 0.08),
          poster.width * 0.18,
          Paint()..color = const Color(0xFFD98C84),
        );
      case 'photo_frame':
        final frame = Rect.fromLTWH(w * 0.64, h * 0.12, w * 0.2, h * 0.16);
        canvas.drawRect(frame, Paint()..color = const Color(0xFF3A2A1C));
        canvas.drawRect(
          frame.deflate(4),
          Paint()..color = const Color(0xFFBFB6A5),
        );
        for (var i = 0; i < 3; i++) {
          final c = Offset(
            frame.left + frame.width * (0.3 + i * 0.2),
            frame.center.dy + 3,
          );
          canvas.drawCircle(
            c.translate(0, -frame.height * 0.16),
            frame.width * 0.06,
            Paint()..color = const Color(0xFF6B5E52),
          );
          canvas.drawRect(
            Rect.fromCenter(
              center: c.translate(0, frame.height * 0.08),
              width: frame.width * 0.14,
              height: frame.height * 0.3,
            ),
            Paint()..color = const Color(0xFF6B5E52),
          );
        }
    }
  }

  void _neonText(
    Canvas canvas,
    String text,
    Offset center,
    double size,
    Color color, {
    required bool glow,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          letterSpacing: size * 0.2,
          color: color,
          shadows: glow
              ? [
                  Shadow(color: color, blurRadius: 12),
                  Shadow(color: color, blurRadius: 4),
                ]
              : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _paintCorner(Canvas canvas, Size s) {
    final id = _at(PlacementSlot.corner);
    if (id == null) return;
    final w = s.width, h = s.height;
    final base = Offset(w * 0.585, h * 0.80);
    switch (id) {
      case 'monstera':
        canvas.drawRect(
          Rect.fromCenter(
            center: base.translate(0, -h * 0.04),
            width: w * 0.08,
            height: h * 0.08,
          ),
          Paint()..color = const Color(0xFFB0643C),
        );
        final leaf = Paint()..color = const Color(0xFF3F6E4A);
        for (final a in [-1.1, -0.5, 0.0, 0.5, 1.1]) {
          final tip = base.translate(
            math.sin(a) * w * 0.1,
            -h * 0.08 - math.cos(a) * h * 0.14,
          );
          canvas.save();
          canvas.translate(tip.dx, tip.dy);
          canvas.rotate(a);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: w * 0.08,
              height: h * 0.07,
            ),
            leaf,
          );
          canvas.restore();
        }
      case 'record_player':
        final cab = Rect.fromLTWH(
          base.dx - w * 0.07,
          base.dy - h * 0.14,
          w * 0.14,
          h * 0.14,
        );
        canvas.drawRect(cab, Paint()..color = const Color(0xFF5A3620));
        canvas.drawRect(
          Rect.fromLTWH(
            cab.left - 2,
            cab.top - h * 0.02,
            cab.width + 4,
            h * 0.02,
          ),
          Paint()..color = const Color(0xFF3A2414),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cab.center.dx, cab.top - h * 0.012),
            width: cab.width * 0.8,
            height: h * 0.018,
          ),
          Paint()..color = const Color(0xFF111111),
        );
      case 'jukebox':
        final body = RRect.fromRectAndCorners(
          Rect.fromLTWH(
            base.dx - w * 0.075,
            base.dy - h * 0.24,
            w * 0.15,
            h * 0.24,
          ),
          topLeft: Radius.circular(w * 0.075),
          topRight: Radius.circular(w * 0.075),
        );
        canvas.drawRRect(body, Paint()..color = const Color(0xFF8C2F2F));
        canvas.drawRRect(
          body.deflate(w * 0.015),
          Paint()
            ..color = const Color(0xFFF2C979)
                .withValues(alpha: _dark ? 0.9 : 0.6),
        );
        canvas.drawRect(
          Rect.fromLTWH(
            base.dx - w * 0.05,
            base.dy - h * 0.1,
            w * 0.1,
            h * 0.06,
          ),
          Paint()..color = const Color(0xFF3A2414),
        );
      case 'umbrella_stand':
      case 'red_umbrella':
        canvas.drawRect(
          Rect.fromLTWH(
            base.dx - w * 0.035,
            base.dy - h * 0.08,
            w * 0.07,
            h * 0.08,
          ),
          Paint()..color = const Color(0xFF4A5560),
        );
        final color = id == 'red_umbrella'
            ? const Color(0xFFC0392B)
            : const Color(0xFF2C3E50);
        canvas.drawLine(
          base.translate(0, -h * 0.07),
          base.translate(w * 0.01, -h * 0.2),
          Paint()
            ..color = color
            ..strokeWidth = w * 0.022
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: base.translate(w * 0.01, -h * 0.205),
            width: w * 0.03,
            height: h * 0.02,
          ),
          math.pi,
          math.pi,
          false,
          Paint()
            ..color = const Color(0xFF3A2414)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }
  }

  void _paintSeat(Canvas canvas, Size s) {
    final id = _at(PlacementSlot.seat);
    if (id == null) return;
    final w = s.width, h = s.height;
    final color = id == 'red_sofa'
        ? const Color(0xFF9E2F35)
        : const Color(0xFF4F7A5A);
    final dark = Color.lerp(color, Colors.black, 0.3)!;
    final back = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.03, h * 0.54, w * 0.34, h * 0.14),
      const Radius.circular(10),
    );
    canvas.drawRRect(back, Paint()..color = dark);
    final seat = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.02, h * 0.64, w * 0.36, h * 0.09),
      const Radius.circular(8),
    );
    canvas.drawRRect(seat, Paint()..color = color);
    for (final x in [0.02, 0.34]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * x, h * 0.6, w * 0.04, h * 0.13),
          const Radius.circular(6),
        ),
        Paint()..color = dark,
      );
    }
  }

  void _paintTable(Canvas canvas, Size s, double t) {
    final id = _at(PlacementSlot.table);
    if (id == null) return;
    final w = s.width, h = s.height;
    final top = Rect.fromCenter(
      center: Offset(w * 0.47, h * 0.72),
      width: w * 0.24,
      height: h * 0.05,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(top.center.dx, h * 0.8),
        width: w * 0.02,
        height: h * 0.14,
      ),
      Paint()..color = const Color(0xFF3A2414),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(top.center.dx, h * 0.87),
        width: w * 0.12,
        height: h * 0.02,
      ),
      Paint()..color = const Color(0xFF3A2414),
    );
    if (id == 'checkered_table') {
      canvas.save();
      canvas.clipPath(Path()..addOval(top));
      final cell = top.width / 8;
      for (var i = 0; i < 8; i++) {
        for (var j = 0; j < 2; j++) {
          canvas.drawRect(
            Rect.fromLTWH(
              top.left + i * cell,
              top.top + j * top.height / 2,
              cell,
              top.height / 2,
            ),
            Paint()
              ..color = (i + j).isEven
                  ? const Color(0xFF2B2A33)
                  : const Color(0xFFEDE6D8),
          );
        }
      }
      canvas.restore();
    } else {
      canvas.drawOval(top, Paint()..color = const Color(0xFF9A6A43));
    }
    // カップ
    final cup = Offset(top.center.dx - w * 0.04, top.center.dy - h * 0.012);
    canvas.drawRect(
      Rect.fromCenter(center: cup, width: w * 0.035, height: h * 0.022),
      Paint()..color = const Color(0xFFF7F2E8),
    );
    if (effects.contains('fx_steam')) {
      final steam = Paint()
        ..color = const Color(0x88FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      for (var k = 0; k < 2; k++) {
        final path = Path();
        final phase = (t * 2 + k * 0.5) % 1.0;
        final x0 = cup.dx + (k - 0.5) * w * 0.012;
        path.moveTo(x0, cup.dy - h * 0.015);
        for (var i = 1; i <= 8; i++) {
          final y = cup.dy - h * 0.015 - i * h * 0.008;
          path.lineTo(
            x0 + math.sin(i * 0.9 + phase * math.pi * 2) * w * 0.008,
            y,
          );
        }
        canvas.drawPath(path, steam);
      }
    }
  }

  void _paintCounter(Canvas canvas, Rect c, Size s) {
    canvas.drawRect(c, Paint()..color = const Color(0xFF5A3620));
    canvas.drawRect(
      Rect.fromLTWH(
        c.left - s.width * 0.02,
        c.top - s.height * 0.02,
        c.width + s.width * 0.02,
        s.height * 0.025,
      ),
      Paint()..color = const Color(0xFF3A2414),
    );
    // 背面の棚とサイフォン
    final shelfY = s.height * 0.3;
    canvas.drawRect(
      Rect.fromLTWH(c.left + s.width * 0.02, shelfY, c.width, s.height * 0.012),
      Paint()..color = const Color(0xFF6B452A),
    );
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          c.left + s.width * (0.04 + i * 0.07),
          shelfY - s.height * 0.05,
          s.width * 0.035,
          s.height * 0.05,
        ),
        Paint()
          ..color = [
            const Color(0xFFB9C6C9),
            const Color(0xFF8C5A3B),
            const Color(0xFFD8C6A6),
            const Color(0xFF6E8C7A),
          ][i],
      );
    }
    // スツール
    for (final x in [0.74, 0.88]) {
      canvas.drawRect(
        Rect.fromLTWH(s.width * x, c.bottom, s.width * 0.012, s.height * 0.08),
        Paint()..color = const Color(0xFF2B2A33),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(s.width * x + s.width * 0.006, c.bottom),
          width: s.width * 0.08,
          height: s.height * 0.02,
        ),
        Paint()..color = const Color(0xFF9E2F35),
      );
    }
    // カウンターの上の小物
    final id = _at(PlacementSlot.counter);
    final base = Offset(s.width * 0.92, c.top - s.height * 0.02);
    switch (id) {
      case 'flower_vase':
        canvas.drawRect(
          Rect.fromCenter(
            center: base.translate(0, -s.height * 0.025),
            width: s.width * 0.02,
            height: s.height * 0.05,
          ),
          Paint()..color = const Color(0xFF8FB3AE),
        );
        canvas.drawLine(
          base.translate(0, -s.height * 0.05),
          base.translate(-s.width * 0.01, -s.height * 0.1),
          Paint()
            ..color = const Color(0xFF3F6E4A)
            ..strokeWidth = 1.5,
        );
        canvas.drawCircle(
          base.translate(-s.width * 0.01, -s.height * 0.105),
          s.width * 0.014,
          Paint()..color = const Color(0xFFD98C84),
        );
      case 'goldfish_bowl':
        final bowl = base.translate(0, -s.height * 0.03);
        canvas.drawCircle(
          bowl,
          s.width * 0.035,
          Paint()..color = const Color(0x8899CCEE),
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: bowl,
            width: s.width * 0.02,
            height: s.width * 0.012,
          ),
          Paint()..color = const Color(0xFFE8663C),
        );
      case 'cat_figure':
        final cat = base.translate(0, -s.height * 0.03);
        canvas.drawOval(
          Rect.fromCenter(
            center: cat,
            width: s.width * 0.045,
            height: s.height * 0.05,
          ),
          Paint()..color = const Color(0xFFF7F2E8),
        );
        canvas.drawCircle(
          cat.translate(0, -s.height * 0.03),
          s.width * 0.02,
          Paint()..color = const Color(0xFFF7F2E8),
        );
        canvas.drawCircle(
          cat.translate(s.width * 0.018, -s.height * 0.045),
          s.width * 0.007,
          Paint()..color = const Color(0xFFF7F2E8),
        );
    }
  }

  void _paintLight(Canvas canvas, Size s) {
    final id = _at(PlacementSlot.light);
    final w = s.width, h = s.height;
    // 常にある天井の裸電球
    final bulb = Offset(w * 0.5, h * 0.14);
    canvas.drawLine(
      Offset(bulb.dx, 0),
      bulb,
      Paint()
        ..color = const Color(0xFF2B2A33)
        ..strokeWidth = 1.2,
    );
    if (id == null) {
      canvas.drawCircle(
        bulb,
        w * 0.018,
        Paint()..color = const Color(0xFFFFF1CF),
      );
      return;
    }
    switch (id) {
      case 'stand_light':
        final foot = Offset(w * 0.07, h * 0.78);
        canvas.drawLine(
          foot,
          foot.translate(0, -h * 0.34),
          Paint()
            ..color = const Color(0xFF2B2A33)
            ..strokeWidth = 2,
        );
        final shade = Path()
          ..moveTo(foot.dx - w * 0.05, foot.dy - h * 0.3)
          ..lineTo(foot.dx + w * 0.05, foot.dy - h * 0.3)
          ..lineTo(foot.dx + w * 0.03, foot.dy - h * 0.37)
          ..lineTo(foot.dx - w * 0.03, foot.dy - h * 0.37)
          ..close();
        canvas.drawPath(shade, Paint()..color = const Color(0xFFF2C979));
        canvas.drawCircle(
          bulb,
          w * 0.018,
          Paint()..color = const Color(0xFFFFF1CF),
        );
      case 'night_lamp':
        canvas.drawCircle(
          bulb,
          w * 0.045,
          Paint()..color = const Color(0xFFFFF3C4),
        );
        canvas.drawCircle(
          bulb.translate(w * 0.018, -w * 0.008),
          w * 0.04,
          Paint()..color = const Color(0x33E6A85C),
        );
      case 'stained_lamp':
        final dome = Rect.fromCenter(
          center: bulb,
          width: w * 0.14,
          height: w * 0.12,
        );
        const colors = [
          Color(0xFF9E2F35),
          Color(0xFF4F7A5A),
          Color(0xFFC9A04F),
          Color(0xFF3B5A8C),
        ];
        for (var i = 0; i < 4; i++) {
          canvas.drawArc(
            dome,
            math.pi + i * math.pi / 4,
            math.pi / 4,
            true,
            Paint()..color = colors[i],
          );
        }
    }
  }

  // ---------------------------------------------------------------------------
  // 照明（時間帯の暗さ＋灯り）
  // ---------------------------------------------------------------------------

  void _paintLighting(Canvas canvas, Size s, double top, double fullHeight) {
    final darkness =
        switch (moment.slot) {
          TimeSlot.morning => 0.0,
          TimeSlot.noon => 0.0,
          TimeSlot.evening => 0.18,
          TimeSlot.night => 0.38,
          _ => 0.5,
        } +
        (moment.weather.isWet && !_dark ? 0.12 : 0.0);
    final whole = Rect.fromLTWH(0, -top, s.width, fullHeight);
    if (darkness > 0) {
      canvas.drawRect(
        whole,
        Paint()..color = const Color(0xFF0B0D1A).withValues(alpha: darkness),
      );
    }
    final lights = <(Offset, double, Color)>[
      (Offset(s.width * 0.5, s.height * 0.16), 0.5, const Color(0xFFFFD9A0)),
      if (top > 0) ...[
        (
          Offset(s.width * 0.16, -top * 0.38 + s.width * 0.05),
          0.32,
          const Color(0xFFFFD9A0),
        ),
        (
          Offset(s.width * 0.84, -top * 0.38 + s.width * 0.05),
          0.32,
          const Color(0xFFFFD9A0),
        ),
      ],
      if (_at(PlacementSlot.light) == 'stand_light')
        (
          Offset(s.width * 0.07, s.height * 0.44),
          0.45,
          const Color(0xFFFFB866),
        ),
      if (_at(PlacementSlot.light) == 'night_lamp')
        (Offset(s.width * 0.5, s.height * 0.14), 0.55, const Color(0xFFFFF0C0)),
      if (_at(PlacementSlot.light) == 'stained_lamp')
        (Offset(s.width * 0.5, s.height * 0.16), 0.55, const Color(0xFFFF9C7A)),
      if (_at(PlacementSlot.wall) == 'neon_sign' && _dark)
        (Offset(s.width * 0.74, s.height * 0.22), 0.4, const Color(0xFFFF7FB0)),
      if (_at(PlacementSlot.corner) == 'jukebox' && _dark)
        (
          Offset(s.width * 0.585, s.height * 0.66),
          0.3,
          const Color(0xFFF2C979),
        ),
    ];
    final strength = 0.12 + darkness * 0.6;
    for (final (c, radius, color) in lights) {
      final rad = s.width * radius;
      canvas.drawCircle(
        c,
        rad,
        Paint()
          ..blendMode = BlendMode.screen
          ..shader = ui.Gradient.radial(c, rad, [
            color.withValues(alpha: strength),
            color.withValues(alpha: 0),
          ]),
      );
    }
  }

  @override
  bool shouldRepaint(CafePainter old) =>
      old.moment.slot != moment.slot ||
      old.moment.weather != moment.weather ||
      old.placement != placement ||
      old.effects != effects;
}
