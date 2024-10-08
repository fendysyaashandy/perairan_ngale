import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perairan_ngale/shared/color_values.dart';

const _extraLargeFontSize = 36.0;
const _largerFontSize = 32.0;
const _largeFontSize = 22.0;
const _mediumFontSize = 18.0;
const _smallFontSize = 13.0;
const _extraSmallFontSize = 11.0;
const _regular = FontWeight.w400;
const _bold = FontWeight.w700;
const _semiBold = FontWeight.w600;
const _brightTextColor = ColorValues.secondaryText50;

class AppTextStyles extends TextTheme {
  const AppTextStyles({
    required this.context,
    required this.titleSmallBright,
    required this.titleMediumBright,
    required this.titleLargeBright,
    required this.bodyMediumBright,
    required this.bodyMediumSemiBold,
    required this.bodyMediumSemiBoldBright,
    required this.bodyMediumBold,
    required this.bodyMediumBoldBright,
    required this.bodySmallBright,
    required this.bodySmallSemiBold,
    required this.bodySmallSemiBoldBright,
    required this.bodySmallBold,
    required this.bodySmallBoldBright,
    required this.bodyExtraSmall,
    required this.labelSmallThin,
    required this.titleExtraLarge,
  });

  factory AppTextStyles.style(BuildContext context) {
    final titleSmallBright = GoogleFonts.plusJakartaSans(
      color: _brightTextColor,
      fontSize: _smallFontSize,
      fontWeight: _bold,
    );
    final titleMediumBright = GoogleFonts.plusJakartaSans(
      color: _brightTextColor,
      fontSize: _mediumFontSize,
      fontWeight: _bold,
    );
    final titleLargeBright = GoogleFonts.plusJakartaSans(
      color: _brightTextColor,
      fontSize: _largeFontSize,
      fontWeight: _bold,
    );

    final bodyMediumBright = GoogleFonts.plusJakartaSans(
      color: _brightTextColor,
      fontSize: _mediumFontSize,
      fontWeight: _regular,
    );
    final bodyMediumSemiBold = GoogleFonts.plusJakartaSans(
      color: ColorValues.text50,
      fontSize: _mediumFontSize,
      fontWeight: _semiBold,
    );
    final bodyMediumSemiBoldBright = bodyMediumSemiBold.copyWith(
      color: _brightTextColor,
    );
    final bodyMediumBold = GoogleFonts.plusJakartaSans(
      color: ColorValues.text50,
      fontSize: _mediumFontSize,
      fontWeight: _bold,
    );
    final bodyMediumBoldBright = bodyMediumBold.copyWith(
      color: _brightTextColor,
    );

    final bodySmallBright = GoogleFonts.plusJakartaSans(
      color: _brightTextColor,
      fontSize: _smallFontSize,
      fontWeight: _regular,
    );
    final bodySmallSemiBold = GoogleFonts.plusJakartaSans(
      color: ColorValues.text50,
      fontSize: _smallFontSize,
      fontWeight: _semiBold,
    );
    final bodySmallSemiBoldBright = bodySmallSemiBold.copyWith(
      color: _brightTextColor,
    );
    final bodySmallBold = GoogleFonts.plusJakartaSans(
      color: ColorValues.text50,
      fontSize: _smallFontSize,
      fontWeight: _bold,
    );
    final bodySmallBoldBright = bodySmallBold.copyWith(
      color: _brightTextColor,
    );
    final bodyExtraSmall = GoogleFonts.plusJakartaSans(
      color: ColorValues.text50,
      fontSize: _extraSmallFontSize,
    );

    final labelSmallThin = GoogleFonts.plusJakartaSans(
      color: ColorValues.text50,
      fontSize: _smallFontSize,
      fontWeight: FontWeight.w100,
    );

    final titleExtraLarge = GoogleFonts.plusJakartaSans(
      color: ColorValues.text50,
      fontSize: _extraLargeFontSize,
      fontWeight: FontWeight.w700,
    );

    return AppTextStyles(
      context: context,
      bodyMediumSemiBold: bodyMediumSemiBold,
      bodyMediumSemiBoldBright: bodyMediumSemiBoldBright,
      bodyMediumBold: bodyMediumBold,
      bodyMediumBoldBright: bodyMediumBoldBright,
      bodySmallSemiBold: bodySmallSemiBold,
      bodySmallSemiBoldBright: bodySmallSemiBoldBright,
      bodySmallBold: bodySmallBold,
      bodySmallBoldBright: bodySmallBoldBright,
      bodyMediumBright: bodyMediumBright,
      bodySmallBright: bodySmallBright,
      titleLargeBright: titleLargeBright,
      titleMediumBright: titleMediumBright,
      titleSmallBright: titleSmallBright,
      labelSmallThin: labelSmallThin,
      titleExtraLarge: titleExtraLarge,
      bodyExtraSmall: bodyExtraSmall,
    );
  }

  final BuildContext context;
  final TextStyle titleSmallBright;
  final TextStyle titleMediumBright;
  final TextStyle titleLargeBright;
  final TextStyle bodyMediumBright;
  final TextStyle bodyMediumSemiBold;
  final TextStyle bodyMediumSemiBoldBright;
  final TextStyle bodyMediumBold;
  final TextStyle bodyMediumBoldBright;
  final TextStyle bodySmallBright;
  final TextStyle bodySmallSemiBold;
  final TextStyle bodySmallSemiBoldBright;
  final TextStyle bodySmallBold;
  final TextStyle bodySmallBoldBright;
  final TextStyle labelSmallThin;
  final TextStyle titleExtraLarge;
  final TextStyle bodyExtraSmall;

  @override
  TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      );

  @override
  TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: 19,
        fontWeight: FontWeight.w300,
      );

  @override
  TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: 13,
        fontWeight: FontWeight.bold,
      );

  @override
  TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: 34,
        fontWeight: _regular,
      );

  @override
  TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: 24,
        fontWeight: _regular,
      );

  TextStyle get titleLarger => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: _largerFontSize,
        fontWeight: FontWeight.w700,
      );

  @override
  TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: _largeFontSize,
        fontWeight: FontWeight.w700,
      );

  @override
  TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: _mediumFontSize,
        fontWeight: FontWeight.w700,
      );

  @override
  TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: _smallFontSize,
        fontWeight: FontWeight.w700,
      );

  @override
  TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: _largeFontSize,
        fontWeight: _regular,
      );


  TextStyle get bodyLargeBold => GoogleFonts.plusJakartaSans(
    color: ColorValues.text50,
    fontSize: _largeFontSize,
    fontWeight: _bold,
  );

  TextStyle get bodyVeryLargeBold => GoogleFonts.plusJakartaSans(
    color: ColorValues.text50,
    fontSize: _extraLargeFontSize,
    fontWeight: _bold,
  );
  @override
  TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: _mediumFontSize,
        fontWeight: _regular,
      );

  @override
  TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: _smallFontSize,
        fontWeight: _regular,
      );

  TextStyle get bodySmallGrey => GoogleFonts.plusJakartaSans(
    color: ColorValues.grey50,
    fontSize: _smallFontSize,
    fontWeight: _regular,
  );

  @override
  TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );

  @override
  TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        color: ColorValues.text50,
        fontSize: 10,
        fontWeight: FontWeight.w400,
      );
}
