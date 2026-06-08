/// App theme (Material 3) — central place for brand + status colors.
///
/// Modern refresh: Inter typography (via google_fonts), a soft cool-gray
/// background, rounded surfaces, and gentle shadows.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/product.dart';

/// Brand colors — warm coral/orange (inspired by the EGOVERN reference).
const Color kPrimary = Color(0xFFF15A2B);
const Color kPrimaryDark = Color(0xFFD9481C);
const Color kSecondary = Color(0xFFFB8C5A);

/// Surfaces.
const Color kBackground = Color(0xFFF6F8FB);
const Color kSurface = Colors.white;

/// Text.
const Color kInk = Color(0xFF0F172A);
const Color kMuted = Color(0xFF64748B);

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

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kPrimary,
    primary: kPrimary,
    secondary: kSecondary,
    surface: kSurface,
  );

  final baseText = GoogleFonts.interTextTheme().apply(
    bodyColor: kInk,
    displayColor: kInk,
  );

  return ThemeData(
    useMaterial3: true,
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
