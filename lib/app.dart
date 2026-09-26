import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/brand/theme.dart';
import 'core/state/game_controller.dart';
import 'features/furniture/furniture_screen.dart';
import 'features/gacha/gacha_screen.dart';
import 'features/home/home_screen.dart';
import 'features/menu/menu_screen.dart';
import 'features/report/report_sheet.dart';
import 'features/settings/settings_screen.dart';
import 'features/shop/shop_screen.dart';
import 'features/visitors/visitor_list_screen.dart';
import 'features/zukan/zukan_screen.dart';

class YohakuApp extends StatelessWidget {
  const YohakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'まちの余白：夜喫茶',
      debugShowCheckedModeBanner: false,
      theme: buildYohakuTheme(),
      home: const MainShell(),
    );
  }
}

/// 画面構成（MVP 10 画面）
///
/// 下タブ: 01 お店 / 03 お客さん / 05 図鑑 / 06 模様替え / 07 メニュー
/// 上部:   08 余白くじ / 09 ショップ / 10 設定
/// その他: 02 おかえりなさい（シート）/ 04 客詳細（お客さん・図鑑から）
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  int _tab = 0;
  Timer? _ticker;
  bool _reportOpen = false;

  /// アプリを開いている間も、ときどき時間を進める（新しい客が来る）。
  static const _liveInterval = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameProvider.notifier).catchUp(showReport: true);
    });
    _ticker = Timer.periodic(_liveInterval, (_) {
      ref.read(gameProvider.notifier).catchUp(showReport: false);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(gameProvider.notifier).catchUp(showReport: true);
    }
  }

  Future<void> _showReport() async {
    if (_reportOpen) return;
    _reportOpen = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: YohakuColors.ink,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ReportSheet(),
    );
    _reportOpen = false;
    ref.read(gameProvider.notifier).dismissReport();
    if (mounted) setState(() => _tab = 0);
  }

  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    ref.listen(gameProvider.select((s) => s.pendingReport), (prev, next) {
      if (next != null) _showReport();
    });
    ref.listen(noticeProvider, (prev, next) {
      if (next == null) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(next)));
      ref.read(noticeProvider.notifier).clear();
    });

    final money = ref.watch(gameProvider.select((s) => s.money));
    final tickets = ref.watch(gameProvider.select((s) => s.tickets));
    final content = ref.watch(contentProvider);

    const pages = [
      HomeScreen(),
      VisitorListScreen(),
      ZukanScreen(),
      FurnitureScreen(),
      MenuScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.brandName,
              style: const TextStyle(
                fontSize: 10,
                letterSpacing: 3,
                color: YohakuColors.paperDim,
              ),
            ),
            Text(content.titleName),
          ],
        ),
        actions: [
          _Chip(icon: Icons.payments_outlined, label: yen(money)),
          const SizedBox(width: 6),
          _Chip(icon: Icons.confirmation_number_outlined, label: '$tickets'),
          IconButton(
            tooltip: '余白くじ',
            icon: const Icon(Icons.redeem_outlined),
            onPressed: () => _push(const GachaScreen()),
          ),
          IconButton(
            tooltip: 'ショップ',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => _push(const ShopScreen()),
          ),
          IconButton(
            tooltip: '設定',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _push(const SettingsScreen()),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        height: 64,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_cafe_outlined),
            selectedIcon: Icon(Icons.local_cafe),
            label: 'お店',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'お客さん',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: '図鑑',
          ),
          NavigationDestination(
            icon: Icon(Icons.chair_outlined),
            selectedIcon: Icon(Icons.chair),
            label: '模様替え',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'メニュー',
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: YohakuColors.inkRaised,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: YohakuColors.lamp),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
