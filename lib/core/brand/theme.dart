import 'package:flutter/material.dart';

/// 「まちの余白」ブランド共通の色。
///
/// シリーズで共通なのはロゴ・UI・音・色・イラストの作法だけ。
/// タイトルごとの差分は [accent] 程度にとどめる。
abstract final class YohakuColors {
  static const ink = Color(0xFF1B1D26); // 夜の地
  static const inkRaised = Color(0xFF252834); // カード
  static const inkLine = Color(0xFF3A3E4C);
  static const paper = Color(0xFFEDE6D8); // 本文
  static const paperDim = Color(0xFFA9A396); // 補足
  static const lamp = Color(0xFFE6A85C); // 灯り（夜喫茶のアクセント）
  static const moss = Color(0xFF8FB3AE); // 余白の色
  static const rose = Color(0xFFD98C84); // 新着・注意
}

ThemeData buildYohakuTheme() {
  const scheme = ColorScheme.dark(
    primary: YohakuColors.lamp,
    onPrimary: YohakuColors.ink,
    secondary: YohakuColors.moss,
    onSecondary: YohakuColors.ink,
    surface: YohakuColors.ink,
    onSurface: YohakuColors.paper,
    surfaceContainerHighest: YohakuColors.inkRaised,
    outline: YohakuColors.inkLine,
    error: YohakuColors.rose,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: YohakuColors.ink,
    appBarTheme: const AppBarTheme(
      backgroundColor: YohakuColors.ink,
      foregroundColor: YohakuColors.paper,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: YohakuColors.paper,
      ),
    ),
    cardTheme: const CardThemeData(
      color: YohakuColors.inkRaised,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: YohakuColors.inkRaised,
      indicatorColor: YohakuColors.lamp.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, letterSpacing: 0.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: YohakuColors.inkLine),
    textTheme: base.textTheme.apply(
      bodyColor: YohakuColors.paper,
      displayColor: YohakuColors.paper,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: YohakuColors.paper,
      contentTextStyle: TextStyle(color: YohakuColors.ink),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

String yen(int v) {
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}¥$buf';
}

String hm(Duration d) =>
    '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}';
