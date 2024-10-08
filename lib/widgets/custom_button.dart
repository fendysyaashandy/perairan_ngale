import 'package:flutter/material.dart';
import 'package:perairan_ngale/shared/styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.text,
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.prefixIcon,
    this.isOutlined = false,
    this.isTextButton = false,
    this.isDense = false,
    this.width,
    this.padding,
    this.isCompact = false,
  });

  final VoidCallback? onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final bool isTextButton;
  final IconData? prefixIcon;
  final double? width;
  final EdgeInsets? padding;
  final bool isDense;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    var widget = _buildElevatedButton();
    if (isOutlined) {
      widget = _buildOutlinedButton();
    }

    if (isTextButton) {
      widget = _buildTextButton();
    }

    return Container(
      constraints: const BoxConstraints(
        minHeight: 50,
      ),
      width: width,
      child: widget,
    );
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: padding,
      ),
      onPressed: onPressed,
      child: _buildContentWidget(),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: padding,
        side: textColor == null ? null : BorderSide(color: textColor!),
      ),
      onPressed: onPressed,
      child: _buildContentWidget(),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor,
        padding: padding,
      ),
      onPressed: onPressed,
      child: _buildContentWidget(),
    );
  }

  Widget _buildContentWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isCompact)
          SizedBox(
            width: isDense ? Styles.mediumSpacing : Styles.biggerPadding,
          ),
        if (prefixIcon != null)
          Icon(
            prefixIcon,
            color: textColor,
          ),
        if (prefixIcon != null)
          const SizedBox(
            width: Styles.defaultSpacing,
          ),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: textColor),
            textAlign: TextAlign.center,
          ),
        ),
        if (!isCompact)
          SizedBox(
            width: isDense ? Styles.mediumSpacing : Styles.biggerPadding,
          ),
      ],
    );
  }
}
