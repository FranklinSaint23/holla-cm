import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/colors.dart';

class HollaTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: HollaColors.primary,
      primary: HollaColors.primary,
      secondary: HollaColors.secondary,
      error: HollaColors.error,
      background: HollaColors.grey100,
      surface: HollaColors.white,
    ),
    scaffoldBackgroundColor: HollaColors.grey100,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: HollaColors.white,
      foregroundColor: HollaColors.dark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w700,
        color: HollaColors.dark, fontFamily: 'Poppins',
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),

    // Cards — Gojek style : coins très arrondis, shadow douce
    cardTheme: CardThemeData(
      color: HollaColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.zero,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: HollaColors.primary,
        foregroundColor: HollaColors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: HollaColors.primary,
        side: const BorderSide(color: HollaColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
    ),

    // Input fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: HollaColors.grey100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HollaColors.grey300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HollaColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: HollaColors.error, width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: HollaColors.grey500, fontSize: 14,
        fontFamily: 'Poppins',
      ),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: HollaColors.white,
      selectedItemColor: HollaColors.primary,
      unselectedItemColor: HollaColors.grey500,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 11, fontFamily: 'Poppins',
      ),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: HollaColors.grey100,
      thickness: 1,
      space: 0,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: HollaColors.grey100,
      selectedColor: HollaColors.primaryLight,
      labelStyle: const TextStyle(
        fontSize: 13, fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );

  // ── Mode sombre ───────────────────────────────────────────
  static ThemeData get dark => light.copyWith(
    scaffoldBackgroundColor: HollaColors.darkBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: HollaColors.primary,
      brightness: Brightness.dark,
      primary: HollaColors.primary,
      background: HollaColors.darkBg,
      surface: HollaColors.darkCard,
    ),
    cardTheme: CardThemeData(
      color: HollaColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: HollaColors.darkCard,
      foregroundColor: HollaColors.darkText,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
  );
}