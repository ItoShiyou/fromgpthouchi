import 'package:flutter/material.dart';

import 'core/brand/theme.dart';
import 'features/title/title_screen.dart';

class YohakuApp extends StatelessWidget {
  const YohakuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'まちの余白：夜喫茶',
      debugShowCheckedModeBanner: false,
      theme: buildYohakuTheme(),
      home: const TitleScreen(),
    );
  }
}

/// 画面構成
///
/// タイトル → お店（ホーム）。お店が常に基点で、下のアイコン列から紙のパネルを開く。
///   01 お店 / 02 おかえりなさい（ダイアログ）/ 03 来店客一覧 / 04 客詳細 / 05 図鑑
///   06 家具 / 07 メニュー / 08 余白くじ / 09 ショップ / 10 設定
///   ＋ タイトル・特別な出来事（ダイアログ）・シリーズ一覧
Route<void> fadeRoute(Widget page) => PageRouteBuilder<void>(
  transitionDuration: const Duration(milliseconds: 600),
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (_, a, _, child) =>
      FadeTransition(opacity: a, child: child),
);
