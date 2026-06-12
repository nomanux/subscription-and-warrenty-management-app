/// App theme (Material 3) — central place for brand + status colors.
///
/// Supports both light and dark themes with Material 3 design.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/product.dart';

/// Brand colors — green theme
const Color kPrimary = Color(0xFF11B082);
const Color kPrimaryDark = Color(0xFF0C8C66);
const Color kSecondary = Color(0xFF34C79D);

/// Light theme colors
const Color kBackground = Color(0xFFF6F8FB);
const Color kSurface = Colors.white;
const Color kInk = Color(0xFF0F172A);
const Color kMuted = Color(0xFF64748B);

/// Dark theme colors
const Color kBackgroundDark = Color(0xFF0F172A);
const Color kSurfaceDark = Color(0xFF1E293B);
const Color kInkDark = Color(0xFFF1F5F9);
const Color kMutedDark = Color(0xFF94A3B8);

/// Status colors used for warranty badges.
const Map<WarrantyStatus, Color> kStatusColors = {
  WarrantyStatus.active: Color(0xFF16A34A),
  WarrantyStatus.expiring: Color(0xFFD97706),
  WarrantyStatus.expired: Color(0xFFDC2626),
};

/// Soft tinted background for a status (used behind icons/badges).
Color statusTint(WarrantyStatus status) =>
    kStatusColors[status]!.withValues(alpha: 0.12);

/// A reusable soft card shadow for a modern, lifted look.
const List<BoxShadow> kCardShadow = [
  BoxShadow(
    color: Color(0x14000000),
    blurRadius: 18,
    offset: Offset(0, 8),
  ),
];

/// Light theme
ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kPrimary,
    primary: kPrimary,
    secondary: kSecondary,
    surface: kSurface,
    brightness: Brightness.light,
  );

  final baseText = GoogleFonts.interTextTheme().apply(
    bodyColor: kInk,
    displayColor: kInk,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBackground,
    textTheme: baseText,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: kBackground,
      foregroundColor: kInk,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kInk,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: kSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      hintStyle: const TextStyle(color: Color(0xFFB6BEC9), fontSize: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurface,
      elevation: 0,
      height: 68,
      indicatorColor: kPrimary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

/// Dark theme
ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kPrimary,
    primary: kPrimary,
    secondary: kSecondary,
    surface: kSurfaceDark,
    brightness: Brightness.dark,
  );

  final baseText = GoogleFonts.interTextTheme().apply(
    bodyColor: kInkDark,
    displayColor: kInkDark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBackgroundDark,
    textTheme: baseText,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: kBackgroundDark,
      foregroundColor: kInkDark,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kInkDark,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: kSurfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF334155),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurfaceDark,
      elevation: 0,
      height: 68,
      indicatorColor: kPrimary.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

/// Backward compatibility - returns light theme by default
ThemeData buildAppTheme() => buildLightTheme();
