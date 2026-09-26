import 'package:flutter/material.dart';

import '../../core/brand/handdrawn.dart';
import '../../core/brand/theme.dart';
import '../../widgets/common.dart';

class _Title {
  const _Title(this.name, this.icon, this.colors, {this.available = false});

  final String name;
  final String icon;
  final List<Color> colors;
  final bool available;
}

const _series = [
  _Title('夜喫茶', '喫', [Color(0xFF3A2E3E), Color(0xFF3A2E3E)], available: true),
  _Title('古本屋', '本', [Color(0xFF5A4634), Color(0xFF5A4634)]),
  _Title('海辺', '浜', [Color(0xFF6F8FA3), Color(0xFF6F8FA3)]),
  _Title('銭湯', '湯', [Color(0xFF3E5A63), Color(0xFF3E5A63)]),
  _Title('商店街', '商', [Color(0xFF6B3E36), Color(0xFF6B3E36)]),
];

/// まちの余白 シリーズ一覧。
/// 作品を横断して遊べる「まちの余白」アプリの入口（将来構想のモック）。
class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaperPage(
      title: 'まちの余白 シリーズ',
      builder: (context, _) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const Text(
            'いろんな「まちの余白」を、\nのぞいてみませんか？',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.8, letterSpacing: 1),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [
              for (final t in _series)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: t.colors,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: const Alignment(0, -0.35),
                        child: InkGlyph(
                          t.icon,
                          size: 70,
                          color: const Color(0xFFF3E6CF),
                          locked: false,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xE6F5EDE0),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                t.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                t.available ? '営業中' : '準備中',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: t.available
                                      ? YohakuColors.wood
                                      : YohakuColors.inkDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '集めるのは、アイテムだけじゃない。\nこの世界の、小さな物語。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.9,
              color: YohakuColors.inkDim,
            ),
          ),
        ],
      ),
    );
  }
}
