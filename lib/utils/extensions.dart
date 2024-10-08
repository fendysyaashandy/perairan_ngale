import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:perairan_ngale/shared/app_text_styles.dart';
import 'package:perairan_ngale/shared/app_theme_data.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';

// Extension on BuildContext for easy theme access
extension CustomThemeExtension on BuildContext {
  AppTextStyles get textTheme {
    final theme = AppTheme.of(this);
    assert(theme != null, 'No AppTheme found in context');
    return theme!.textTheme;
  }

  void showSnackBar({
    required String message,
    bool isSuccess = true,
    bool isTop = false,
  }) {
    final context = this;
    final backgroundColor =
        isSuccess ? ColorValues.success10 : ColorValues.danger10;
    final borderColor =
        isSuccess ? ColorValues.success20 : ColorValues.danger20;
    final color =
        isSuccess ? ColorValues.success50 : ColorValues.danger50;
    var flushbar = Flushbar();
    flushbar = Flushbar(
      flushbarPosition: isTop ? FlushbarPosition.TOP : FlushbarPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.symmetric(
        vertical: Styles.defaultPadding,
        horizontal: Styles.bigSpacing,
      ),
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(Styles.defaultBorder),
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      messageText: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Styles.smallerBorder),
              color: color,
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Icon(
                isSuccess
                    ? IconsaxPlusLinear.check
                    : IconsaxPlusLinear.info_circle,
                color: ColorValues.white,
                size: 16,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
              child:
                  Text(message, style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
          GestureDetector(
            onTap: () => flushbar.dismiss(),
            child: const Icon(
              IconsaxPlusLinear.close_circle,
              size: 16,
              color: ColorValues.text50,
            ),
          ),
        ],
      ),
    )

    ..show(context);
  }
}

/// Extension on [DateTime] to format it to a string with a specified locale.
extension FormattedDateTime on DateTime {
  /// Returns a formatted string representation of the [DateTime] object.
  ///
  /// The format of the string is "d MMMM y - HH:mm" by default, but can be
  /// customized by specifying a different [locale].
  String toFormattedString({String locale = 'id_ID'}) {
    final dateFormat = DateFormat('d MMMM y - HH:mm', locale);
    return dateFormat.format(this);
  }

  String toFormattedHour() {
    return DateFormat('HH:mm').format(this);
  }

  String toFormattedDate() {
    return DateFormat('d MMMM y').format(this);
  }

  String toFormattedShortDate() {
    return DateFormat('dd/MM/y').format(this);
  }

  String toFormattedDateWithHour() {
    return DateFormat('dd/MM/y HH:mm').format(this);
  }

  String toFormattedLongDateWithHour() {
    return DateFormat('dd MMMM y HH:mm').format(this);
  }

  String toYearMonthString() {
    return DateFormat('yyyyMM').format(this);
  }
}
