import 'package:flutter/material.dart';

import '../core/brand/theme.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          Container(width: 3, height: 14, color: YohakuColors.lamp),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                letterSpacing: 2,
                color: YohakuColors.paperDim,
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
        border: Border.all(color: color.withValues(alpha: 0.7)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: filled ? YohakuColors.ink : color,
        ),
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
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: YohakuColors.inkLine),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '広告枠（モック）',
        style: TextStyle(
          fontSize: 11,
          color: YohakuColors.paperDim,
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
        style: const TextStyle(color: YohakuColors.paperDim, height: 1.8),
      ),
    );
  }
}
