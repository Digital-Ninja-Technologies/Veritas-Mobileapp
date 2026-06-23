import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFFCFFC1);
  static const dark = Color(0xFF26230F);
  static const darkText = Color(0xFF372F01);
  static const yellow = Color(0xFFFEEA27);
  static const border = Color(0xFFECEAD2);
  static const subText = Color(0xFF9C9A7C);
  static const subText2 = Color(0xFF79775F);
  static const lightBg = Color(0xFFF1EFD6);
  static const cardBg = Color(0xFFFFFFFF);
  static const green = Color(0xFF3FCF6E);
  static const greenDark = Color(0xFF008751);
  static const red = Color(0xFFE54D2E);
  static const redDark = Color(0xFFC0362C);
  static const blue = Color(0xFF2D6BDB);
  static const orange = Color(0xFFC0500F);
  static const gold = Color(0xFF9A7B00);
  static const mutedText = Color(0xFFC9C6A6);

  // Badge colors
  static const activeBadgeBg = Color(0xFFE8F5EF);
  static const activeBadgeFg = Color(0xFF008751);
  static const pendingBadgeBg = Color(0xFFFFF3CC);
  static const pendingBadgeFg = Color(0xFF9A7B00);
  static const completeBadgeBg = Color(0xFFE3ECFF);
  static const completeBadgeFg = Color(0xFF2D6BDB);
}

ThemeData buildAppTheme() {
  final base = ThemeData.light();
  return base.copyWith(
    colorScheme: const ColorScheme.light(
      primary: AppColors.yellow,
      secondary: AppColors.dark,
      surface: AppColors.bg,
      error: AppColors.red,
    ),
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      bodyLarge: GoogleFonts.inter(color: AppColors.darkText),
      bodyMedium: GoogleFonts.inter(color: AppColors.darkText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.dark, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintStyle: const TextStyle(color: AppColors.subText, fontSize: 14.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.yellow,
        foregroundColor: AppColors.darkText,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        elevation: 0,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
