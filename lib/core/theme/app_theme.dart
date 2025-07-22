import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Yellow and White theme
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color lightYellow = Color(0xFFFFF8DC);
  static const Color darkYellow = Color(0xFFFFB000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);

  // Accent Colors
  static const Color darkGray = Color(0xFF333333);
  static const Color mediumGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color red = Color(0xFFFF4444);
  static const Color green = Color(0xFF4CAF50);

  // Meeting specific colors
  static const Color activeSpeakerBorder = Color(0xFFFFD700);
  static const Color mutedIndicator = Color(0xFFFF4444);
  static const Color recordingIndicator = Color(0xFFFF0000);

  // Gradient colors for splash screen
  static const Color gradientPurple = Color(0xFF8B5CF6);
  static const Color gradientPink = Color(0xFFEC4899);
  static const Color gradientOrange = Color(0xFFF59E0B);
  static const Color gradientYellow = Color(0xFFEAB308);

  // Gradient definitions
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientPurple, gradientPink, gradientOrange, gradientYellow],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        brightness: Brightness.light,
        primary: primaryYellow,
        onPrimary: darkGray,
        secondary: darkYellow,
        onSecondary: white,
        surface: white,
        onSurface: darkGray,
        background: offWhite,
        onBackground: darkGray,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkGray,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkGray,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: darkGray,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: darkGray,
        elevation: 4,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: darkGray,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: darkGray,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: darkGray,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: darkGray,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: darkGray,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: darkGray, fontSize: 16),
        bodyMedium: TextStyle(color: mediumGray, fontSize: 14),
        bodySmall: TextStyle(color: mediumGray, fontSize: 12),
      ),
    );
  }
}
