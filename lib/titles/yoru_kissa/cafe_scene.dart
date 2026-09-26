import 'package:flutter/material.dart';

import '../../core/brand/theme.dart';
import '../../core/models/content.dart';
import '../../core/models/world.dart';
import '../../core/state/game_state.dart';
import 'cafe_painter.dart';

/// 店の画面。背景レイヤー（CafePainter）の上に、タップできる客を重ねる。
class CafeScene extends StatefulWidget {
  const CafeScene({
    super.key,
    required this.content,
    required this.moment,
    required this.placement,
    required this.effects,
    required this.seated,
    required this.onGuestTap,
  });

  final TitleContent content;
  final WorldMoment moment;
  final Map<PlacementSlot, String> placement;
  final Set<String> effects;
  final List<SeatedGuest> seated;
  final void Function(int index) onGuestTap;

  @override
  State<CafeScene> createState() => _CafeSceneState();
}

class _CafeSceneState extends State<CafeScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth, h = c.maxHeight;
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: CafePainter(
                      moment: widget.moment,
                      placement: widget.placement,
                      effects: widget.effects,
                      animation: _anim,
                    ),
                  ),
                ),
                for (var i = 0; i < widget.seated.length; i++)
                  _positioned(i, w, h),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _positioned(int i, double w, double h) {
    final g = widget.seated[i];
    final anchors = CafePainter.guestAnchors;
    final anchor = anchors[(g.seat < 0 ? i : g.seat) % anchors.length];
    final def = g.visit.visitorId == null
        ? null
        : widget.content.visitor(g.visit.visitorId!);
    final size = w * 0.16;
    return Positioned(
      left: anchor.dx * w - size / 2,
      top: anchor.dy * h - size * 0.4,
      width: size,
      height: size * 1.55,
      child: GuestFigure(
        key: ValueKey('${g.visit.at.toIso8601String()}-$i'),
        color: Color(def?.colorValue ?? 0xFF6B6E78),
        bill: g.bill,
        named: def != null,
        onTap: () => widget.onGuestTap(i),
      ),
    );
  }
}

/// 客のシルエット＋会計バッジ。
class GuestFigure extends StatelessWidget {
  const GuestFigure({
    super.key,
    required this.color,
    required this.bill,
    required this.named,
    required this.onTap,
  });

  final Color color;
  final int bill;
  final bool named;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (context, v, child) => Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * 8),
            child: child,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final s = c.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: s * 0.32,
                  child: Container(
                    width: s * 0.42,
                    height: s * 0.42,
                    decoration: BoxDecoration(
                      color: Color.lerp(color, Colors.white, 0.35),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  top: s * 0.7,
                  child: Container(
                    width: s * 0.7,
                    height: s * 0.8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(s * 0.35),
                        bottom: Radius.circular(s * 0.08),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: YohakuColors.lamp,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      yen(bill),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: YohakuColors.ink,
                      ),
                    ),
                  ),
                ),
                if (named)
                  Positioned(
                    top: s * 0.36,
                    right: s * 0.12,
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: YohakuColors.lamp,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
