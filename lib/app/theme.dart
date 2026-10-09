import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.text,
        secondary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        onSurfaceVariant: AppColors.mutedText,
        outlineVariant: AppColors.search,
        error: AppColors.destructive,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 30,
          height: 1.15,
          fontWeight: FontWeight.w500,
          letterSpacing: -.7,
          color: AppColors.text,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          height: 1.25,
          fontWeight: FontWeight.w500,
          letterSpacing: -.4,
          color: AppColors.text,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w500,
          letterSpacing: -.25,
          color: AppColors.text,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          height: 1.35,
          letterSpacing: -.25,
          color: AppColors.text,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          height: 1.4,
          color: AppColors.mutedText,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w400,
          letterSpacing: .5,
          color: AppColors.mutedText,
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 52,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.text,
        ),
        iconTheme: IconThemeData(color: AppColors.primary, size: 22),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: TextStyle(
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w400,
          color: AppColors.text,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: AppColors.mutedText,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.search,
        thickness: .5,
        space: 1,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: AppColors.primary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.actionText,
          minimumSize: const Size(44, 44),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        color: AppColors.bar,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.text,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class AppColors {
  static const Color primary = Color.fromRGBO(228, 174, 10, 1);
  static const Color search = Color.fromRGBO(228, 227, 233, 1);
  static const Color bar = Color.fromRGBO(247, 247, 248, 1);
  static const Color background = Color.fromRGBO(243, 242, 248, 1);
  static const Color surface = Color.fromRGBO(255, 255, 255, 1);
  static const Color text = Color.fromRGBO(0, 0, 0, 1);
  static const Color mutedText = Color.fromRGBO(110, 109, 116, 1);
  static const Color actionText = Color(0xFF806000);
  static const Color destructive = Color(0xFFCC3434);
}
