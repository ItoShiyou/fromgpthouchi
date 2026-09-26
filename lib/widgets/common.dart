import 'package:flutter/material.dart';

import '../core/brand/theme.dart';

/// 夜の背景の上に、紙のパネルを 1 枚置いたページ。
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

  /// パネルの後ろ（夜空の代わり）に敷くもの。
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
                decoration: BoxDecoration(
                  color: widget.panelColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
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
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          Expanded(
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: YohakuColors.ink,
                              ),
                            ),
                          ),
                          if (widget.showClose)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: YohakuColors.inkDim,
                              ),
                              onPressed: () => Navigator.of(context).maybePop(),
                            )
                          else
                            const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    if (widget.tabs.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF14203D), Color(0xFF2A3A63), Color(0xFF3B4A73)],
        ),
      ),
      child: CustomPaint(painter: StarsPainter(), size: Size.infinite),
    );
  }
}

class StarsPainter extends CustomPainter {
  const StarsPainter({this.count = 60});

  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    var seed = 17;
    double rnd() {
      seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF;
      return seed / 0x7FFFFFFF;
    }

    for (var i = 0; i < count; i++) {
      final o = Offset(rnd() * size.width, rnd() * size.height * 0.7);
      final r = 0.4 + rnd() * 1.2;
      canvas.drawCircle(
        o,
        r,
        Paint()..color = Color.fromRGBO(255, 248, 225, 0.3 + rnd() * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(StarsPainter old) => false;
}

/// 茶色の丸いタブ（「すべて／常連／特別」など）。
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
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: YohakuColors.paperDeep,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected
                        ? YohakuColors.wood
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i == selected
                          ? YohakuColors.paper
                          : YohakuColors.inkDim,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 紙のパネルの中に置く、一段濃い紙のカード。
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
    return Material(
      color: Colors.white.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: highlight ? YohakuColors.lamp : YohakuColors.paperLine,
          width: highlight ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 絵文字アイコンを載せた四角いタイル（モックの仮イラスト）。
class IconTile extends StatelessWidget {
  const IconTile(
    this.icon, {
    super.key,
    this.size = 52,
    this.locked = false,
    this.background = YohakuColors.paperDeep,
  });

  final String icon;
  final double size;
  final bool locked;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: locked
          ? Icon(
              Icons.question_mark,
              size: size * 0.4,
              color: YohakuColors.paperLine,
            )
          : Text(icon, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 16, 2, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: YohakuColors.ink,
              ),
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
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
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

class NewBadge extends StatelessWidget {
  const NewBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: YohakuColors.rose,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'NEW',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 図鑑の進み具合。
class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.value,
    this.color = YohakuColors.wood,
    this.height = 8,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        color: color,
        backgroundColor: YohakuColors.paperLine,
      ),
    );
  }
}

/// 無課金ユーザー向けの広告枠（モック）。広告削除を買うと消える。
class AdBannerMock extends StatelessWidget {
  const AdBannerMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '広告枠（モック）',
        style: TextStyle(
          fontSize: 10,
          color: Color(0xAAFFFFFF),
          letterSpacing: 2,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
        ),
        child: Stack(
          children: [
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
