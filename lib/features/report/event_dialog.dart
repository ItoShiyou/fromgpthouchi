import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          borderRadius: BorderRadius.circular(20),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: YohakuColors.lamp,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '特別な出来事',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: YohakuColors.wood,
                      ),
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
                    child: Text(
                      '― この出来事を、最後まで見届けました。',
                      style: TextStyle(
                        fontSize: 11,
                        color: YohakuColors.inkDim,
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
