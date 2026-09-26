import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/models/content.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';

/// 07. メニュー ― ドリンク・フード・スイーツ。
///
/// メニューが増えると、好物を持つ客が来やすくなり、出来事の条件にもなる。
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final ctrl = ref.read(gameProvider.notifier);

    return PaperPage(
      title: 'メニュー',
      tabs: [for (final cat in MenuCategory.values) cat.label],
      builder: (context, tab) {
        final menus = c.menus
            .where((m) => m.category == MenuCategory.values[tab])
            .toList();
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
          itemCount: menus.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            if (i == menus.length) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  '好きなものがメニューにあると、その人は少し来やすくなります。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: YohakuColors.inkDim),
                ),
              );
            }
            final m = menus[i];
            final owned = s.ownedMenus.contains(m.id);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: YohakuColors.paperLine),
                    ),
                    child: Opacity(
                      opacity: owned ? 1 : 0.35,
                      child: Text(m.icon, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m.description,
                          style: const TextStyle(
                            fontSize: 11,
                            color: YohakuColors.inkDim,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        yen(m.price),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      if (!owned)
                        SizedBox(
                          height: 30,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              textStyle: const TextStyle(fontSize: 11),
                            ),
                            onPressed: s.money >= m.unlockCost
                                ? () {
                                    if (ctrl.unlockMenu(m.id)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '「${m.name}」を出せるようになりました',
                                              ),
                                            ),
                                          );
                                    }
                                  }
                                : null,
                            child: Text('覚える ${yen(m.unlockCost)}'),
                          ),
                        )
                      else
                        const Text(
                          '提供中',
                          style: TextStyle(
                            fontSize: 10,
                            color: YohakuColors.moss,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
