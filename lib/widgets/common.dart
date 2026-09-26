import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/brand/handdrawn.dart';
import '../core/brand/theme.dart';

/// 夜の背景の上に、紙を 1 枚置いたページ。
/// 図鑑・家具・メニュー・くじ・ショップ・設定などはすべてこの形。
class PaperPage extends StatefulWidget {
  const PaperPage({
    super.key,
    required this.title,
    this.tabs = const [],
    required this.builder,
    this.showClose = false,
    this.footer,
    this.background,
    this.panelColor = YohakuColors.paper,
  });

  final String title;
  final List<String> tabs;
  final Widget Function(BuildContext context, int tab) builder;
  final bool showClose;
  final Widget? footer;

  /// 紙の後ろ（夜空の代わり）に敷くもの。
  final Widget? background;
  final Color panelColor;

  @override
  State<PaperPage> createState() => _PaperPageState();
}

class _PaperPageState extends State<PaperPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: widget.background ?? const NightBackdrop()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Container(
                decoration: ShapeDecoration(
                  color: widget.panelColor,
                  shape: RoughBorder(
                    radius: 16,
                    amount: 0.8,
                    side: BorderSide(
                      color: YohakuColors.ink.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    const Positioned.fill(child: PaperGrain()),
                    Column(
                      children: [
                        SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.chevron_left,
                                  size: 30,
                                  color: YohakuColors.ink,
                                ),
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                              ),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: YohakuText.heading(19),
                                ),
                              ),
                              if (widget.showClose)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: YohakuColors.inkDim,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                )
                              else
                                const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        if (widget.tabs.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                            child: PillTabs(
                              labels: widget.tabs,
                              selected: _tab,
                              onChanged: (i) => setState(() => _tab = i),
                            ),
                          ),
                        Expanded(child: widget.builder(context, _tab)),
                        ?widget.footer,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 夜空（星つき）。
class NightBackdrop extends StatelessWidget {
  const NightBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Color(0xFF1C2742)),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: StarsPainter())),
          Positioned.fill(child: PaperGrain(dark: true, opacity: 0.8)),
        ],
      ),
    );
  }
}

class StarsPainter extends CustomPainter {
  const StarsPainter({this.count = 45});

  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(17);
    for (var i = 0; i < count; i++) {
      final o = Offset(
        rnd.nextDouble() * size.width,
        rnd.nextDouble() * size.height * 0.7,
      );
      final big = rnd.nextInt(9) == 0;
      final paint = Paint()
        ..color = Color.fromRGBO(255, 244, 214, 0.35 + rnd.nextDouble() * 0.5);
      if (big) {
        // 大きい星だけ、手で描いた十字
        paint
          ..strokeWidth = 1.1
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(o.translate(-3, 0.3), o.translate(3, -0.3), paint);
        canvas.drawLine(o.translate(0.3, -3), o.translate(-0.3, 3), paint);
      } else {
        canvas.drawCircle(o, 0.5 + rnd.nextDouble() * 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(StarsPainter old) => false;
}

/// タブ。選ぶと筆で下線が引かれる。
class PillTabs extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: YohakuColors.ink.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: SizedBox(
                  height: 38,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (i == selected)
                        Positioned(
                          bottom: 4,
                          child: BrushUnderline(
                            width: 12.0 * labels[i].length + 10,
                            thickness: 6,
                          ),
                        ),
                      Text(
                        labels[i],
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: i == selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: i == selected
                              ? YohakuColors.ink
                              : YohakuColors.inkDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 紙の上の、線で囲っただけの区画。影は付けない。
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.highlight = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final shape = RoughBorder(
      radius: 8,
      amount: 1.1,
      side: BorderSide(
        color: highlight
            ? YohakuColors.wood
            : YohakuColors.ink.withValues(alpha: 0.35),
        width: highlight ? 2 : 1,
      ),
    );
    return Material(
      color: highlight
          ? YohakuColors.cream.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.28),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: shape,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 家具・メニュー・商品の「しるし」。
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.size = 52, this.locked = false});

  final String icon;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) =>
      InkGlyph(icon, size: size, locked: locked);
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned(
                  left: -2,
                  bottom: 0,
                  child: BrushUnderline(
                    width: 14.0 * text.length + 6,
                    thickness: 5,
                    color: YohakuColors.lamp.withValues(alpha: 0.6),
                  ),
                ),
                Text(text, style: YohakuText.heading(14)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class TagPill extends StatelessWidget {
  const TagPill(
    this.label, {
    super.key,
    this.color = YohakuColors.moss,
    this.filled = false,
  });

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: ShapeDecoration(
        color: filled ? color.withValues(alpha: 0.85) : Colors.transparent,
        shape: RoughBorder(
          radius: 6,
          amount: 0.7,
          side: BorderSide(color: color, width: 1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: filled ? Colors.white : color,
        ),
      ),
    );
  }
}

/// 新しく来た人・新しく手に入ったものに押す、赤い判子。
class NewBadge extends StatelessWidget {
  const NewBadge({super.key});

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -0.12,
    child: const InkGlyph('新', size: 24, color: YohakuColors.rose),
  );
}

/// 図鑑の進み具合。塗りは斜線で。
class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.value,
    this.color = YohakuColors.wood,
    this.height = 10,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _ProgressPainter(value.clamp(0, 1).toDouble(), color),
        size: Size.infinite,
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter(this.value, this.color);

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    final outline = Rough.rrect(r.deflate(1), size.height / 2, amount: 0.8);
    if (value > 0) {
      canvas.save();
      canvas.clipPath(outline);
      final fillW = size.width * value;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, fillW, size.height),
        Paint()..color = color.withValues(alpha: 0.35),
      );
      final hatch = Paint()
        ..color = color
        ..strokeWidth = 1.4;
      for (var x = -size.height; x < fillW; x += 4) {
        canvas.drawLine(
          Offset(x, size.height),
          Offset(x + size.height, 0),
          hatch,
        );
      }
      canvas.restore();
    }
    Rough.ink(canvas, outline, color: YohakuColors.ink, width: 1, opacity: 0.6);
  }

  @override
  bool shouldRepaint(_ProgressPainter old) =>
      old.value != value || old.color != color;
}

