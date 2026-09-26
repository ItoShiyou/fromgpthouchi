import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/brand/theme.dart';
import '../../titles/yoru_kissa/exterior_painter.dart';
import '../home/home_screen.dart';
import '../series/series_screen.dart';
import '../settings/settings_screen.dart';

/// タイトル。「まちの余白」のロゴと、夜喫茶の外観。
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: ExteriorPainter(animation: _anim)),
          ),
          // 下の方を暗くして文字を読みやすく
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.3, 0.75, 1],
                  colors: [
                    Color(0x66000000),
                    Color(0x00000000),
                    Color(0x00000000),
                    Color(0xCC0B1024),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings, color: YohakuColors.paper),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const _Logo(),
                const Spacer(),
                const Text(
                  'ほんの少しだけ、\n特別な時間を。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: YohakuColors.paper,
                    fontSize: 15,
                    height: 1.9,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: 210,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: YohakuColors.cream,
                      foregroundColor: YohakuColors.ink,
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                      ),
                      elevation: 6,
                    ),
                    onPressed: () =>
                        Navigator.of(context)
                            .pushReplacement(fadeRoute(const HomeScreen())),
                    child: const Text('はじめる'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SeriesScreen(),
                    ),
                  ),
                  child: const Text(
                    'まちの余白 シリーズ',
                    style: TextStyle(
                      color: Color(0xCCF5EDE0),
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 「まちの余白」ロゴ（シリーズ共通）＋タイトル名。
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    const shadow = [Shadow(color: Color(0xAA000000), blurRadius: 12)];
    return Transform.rotate(
      angle: -0.06,
      child: Column(
        children: [
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'まち'),
                TextSpan(text: 'の', style: TextStyle(fontSize: 26)),
                TextSpan(text: '余白'),
              ],
            ),
            style: TextStyle(
              color: YohakuColors.paper,
              fontSize: 42,
              fontWeight: FontWeight.w500,
              letterSpacing: 6,
              shadows: shadow,
            ),
          ),
          Container(
            width: 190,
            height: 1.5,
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: YohakuColors.paper,
          ),
          const Text(
            '夜喫茶',
            style: TextStyle(
              color: YohakuColors.paper,
              fontSize: 22,
              letterSpacing: 8,
              shadows: shadow,
            ),
          ),
        ],
      ),
    );
  }
}
