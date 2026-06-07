import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: isDark ? AppColors.secondaryDark : AppColors.secondary,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      surface: isDark ? AppColors.secondaryBackgroundDark : AppColors.secondaryBackground,
      onSurface: isDark ? AppColors.primaryTextDark : AppColors.primaryText,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AppColors.primaryBackgroundDark : AppColors.primaryBackground,
      textTheme: _textTheme(colorScheme, isDark),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.primaryBackgroundDark : AppColors.primaryBackground,
        foregroundColor: isDark ? AppColors.primaryTextDark : AppColors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.primaryTextDark : AppColors.primaryText,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.secondaryBackgroundDark : AppColors.secondaryBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2535) : const Color(0xFFF5F4FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2A3A50) : const Color(0xFFE5E3F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryDark : AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontSize: 14,
          color: (isDark ? AppColors.primaryTextDark : AppColors.primaryText).withOpacity(0.4),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.primaryBackgroundDark : AppColors.secondaryBackground,
        selectedItemColor: isDark ? AppColors.primaryDark : AppColors.primary,
        unselectedItemColor: isDark ? AppColors.secondaryTextDark : AppColors.secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.dividerDark : AppColors.divider,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
            ? (isDark ? AppColors.primaryDark : AppColors.primary)
            : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
            ? (isDark ? AppColors.primaryDark : AppColors.primary).withOpacity(0.5)
            : (isDark ? const Color(0xFF2A3A50) : const Color(0xFFE5E3F0))),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme cs, bool isDark) {
    final textColor = isDark ? AppColors.primaryTextDark : AppColors.primaryText;
    final subColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryText;
    return TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textColor, height: 1.2),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: textColor, height: 1.25),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textColor, height: 1.3),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor, height: 1.4),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor, height: 1.4),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textColor, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: subColor, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: subColor),
    );
  }
}