/// 無課金ユーザー向けの広告枠。広告削除を買うと消える。
class AdBannerMock extends StatelessWidget {
  const AdBannerMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      alignment: Alignment.center,
      color: Colors.black.withValues(alpha: 0.4),
      child: const Text(
        '広告',
        style: TextStyle(
          fontSize: 10,
          color: Color(0x88FFFFFF),
          letterSpacing: 4,
        ),
      ),
    );
  }
}

class EmptyNote extends StatelessWidget {
  const EmptyNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: YohakuColors.inkDim, height: 1.8),
      ),
    );
  }
}

/// 未発見の行。点線ではなく、まだ何も書かれていない罫線にする。
class BlankRule extends StatelessWidget {
  const BlankRule({super.key, this.height = 22});

  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: CustomPaint(painter: _RulePainter(), size: Size.infinite),
  );
}

class _RulePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rough.ink(
      canvas,
      Rough.line(
        Offset(0, size.height - 3),
        Offset(size.width, size.height - 3),
        amount: 0.6,
        seed: size.width,
      ),
      color: YohakuColors.ink,
      width: 0.8,
      opacity: 0.25,
    );
  }

  @override
  bool shouldRepaint(_RulePainter old) => false;
}

/// 紙のダイアログ（おかえりなさい・お客さん・くじの結果など）。
class PaperDialog extends StatelessWidget {
  const PaperDialog({
    super.key,
    required this.child,
    this.buttonLabel = 'OK',
    this.onButton,
    this.maxHeightFactor = 0.8,
    this.corner,
  });

  final Widget child;
  final String buttonLabel;
  final VoidCallback? onButton;
  final double maxHeightFactor;

  /// 右下の隅に添える飾り（寝ている猫など）。
  final Widget? corner;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: YohakuColors.paper,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoughBorder(
        radius: 14,
        amount: 0.9,
        side: BorderSide(
          color: YohakuColors.ink.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: PaperGrain()),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 8),
                    child: child,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
                  child: SizedBox(
                    width: 150,
                    height: 44,
                    child: FilledButton(
                      onPressed: onButton ?? () => Navigator.of(context).pop(),
                      child: Text(buttonLabel),
                    ),
                  ),
                ),
              ],
            ),
            if (corner != null)
              Positioned(
                right: 16,
                bottom: 14,
                child: IgnorePointer(child: corner!),
              ),
          ],
        ),
      ),
    );
  }
}
