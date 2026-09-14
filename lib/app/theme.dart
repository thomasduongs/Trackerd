import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
    );
  }
}

class AppColors {
  // Brand colors (pick whatever you want)
  static const Color primary = Color.fromRGBO(228, 174, 10, 1);
  static const Color search = Color.fromRGBO(228, 227, 233, 1);
  static const Color bar = Color.fromRGBO(247, 247, 248, 1);
  static const Color background = Color.fromRGBO(243, 242, 248, 1);
  static const Color surface = Color.fromRGBO(255, 255, 255, 1);

  static const Color text = Color.fromRGBO(0, 0, 0, 1);
  static const Color mutedText = Color.fromRGBO(137, 136, 142, 1);
}
