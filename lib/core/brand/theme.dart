import 'package:flutter/material.dart';

/// 「まちの余白」ブランド共通の色。
///
/// 夜の紺地に、クリーム色の紙のパネルと、焦げ茶のインク・ボタン。
/// シリーズで共通なのはロゴ・UI・音・色・イラストの作法だけで、
/// タイトルごとの差分はアクセント程度にとどめる。
abstract final class YohakuColors {
  // 夜（背景）
  static const night = Color(0xFF1D2640);
  static const nightDeep = Color(0xFF121829);
  static const nightLine = Color(0xFF3A4566);
  static const starlight = Color(0xFFEDE6D8);

  // 紙（パネル）
  static const paper = Color(0xFFF5EDE0);
  static const paperDeep = Color(0xFFEADFCC);
  static const paperLine = Color(0xFFD9C9B0);

  // インク（紙の上の文字）
  static const ink = Color(0xFF4A3A2E);
  static const inkDim = Color(0xFF8E7C6A);

  // 木とランプ
  static const wood = Color(0xFF8A5A3B);
  static const woodDark = Color(0xFF5E3C27);
  static const lamp = Color(0xFFE6B66E);
  static const cream = Color(0xFFF3DDB0);
  static const moss = Color(0xFF7FA394);
  static const rose = Color(0xFFD9695B);
}

ThemeData buildYohakuTheme() {
  const scheme = ColorScheme.light(
    primary: YohakuColors.wood,
    onPrimary: YohakuColors.paper,
    secondary: YohakuColors.lamp,
    onSecondary: YohakuColors.ink,
    surface: YohakuColors.paper,
    onSurface: YohakuColors.ink,
    surfaceContainerHighest: YohakuColors.paperDeep,
    outline: YohakuColors.paperLine,
    error: YohakuColors.rose,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: YohakuColors.night,
    textTheme: base.textTheme.apply(
      bodyColor: YohakuColors.ink,
      displayColor: YohakuColors.ink,
    ),
    dividerTheme: const DividerThemeData(color: YohakuColors.paperLine),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: YohakuColors.wood,
        foregroundColor: YohakuColors.paper,
        disabledBackgroundColor: YohakuColors.paperLine,
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: YohakuColors.paper),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: YohakuColors.paper,
      contentTextStyle: TextStyle(color: YohakuColors.ink),
      behavior: SnackBarBehavior.floating,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? YohakuColors.paper
            : YohakuColors.inkDim,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? YohakuColors.wood
            : YohakuColors.paperDeep,
      ),
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

/// 「8 時間 12 分」
String hmJa(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60;
  if (h == 0) return '$m 分';
  return m == 0 ? '$h 時間' : '$h 時間 $m 分';
}
