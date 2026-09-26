import 'package:flutter/material.dart';

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
  _Title('夜喫茶', '☕', [Color(0xFF3A2A4A), Color(0xFFD98A3E)], available: true),
  _Title('古本屋', '📚', [Color(0xFF4A3A2A), Color(0xFFB98A5A)]),
  _Title('海辺', '🐚', [Color(0xFF7FB6E6), Color(0xFFF6E3C4)]),
  _Title('銭湯', '♨️', [Color(0xFF2E4A5A), Color(0xFF9FC3CF)]),
  _Title('商店街', '🏮', [Color(0xFF3A2440), Color(0xFFE08A5A)]),
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
                      Center(
                        child: Text(
                          t.icon,
                          style: const TextStyle(fontSize: 46),
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
