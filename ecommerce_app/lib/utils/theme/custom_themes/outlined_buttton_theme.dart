import 'package:ecommerce_app/utils/constants/colors.dart';
import 'package:ecommerce_app/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class COutlineButtonTheme {
  COutlineButtonTheme._();

  static final lightOutlineButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: CColors.backgroundDark,
      side: const BorderSide(color: CColors.borderPrimary),
      padding: const EdgeInsets.symmetric(
        vertical: CSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(CSizes.buttonRadius),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        color: CColors.black,
        fontWeight: FontWeight.w600,
        fontFamily: GoogleFonts.urbanist().fontFamily,
      ),
    ),
  );
  static final darkOutlineButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: CColors.backgroundLight,
      side: const BorderSide(color: CColors.borderPrimary),
      padding: const EdgeInsets.symmetric(
        vertical: CSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(CSizes.buttonRadius),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        color: CColors.textWhite,
        fontWeight: FontWeight.w600,
        fontFamily: GoogleFonts.urbanist().fontFamily,
      ),
    ),
  );
}
