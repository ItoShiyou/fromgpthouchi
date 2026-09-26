import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/handdrawn.dart';
import '../../core/brand/theme.dart';
import '../../core/state/game_controller.dart';
import '../../core/state/game_state.dart';

/// 特別な出来事。店の絵の手前に、紙のカードを 1 枚出す。
class EventDialog extends ConsumerWidget {
  const EventDialog({super.key, required this.fragment});

  final DiscoveredFragment fragment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chain = ref.watch(contentProvider).story(fragment.chainId);
    final last = fragment.step == chain.steps.length - 1;
    return Align(
      alignment: const Alignment(0, 0.55),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Material(
          color: YohakuColors.paper,
          shape: RoughBorder(
            radius: 12,
            amount: 0.9,
            side: BorderSide(
              color: YohakuColors.ink.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'できごと',
                      style: YohakuText.heading(13, color: YohakuColors.wood),
                    ),
                    const Spacer(),
                    Text(
                      '「${chain.title}」 ${fragment.step + 1}/${chain.steps.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: YohakuColors.inkDim,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  chain.steps[fragment.step].text,
                  style: const TextStyle(fontSize: 15, height: 1.8),
                ),
                if (last)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '（おしまい）',
                        style: TextStyle(
                          fontSize: 11,
                          color: YohakuColors.inkDim,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                Center(
                  child: SizedBox(
                    width: 130,
                    height: 40,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
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
