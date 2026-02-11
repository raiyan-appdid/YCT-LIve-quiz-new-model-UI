import 'package:flutter/material.dart';

class AppColors {
  // Brand coral palette based on provided logo
  static const Color primary = Color(0xFFFF5A5A); // brand coral
  static const Color primaryVariant = Color(0xFFCC4747); // darker coral
  static const Color secondary = Color(0xFFFF8A80); // light coral accent
  static const Color secondaryVariant = Color(0xFFCC6A6A);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F7);
  static const Color error = Color(0xFFD32F2F);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
  static const Color onError = Colors.white;

  static const Color correct = Color(0xFF4CAF50);
  static const Color incorrect = Color(0xFFF44336);
  static const Color timer = Color(0xFFFFB74D);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onBackground,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    color: AppColors.onBackground,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    color: Color(0xFF616161),
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.onPrimary,
  );
}
