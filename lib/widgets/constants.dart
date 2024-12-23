import 'package:flutter/material.dart';

class AppColor {
  static const Color primaryColor = Color(0xFFDA7B92);
  static const Color backgroundColor = Color(0xFF181818);
  static const Color buttonColor = Color(0xFF2f2f2f);
  static const Color buttonSelectedColor = Color(0xFF606060);
  static const Color buttonActiveColor = Color(0xFF115D25);
  static const Color buttonInactiveColor = Color(0xFF5D1111);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFA4A4A4);
  static const Color borderColor = Color(0x80000000);
  static const Color errorColor = Color(0x80ff3333);
}
class AppFontSize {
  /// 16.0
  static const double body = 16.0;

  /// 24.0
  static const double title = 24.0;

  /// 28.0
  static const double titleLarge = 28.0;

  /// 12.0
  static const double caption = 12.0;

  static double rem(double multiplier) => multiplier * 16.0;

  final double size;
  const AppFontSize(this.size);

  double em(double multiplier) => multiplier * size;
}

enum AppFont {
  placeholder;
}
