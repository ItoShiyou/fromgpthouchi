import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand/handdrawn.dart';

import '../../core/brand/theme.dart';
import '../../core/engine/ambience.dart';
import '../../core/models/content.dart';
import '../../core/services/sound.dart';
import '../../core/state/game_controller.dart';
import '../../titles/yoru_kissa/cafe_scene.dart';
import '../../widgets/common.dart';

/// 06. 家具 ― 配置・変更。
///
/// 家具にステータスは無い。タグの組み合わせで「雰囲気」が生まれ、
/// 来る客・起きる出来事が少し変わる。
class FurnitureScreen extends ConsumerStatefulWidget {
  const FurnitureScreen({super.key});

  @override
  ConsumerState<FurnitureScreen> createState() => _FurnitureScreenState();
}

class _FurnitureScreenState extends ConsumerState<FurnitureScreen> {
  String? _selected;

  static const _tabs = ['すべて', 'テーブル', '椅子', '照明', '装飾', '音'];

  bool _inTab(ItemDef i, int tab) => switch (tab) {
    1 => i.slot == PlacementSlot.table || i.slot == PlacementSlot.counter,
    2 => i.slot == PlacementSlot.seat,
    3 => i.slot == PlacementSlot.light,
    4 => const {
      PlacementSlot.window,
      PlacementSlot.wall,
      PlacementSlot.corner,
    }.contains(i.slot),
    5 => i.kind != ItemKind.furniture,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final active = ref.watch(ambiencesProvider).map((a) => a.id).toSet();
    final resolver = AmbienceResolver(c);

    return PaperPage(
      title: '家具',
      tabs: _tabs,
      footer: _Footer(selected: _selected),
      builder: (context, tab) {
        final items = c.items.where((i) => _inTab(i, tab)).toList();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  children: [
                    for (final a in c.ambiences)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Tooltip(
                          message: active.contains(a.id)
                              ? a.description
                              : 'あと：${resolver.missing(a, s.placement.values).map((r) => r.count > 1 ? '${r.tag}×${r.count}' : r.tag).join('・')}',
                          triggerMode: TooltipTriggerMode.tap,
                          child: TagPill(
                            active.contains(a.id) ? '✓ ${a.name}' : a.name,
                            color: active.contains(a.id)
                                ? YohakuColors.wood
                                : YohakuColors.inkDim,
                            filled: active.contains(a.id),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
              sliver: SliverGrid.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
                children: [
                  for (final i in items)
                    _ItemCell(
                      item: i,
                      owned: s.ownedItems.contains(i.id),
                      inUse:
                          s.placement[i.slot] == i.id ||
                          s.activeBgm == i.id ||
                          s.activeEffects.contains(i.id),
                      selected: _selected == i.id,
                      onTap: () => setState(() => _selected = i.id),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ItemCell extends StatelessWidget {
  const _ItemCell({
    required this.item,
    required this.owned,
    required this.inUse,
    required this.selected,
    required this.onTap,
  });

  final ItemDef item;
  final bool owned;
  final bool inUse;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visible = owned || item.price != null;
    return PaperCard(
      onTap: onTap,
      highlight: selected,
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              IconTile(item.icon, size: 54, locked: !visible, artId: item.id),
              const SizedBox(height: 4),
              Text(
                visible ? item.name : '？？？',
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              Text(
                inUse
                    ? '使用中'
                    : owned
                    ? '所持'
                    : item.price != null
                    ? yen(item.price!)
                    : item.source.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: inUse
                      ? YohakuColors.wood
                      : owned
                      ? YohakuColors.moss
                      : YohakuColors.inkDim,
                ),
              ),
            ],
          ),
          if (inUse)
            Positioned(
              top: -2,
              right: -2,
              child: SketchIcon(
                Sketch.check,
                size: 16,
                color: YohakuColors.wood,
              ),
            ),
        ],
      ),
    );
  }
}

/// 下部：店のプレビュー＋選んだ家具の操作。
class _Footer extends ConsumerWidget {
  const _Footer({required this.selected});

  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(gameProvider);
    final c = ref.watch(contentProvider);
    final ctrl = ref.read(gameProvider.notifier);
    final item = selected == null ? null : c.item(selected!);

    String label;
    VoidCallback? action;
    if (item == null) {
      label = '家具を選んでください';
    } else if (!s.ownedItems.contains(item.id)) {
      if (item.price != null) {
        label = '購入して配置 ${yen(item.price!)}';
        action = s.money >= item.price!
            ? () {
                if (ctrl.buyItem(item.id)) {
                  ctrl.place(item.id);
                  ref.read(soundProvider).play(Se.stamp);
                }
              }
            : null;
      } else {
        label = '${item.source.label}で手に入ります';
      }
    } else if (item.kind == ItemKind.bgm) {
      final on = s.activeBgm == item.id;
      label = on ? 'BGM を止める' : 'BGM にする';
      action = () => ctrl.setBgm(on ? null : item.id);
    } else if (item.kind == ItemKind.effect) {
      final on = s.activeEffects.contains(item.id);
      label = on ? '演出をやめる' : '演出をつける';
      action = () => ctrl.toggleEffect(item.id);
    } else if (s.placement[item.slot] == item.id) {
      label = '片付ける';
      action = () => ctrl.clearSlot(item.slot!);
    } else {
      label = '配置する';
      action = () {
        ctrl.place(item.id);
        ref.read(soundProvider).play(Se.stamp);
      };
    }

    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, box) => ClipRect(
                child: OverflowBox(
                  maxHeight: box.maxWidth * 1.25,
                  alignment: const Alignment(0, 0.35),
                  child: SizedBox(
                    width: box.maxWidth,
                    height: box.maxWidth * 1.25,
                    child: CafeScene(
                      content: c,
                      moment: ctrl.currentMoment(),
                      placement: s.placement,
                      effects: s.activeEffects,
                      seated: const [],
                      showBubble: false,
                      onGuestTap: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (item != null)
            Positioned(
              left: 12,
              top: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: ShapeDecoration(
                  color: YohakuColors.paper.withValues(alpha: 0.92),
                  shape: RoughBorder(radius: 10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.ownedItems.contains(item.id) || item.price != null
                          ? item.name
                          : '？？？',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    if (s.ownedItems.contains(item.id) || item.price != null)
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: YohakuColors.inkDim,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Positioned(
            right: 12,
            bottom: 12,
            child: SizedBox(
              height: 42,
              child: FilledButton(
                style: FilledButton.styleFrom(elevation: 4),
                onPressed: action,
                child: Text(label),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
