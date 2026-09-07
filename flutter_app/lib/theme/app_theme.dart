import 'package:flutter/material.dart';

/// Color palette inspired by traditional Japanese pigments:
/// ai (indigo), washi (paper), shu (vermillion torii red), sumi (ink).
class AppColors {
  static const ai = Color(0xFF1B3A5C);
  static const aiDark = Color(0xFF122A44);
  static const shu = Color(0xFFBF3B26);
  static const washi = Color(0xFFF6F3EC);
  static const surface = Color(0xFFFFFFFF);
  static const sumi = Color(0xFF262220);
  static const sumiMuted = Color(0xFF5B564F);
  static const matcha = Color(0xFF3C7A54);
  static const line = Color(0xFFE4DFD3);
}

const _sans = 'Noto Sans Thai';
const _serif = 'Noto Serif Thai';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ai,
        primary: AppColors.ai,
        secondary: AppColors.shu,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.washi,
    );

    const textTheme = TextTheme(
      headlineSmall: TextStyle(fontFamily: _serif, fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.sumi),
      titleLarge: TextStyle(fontFamily: _serif, fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.sumi),
      titleMedium: TextStyle(fontFamily: _sans, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.sumi),
      bodyMedium: TextStyle(fontFamily: _sans, fontSize: 14, color: AppColors.sumiMuted, height: 1.5),
      bodyLarge: TextStyle(fontFamily: _sans, fontSize: 15, color: AppColors.sumi, height: 1.6),
      labelLarge: TextStyle(fontFamily: _sans, fontWeight: FontWeight.w600),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ai,
        foregroundColor: AppColors.washi,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontFamily: _serif, color: AppColors.washi, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: AppColors.line)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.ai,
        labelStyle: const TextStyle(fontFamily: _sans, fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.sumi),
        secondaryLabelStyle: const TextStyle(fontFamily: _sans, fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.washi),
        side: const BorderSide(color: AppColors.line),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        hintStyle: const TextStyle(fontFamily: _sans, color: AppColors.sumiMuted, fontSize: 14),
      ),
    );
  }
}
