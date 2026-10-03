import 'package:flutter/material.dart';

class CColors {
  CColors._();

  static const Color primaryColor = Color(0xFF4b68ff);
  static const Color secondaryColor = Color(0xFFFFE24B);
  static const Color accentColor = Color(0xFFb0c7ff);

  //gradient colors
  static const Gradient linerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xffff9a9e), Color(0xfffad0c4), Color(0xfffad0c4)],
  );

  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF6C757d);
  static const Color textWhite = Colors.white;

  static const Color backgroundLight = Color(0xfff6f6f6);
  static const Color backgroundDark = Color(0xff272727);
  static const Color primaryBackground = Color(0xfff3f5ff);

  static const Color lightContainer = Color(0xfff6f6f6);
  static Color darkContainer = CColors.textWhite.withValues(alpha: 0.1);

  static const Color buttonPrimary = Color(0xff4b68ff);
  static const Color buttonSecondary = Color(0xFF6c757d);
  static const Color buttonDisabled = Color(0xFFc4c4c4);

  static const Color borderPrimary = Color(0xffd9d9d9);
  static const Color borderSecondary = Color(0xffe6e6e6);

  static const Color error = Color(0xffd32f2f);
  static const Color success = Color(0xff388e3c);
  static const Color warning = Color(0xfff57c00);
  static const Color info = Color(0xff1976d2);

  static const Color black = Color(0xff232323);
  static const Color darkerGrey = Color(0xff4f4f4f);
  static const Color darkGrey = Color(0xff939393);
  static const Color grey = Color(0xffe0e0e0);
  static const Color softGrey = Color(0xfff4f4f4);
  static const Color lightGrey = Color(0xfff9f9f9);
  static const Color white = Colors.white;
}
