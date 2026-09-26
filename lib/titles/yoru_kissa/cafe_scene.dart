import 'package:flutter/material.dart';

import '../../core/brand/handdrawn.dart';

import '../../core/brand/theme.dart';
import '../../core/models/content.dart';
import '../../core/models/world.dart';
import '../../core/state/game_state.dart';
import '../../widgets/portrait.dart';
import 'cafe_painter.dart';

/// 店の画面。背景レイヤー（CafePainter）の上に、タップできる客を重ねる。
/// 与えられた領域いっぱいに描く（縦長なら天井と床を足す）。
class CafeScene extends StatefulWidget {
  const CafeScene({
    super.key,
    required this.content,
    required this.moment,
    required this.placement,
    required this.effects,
    required this.seated,
    required this.onGuestTap,
    this.showBubble = true,
  });

  final TitleContent content;
  final WorldMoment moment;
  final Map<PlacementSlot, String> placement;
  final Set<String> effects;
  final List<SeatedGuest> seated;
  final void Function(int index) onGuestTap;
  final bool showBubble;

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
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        final top = CafePainter.roomTop(size);
        final roomH = CafePainter.roomHeight(size);
        // 吹き出しは、いちばん最近来た客の上に出す。
        final bubbleIndex = widget.seated.isEmpty
            ? -1
            : widget.seated.length - 1;
        return Stack(
          clipBehavior: Clip.none,
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
            const Positioned.fill(child: PaperGrain(opacity: 1.4)),
            for (var i = 0; i < widget.seated.length; i++)
              _guest(
                i,
                size.width,
                top,
                roomH,
                bubble: widget.showBubble && i == bubbleIndex,
              ),
          ],
        );
      },
    );
  }

  Widget _guest(
    int i,
    double w,
    double top,
    double roomH, {
    required bool bubble,
  }) {
    final g = widget.seated[i];
    final anchors = CafePainter.guestAnchors;
    final anchor = anchors[(g.seat < 0 ? i : g.seat) % anchors.length];
    final id = g.visit.visitorId;
    final def = id == null ? null : widget.content.visitor(id);
    final look =
        def?.look ?? anonymousLook(g.visit.at.millisecondsSinceEpoch ~/ 60000);
    final size = w * 0.2;
    final line = def == null
        ? _passerbyLines[g.visit.at.minute % _passerbyLines.length]
        : def.lines[g.visit.at.minute % def.lines.length];
    final left = anchor.dx * w - size / 2;
    return Positioned(
      left: left,
      top: top + anchor.dy * roomH - size * 0.55,
      width: size,
      height: size * 1.2,
      child: GestureDetector(
        onTap: () => widget.onGuestTap(i),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: size * 0.2,
              left: 0,
              right: 0,
              height: size,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(g.visit.at),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                builder: (context, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, (1 - v) * 8),
                    child: child,
                  ),
                ),
                child: CustomPaint(painter: PortraitPainter(look: look)),
              ),
            ),
            Positioned(
              top: 0,
              child: _CoinBadge(bill: g.bill, named: def != null),
            ),
            if (bubble)
              Positioned(
                bottom: size * 1.28,
                // 画面からはみ出さない位置に寄せる（吹き出しは最大幅 190）。
                left: (-size * 0.6).clamp(-left + 8, w - 198 - left),
                child: _SpeechBubble(text: line),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoinBadge extends StatelessWidget {
  const _CoinBadge({required this.bill, required this.named});

  final int bill;
  final bool named;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: ShapeDecoration(
        color: YohakuColors.paper,
        // 顔なじみ（図鑑に載る人）は枠を濃くするだけ。記号は付けない。
        shape: RoughBorder(
          radius: 10,
          side: BorderSide(
            color: named ? YohakuColors.wood : YohakuColors.lamp,
            width: named ? 2 : 1.5,
          ),
        ),
        shadows: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            yen(bill),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: YohakuColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 190),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: ShapeDecoration(
          color: YohakuColors.paper.withValues(alpha: 0.95),
          shape: RoughBorder(radius: 14),
          shadows: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            height: 1.5,
            color: YohakuColors.ink,
          ),
        ),
      ),
    );
  }
}

/// 通りすがりの客のひとりごと。説明ではなく、その場で本当に言いそうなこと。
const _passerbyLines = [
  'すみません、お水もらえますか',
  'あ、雨やんだ',
  '砂糖、どこですか',
  'ここ、こんな時間までやってるんだ',
  '（スマホの充電が切れた）',
  'もう一杯だけ',
  '駅、こっちで合ってますよね',
  '……ふう',
];
