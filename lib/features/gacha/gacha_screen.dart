import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/handdrawn.dart';

import '../../core/brand/theme.dart';
import '../../core/engine/gacha_engine.dart';
import '../../core/models/content.dart';
import '../../core/services/sound.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';
import '../shop/shop_screen.dart';

/// 08. 余白くじ。
///
/// 「課金すると強くなる」ではなく「課金すると世界が広がる」。
/// 排出率はいつでも確認できる。天井あり。コンプリート報酬なし。
class GachaScreen extends ConsumerStatefulWidget {
  const GachaScreen({super.key});

  @override
  ConsumerState<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends ConsumerState<GachaScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final g = c.gacha;
    final ownedInPool = g.entries
        .where((e) => s.ownedItems.contains(e.itemId))
        .length;
    final complete = ownedInPool == g.entries.length;

    return Scaffold(
      backgroundColor: const Color(0xFF3E2819),
      body: Stack(
        children: [
          const Positioned.fill(child: PaperGrain(dark: true, opacity: 1.3)),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const SketchIcon(
                          Sketch.back,
                          size: 30,
                          color: YohakuColors.paper,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          g.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: YohakuColors.paper,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: ShapeDecoration(
                    color: YohakuColors.paper,
                    shape: RoughBorder(radius: 20),
                  ),
                  child: Text(
                    '集めた $ownedInPool / ${g.entries.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: AnimatedBuilder(
                      animation: _shake,
                      builder: (context, child) => Transform.rotate(
                        angle:
                            math.sin(_shake.value * math.pi * 8) *
                            0.04 *
                            (1 - _shake.value),
                        child: child,
                      ),
                      child: AspectRatio(
                        aspectRatio: 0.8,
                        child: CustomPaint(
                          painter: _MachinePainter(knob: _shake),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DrawButton(
                          times: 1,
                          enabled: s.tickets >= 1,
                          onTap: () => _draw(1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DrawButton(
                          times: 10,
                          enabled: s.tickets >= 10,
                          onTap: () => _draw(10),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  complete
                      ? 'すべて集まりました'
                      : 'あと ${g.pityCount - s.gachaPity} 回のうちに、まだ持っていないものが必ず出ます',
                  style: const TextStyle(
                    fontSize: 12,
                    color: YohakuColors.cream,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0x66000000),
                            shape: RoughBorder(radius: 20),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '所持チケット',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: YohakuColors.paper,
                                ),
                              ),
                              const Spacer(),
                              const SketchIcon(
                                Sketch.ticket,
                                size: 16,
                                color: Color(0xFF8EC5E8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${s.tickets}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: YohakuColors.paper,
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: 'チケットを手に入れる',
                                icon: const SketchIcon(
                                  Sketch.plus,
                                  color: YohakuColors.lamp,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const ShopScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 40,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: YohakuColors.paper,
                            foregroundColor: YohakuColors.ink,
                          ),
                          onPressed: () => _showRates(context, c.gacha, c),
                          child: const Text('提供割合'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _draw(int times) async {
    final out = ref.read(gameProvider.notifier).drawGacha(times);
    if (out == null) return;
    ref.read(soundProvider).play(Se.gacha);
    ref
        .read(analyticsProvider)
        .gachaDrawn(times, out.draws.where((d) => d.isNew).length);
    await _shake.forward(from: 0);
    if (!mounted) return;
    final c = ref.read(contentProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) => PaperDialog(
        buttonLabel: 'お店に戻す',
        child: Column(
          children: [
            const Text(
              '余白くじ',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final d in out.draws)
                  _ResultCard(draw: d, item: c.item(d.entry.itemId)),
              ],
            ),
            if (out.refund > 0) ...[
              const SizedBox(height: 12),
              Text(
                '持っていたものは ${yen(out.refund)} の売上になりました',
                style: const TextStyle(
                  fontSize: 11,
                  color: YohakuColors.inkDim,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRates(BuildContext context, GachaDef g, TitleContent c) {
    final s = ref.read(gameProvider);
    showDialog<void>(
      context: context,
      builder: (_) => PaperDialog(
        buttonLabel: '閉じる',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '提供割合',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 12),
            for (final r in Rarity.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    TagPill(r.label, color: _rarityColor(r), filled: true),
                    const Spacer(),
                    Text(
                      '${((g.rarityRates[r] ?? 0) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            const Divider(height: 20),
            for (final e in g.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    IconTile(c.item(e.itemId).icon, size: 22, artId: e.itemId),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        c.item(e.itemId).name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    if (s.ownedItems.contains(e.itemId))
                      const SketchIcon(
                        Sketch.check,
                        size: 14,
                        color: YohakuColors.moss,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      '${(g.rateOf(e) * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '・出るのは家具・小物・BGM・演出です。売上や来店数は変わりません。\n'
              '・${g.pityCount} 回引くまでに持っていないものが出なかった場合、次の 1 回は必ず持っていないものになります。\n'
              '・持っているものが出た場合は ${yen(g.duplicateRefund)} の売上に換わります。\n'
              '・特定の組み合わせを揃えることで得られる特典はありません。',
              style: const TextStyle(
                fontSize: 10,
                color: YohakuColors.inkDim,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _rarityColor(Rarity r) => switch (r) {
  Rarity.common => YohakuColors.moss,
  Rarity.rare => YohakuColors.lamp,
  Rarity.superRare => YohakuColors.rose,
};

class _DrawButton extends StatelessWidget {
  const _DrawButton({
    required this.times,
    required this.enabled,
    required this.onTap,
  });

  final int times;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: const Color(0xFF3A2414),
        shape: const RoughBorder(
          radius: 14,
          side: BorderSide(color: YohakuColors.lamp, width: 1.5),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  '$times回引く',
                  style: const TextStyle(
                    color: YohakuColors.paper,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    color: YohakuColors.paper,
                    shape: RoughBorder(radius: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SketchIcon(
                        Sketch.ticket,
                        size: 14,
                        color: Color(0xFF5E9CC7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$times',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.draw, required this.item});

  final GachaDraw draw;
  final ItemDef item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      padding: const EdgeInsets.all(6),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoughBorder(
          radius: 12,
          side: BorderSide(color: _rarityColor(draw.entry.rarity), width: 2),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              IconTile(item.icon, size: 40, artId: item.id),
              const SizedBox(height: 4),
              Text(
                item.name,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
          ),
          if (draw.isNew)
            const Positioned(top: -12, right: -12, child: NewBadge()),
        ],
      ),
    );
  }
}

/// カプセルの入ったくじ機。
class _MachinePainter extends CustomPainter {
  _MachinePainter({required this.knob}) : super(repaint: knob);

  final Animation<double> knob;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cx = w / 2;
    // 影
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.97),
        width: w * 0.7,
        height: h * 0.05,
      ),
      Paint()..color = const Color(0x55000000),
    );
    // 台
    final base = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.2, h * 0.55, w * 0.8, h * 0.95),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(base, Paint()..color = const Color(0xFFB2322C));
    canvas.drawRRect(
      base.deflate(w * 0.03),
      Paint()..color = const Color(0xFFC94A3F),
    );
    canvas.drawRect(
      Rect.fromLTRB(w * 0.18, h * 0.53, w * 0.82, h * 0.58),
      Paint()..color = const Color(0xFF8C2420),
    );
    // つまみ
    final k = Offset(cx, h * 0.72);
    canvas.drawCircle(k, w * 0.1, Paint()..color = const Color(0xFFF3EBDD));
    canvas.save();
    canvas.translate(k.dx, k.dy);
    canvas.rotate(knob.value * math.pi * 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w * 0.17, height: w * 0.04),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFB9A88F),
    );
    canvas.restore();
    // 取り出し口
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.87),
          width: w * 0.2,
          height: h * 0.07,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF3A1410),
    );
    // ガラスの球
    final dome = Offset(cx, h * 0.3);
    final r = w * 0.33;
    canvas.drawCircle(dome, r, Paint()..color = const Color(0x55DDEEFF));
    final rnd = math.Random(3);
    const colors = [
      Color(0xFFE6B66E),
      Color(0xFF7FA394),
      Color(0xFFD9695B),
      Color(0xFF8EC5E8),
      Color(0xFFF3EBDD),
      Color(0xFFB48AC9),
    ];
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: dome, radius: r * 0.96)),
    );
    for (var i = 0; i < 26; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = math.sqrt(rnd.nextDouble()) * r * 0.9;
      final p =
          dome + Offset(math.cos(a) * d, math.sin(a) * d * 0.8 + r * 0.25);
      if (i.isEven) {
        // カプセル
        final cr = w * 0.05;
        canvas.drawCircle(p, cr, Paint()..color = colors[i % colors.length]);
        canvas.drawArc(
          Rect.fromCircle(center: p, radius: cr),
          0,
          math.pi,
          true,
          Paint()..color = Colors.white.withValues(alpha: 0.85),
        );
      } else {
        // 小さな絵札
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(rnd.nextDouble() - 0.5);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: w * 0.08,
              height: w * 0.1,
            ),
            const Radius.circular(3),
          ),
          Paint()..color = colors[(i + 2) % colors.length],
        );
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: w * 0.05,
            height: w * 0.05,
          ),
          Paint()..color = const Color(0xFFF3EBDD),
        );
        canvas.restore();
      }
    }
    canvas.restore();
    Rough.ink(
      canvas,
      Rough.oval(Rect.fromCircle(center: dome, radius: r), amount: 1.6),
      color: const Color(0xFF1E140E),
      width: 2.4,
    );
    canvas.drawArc(
      Rect.fromCircle(center: dome, radius: r * 0.82),
      math.pi * 1.1,
      0.7,
      false,
      Paint()
        ..color = const Color(0xAAFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // 上のふた
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, dome.dy - r),
          width: w * 0.2,
          height: h * 0.04,
        ),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFB2322C),
    );
    _linework(canvas, size, dome, r);
  }

  /// 塗りの上にインクの輪郭。
  void _linework(Canvas canvas, Size size, Offset dome, double r) {
    final w = size.width, h = size.height, cx = w / 2;
    const ink = Color(0xFF1E140E);
    void line(Path p, [double width = 2.2]) =>
        Rough.ink(canvas, p, color: ink, width: width);
    line(
      Rough.rrect(
        Rect.fromLTRB(w * 0.2, h * 0.55, w * 0.8, h * 0.95),
        w * 0.06,
        amount: 1.4,
      ),
    );
    line(Rough.rrect(Rect.fromLTRB(w * 0.18, h * 0.53, w * 0.82, h * 0.58), 2));
    line(
      Rough.oval(
        Rect.fromCircle(center: Offset(cx, h * 0.72), radius: w * 0.1),
      ),
      1.8,
    );
    line(
      Rough.rrect(
        Rect.fromCenter(
          center: Offset(cx, h * 0.87),
          width: w * 0.2,
          height: h * 0.07,
        ),
        8,
      ),
      1.8,
    );
    line(
      Rough.rrect(
        Rect.fromCenter(
          center: Offset(cx, dome.dy - r),
          width: w * 0.2,
          height: h * 0.04,
        ),
        6,
      ),
      1.8,
    );
    // 台の木目のような縦の擦れ
    for (var i = 0; i < 5; i++) {
      final x = w * (0.28 + i * 0.1);
      Rough.ink(
        canvas,
        Rough.line(
          Offset(x, h * 0.62),
          Offset(x + 2, h * 0.64 + (i % 2) * h * 0.03),
        ),
        color: ink,
        width: 1,
        opacity: 0.3,
      );
    }
  }

  @override
  bool shouldRepaint(_MachinePainter old) => false;
}
