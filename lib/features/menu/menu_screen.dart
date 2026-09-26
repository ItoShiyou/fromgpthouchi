import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';

/// 07. メニュー ― 料理・飲み物。
///
/// メニューが増えると、好物を持つ客が来やすくなり、出来事の条件にもなる。
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final ctrl = ref.read(gameProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const SectionTitle('お品書き'),
        for (final m in c.menus)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                m.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                yen(m.price),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: YohakuColors.paperDim,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: YohakuColors.paperDim,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (s.ownedMenus.contains(m.id))
                      const Text(
                        '出せる',
                        style: TextStyle(
                          color: YohakuColors.lamp,
                          fontSize: 12,
                        ),
                      )
                    else
                      FilledButton.tonal(
                        onPressed: s.money >= m.unlockCost
                            ? () {
                                if (ctrl.unlockMenu(m.id)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('「${m.name}」を出せるようになりました'),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Text('覚える ${yen(m.unlockCost)}'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          '好きなものがメニューにあると、その人は少し来やすくなります。',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: YohakuColors.paperDim),
        ),
      ],
    );
  }
}
