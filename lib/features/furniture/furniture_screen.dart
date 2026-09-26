import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/theme.dart';
import '../../core/engine/ambience.dart';
import '../../core/models/content.dart';
import '../../core/state/game_controller.dart';
import '../../widgets/common.dart';

/// 06. 家具 ― 配置・変更。
///
/// 家具にステータスは無い。タグの組み合わせで「雰囲気」が生まれ、
/// 来る客・起きる出来事が少し変わる。
class FurnitureScreen extends ConsumerWidget {
  const FurnitureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final resolver = AmbienceResolver(c);
    final active = ref.watch(ambiencesProvider).map((a) => a.id).toSet();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        const SectionTitle('お店の雰囲気'),
        for (final a in c.ambiences)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 136,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TagPill(
                      a.name,
                      filled: active.contains(a.id),
                      color: active.contains(a.id)
                          ? YohakuColors.lamp
                          : YohakuColors.moss,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    active.contains(a.id)
                        ? a.description
                        : 'あと：${resolver.missing(a, s.placement.values).map((r) => r.count > 1 ? '${r.tag}×${r.count}' : r.tag).join('・')}'
                              '${a.minSatisfied < a.requirements.length ? '（${a.minSatisfied}つでよい）' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: YohakuColors.paperDim,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        for (final slot in PlacementSlot.values) ...[
          SectionTitle(
            slot.label,
            trailing: s.placement[slot] == null
                ? null
                : TextButton(
                    onPressed: () => ctrl.clearSlot(slot),
                    child: const Text('片付ける'),
                  ),
          ),
          ...c.items
              .where(
                (i) =>
                    i.slot == slot &&
                    (s.ownedItems.contains(i.id) || i.price != null),
              )
              .map((i) {
                final owned = s.ownedItems.contains(i.id);
                final placed = s.placement[slot] == i.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: placed ? YohakuColors.lamp : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      title: Text(i.name),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [for (final t in i.tags) TagPill(t)],
                        ),
                      ),
                      trailing: placed
                          ? const Text(
                              '置いてある',
                              style: TextStyle(
                                color: YohakuColors.lamp,
                                fontSize: 12,
                              ),
                            )
                          : owned
                          ? OutlinedButton(
                              onPressed: () => ctrl.place(i.id),
                              child: const Text('置く'),
                            )
                          : FilledButton.tonal(
                              onPressed: s.money >= i.price!
                                  ? () => _buy(context, ref, i)
                                  : null,
                              child: Text(yen(i.price!)),
                            ),
                    ),
                  ),
                );
              }),
        ],
        const SectionTitle('BGM'),
        Card(
          child: RadioGroup<String?>(
            groupValue: s.activeBgm,
            onChanged: ctrl.setBgm,
            child: Column(
              children: [
                const RadioListTile<String?>(
                  value: null,
                  title: Text('店の物音だけ'),
                ),
                for (final i in c.items.where(
                  (i) => i.kind == ItemKind.bgm && s.ownedItems.contains(i.id),
                ))
                  RadioListTile<String?>(
                    value: i.id,
                    title: Text(i.name.replaceFirst('BGM：', '')),
                  ),
              ],
            ),
          ),
        ),
        const SectionTitle('演出'),
        Card(
          child: Column(
            children: [
              for (final i in c.items.where((i) => i.kind == ItemKind.effect))
                SwitchListTile(
                  value: s.activeEffects.contains(i.id),
                  onChanged: s.ownedItems.contains(i.id)
                      ? (_) => ctrl.toggleEffect(i.id)
                      : null,
                  title: Text(
                    s.ownedItems.contains(i.id)
                        ? i.name.replaceFirst('演出：', '')
                        : '？？？',
                  ),
                  subtitle: Text(
                    s.ownedItems.contains(i.id)
                        ? i.description
                        : '入手方法：${i.source.label}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: YohakuColors.paperDim,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '余白くじ・セットで手に入れたものも、ここに並びます。',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: YohakuColors.paperDim),
        ),
      ],
    );
  }

  void _buy(BuildContext context, WidgetRef ref, ItemDef i) {
    final ctrl = ref.read(gameProvider.notifier);
    if (ctrl.buyItem(i.id)) {
      ctrl.place(i.id);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('「${i.name}」を置きました')));
    }
  }
}
