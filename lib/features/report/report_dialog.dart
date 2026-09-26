import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/state/game_state.dart';
import '../../widgets/common.dart';
import '../../widgets/portrait.dart';

/// 02. 放置結果 ―「おかえりなさい」。
/// 出来事の本文はこのあと「特別な出来事」で 1 つずつ見せる。
class ReportDialog extends ConsumerWidget {
  const ReportDialog({super.key, required this.report});

  final IdleReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = report;
    final content = ref.watch(contentProvider);

    Widget row(
      IconData icon,
      String label,
      String value, {
      bool coin = false,
    }) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: YohakuColors.paperLine),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: YohakuColors.cream,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: YohakuColors.wood),
          ),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          if (coin)
            const Icon(
              Icons.monetization_on,
              size: 16,
              color: YohakuColors.lamp,
            ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );

    return PaperDialog(
      corner: const SleepingCat(size: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'おかえりなさい',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '前回の営業から '),
                TextSpan(
                  text: hmJa(r.elapsed),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const TextSpan(text: ' 経過しました'),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: YohakuColors.inkDim),
          ),
          if (r.isCapped)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '（お店は ${content.maxIdle.inHours} 時間分まで営業します）',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: YohakuColors.inkDim,
                ),
              ),
            ),
          const SizedBox(height: 16),
          row(
            Icons.payments_outlined,
            '売上',
            '+${yen(r.income).substring(1)}',
            coin: true,
          ),
          row(Icons.person_outline, '来店したお客様', '${r.visitCount} 人'),
          row(
            Icons.inventory_2_outlined,
            '新しいアイテム',
            '${r.ticketsEarned + r.itemsFound.length} 個',
          ),
          row(
            Icons.auto_awesome_outlined,
            '特別な出来事',
            '${r.newFragments.length} 件',
          ),
          if (r.newVisitorIds.isNotEmpty) ...[
            const SizedBox(height: 6),
            const Text(
              'はじめてのお客さん',
              style: TextStyle(fontSize: 12, color: YohakuColors.inkDim),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final id in r.newVisitorIds)
                  Column(
                    children: [
                      Portrait(look: content.visitor(id).look, size: 46),
                      const SizedBox(height: 4),
                      Text(
                        content.visitor(id).silhouetteName,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
              ],
            ),
          ],
          if (r.ticketsEarned > 0 || r.itemsFound.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              [
                if (r.ticketsEarned > 0) '余白くじチケット ×${r.ticketsEarned}',
                for (final id in r.itemsFound) content.item(id).name,
              ].join('、'),
              style: const TextStyle(fontSize: 11, color: YohakuColors.inkDim),
            ),
          ],
        ],
      ),
    );
  }
}

/// ダイアログの隅で寝ている猫。
class SleepingCat extends StatelessWidget {
  const SleepingCat({super.key, this.size = 60});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size * 0.6,
        child: CustomPaint(painter: _CatPainter()),
      ),
    );
  }
}

class _CatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final fur = Paint()..color = const Color(0xFFF1D7B8);
    final line = Paint()
      ..color = const Color(0xFF8E6A4E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final body = Rect.fromLTWH(
      s.width * 0.1,
      s.height * 0.35,
      s.width * 0.7,
      s.height * 0.6,
    );
    canvas.drawOval(body, fur);
    canvas.drawOval(body, line);
    final head = Offset(s.width * 0.78, s.height * 0.55);
    final r = s.height * 0.3;
    for (final side in [-1.0, 1.0]) {
      final ear = Path()
        ..moveTo(head.dx + side * r * 0.8, head.dy - r * 0.3)
        ..lineTo(head.dx + side * r * 0.6, head.dy - r * 1.2)
        ..lineTo(head.dx + side * r * 0.05, head.dy - r * 0.8)
        ..close();
      canvas.drawPath(ear, fur);
      canvas.drawPath(ear, line);
    }
    canvas.drawCircle(head, r, fur);
    canvas.drawCircle(head, r, line);
    for (final side in [-1.0, 1.0]) {
      canvas.drawArc(
        Rect.fromCenter(
          center: head.translate(side * r * 0.38, 0),
          width: r * 0.4,
          height: r * 0.25,
        ),
        0,
        math.pi,
        false,
        line,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(s.width * 0.12, s.height * 0.7),
        width: s.width * 0.18,
        height: s.height * 0.4,
      ),
      math.pi * 0.5,
      math.pi,
      false,
      line..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_CatPainter old) => false;
}
