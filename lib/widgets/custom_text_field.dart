import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';
import 'package:perairan_ngale/utils/validator.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    required this.controller,
    super.key,
    this.hintText,
    this.prefixIcon,
    this.fillColor,
    this.borderWidth = 1,
    this.label,
    this.isRequired = true,
    this.validator,
    this.onChanged,
    this.maxCharacter,
    this.maxLines = 1,
    this.inputFormatters,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.suffixIconOnPressed,
    this.onFieldSubmitted,
    this.initialValue,
    this.enabled,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool? enabled;
  final String? label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? initialValue;
  final Color? fillColor;
  final double borderWidth;
  final void Function(String)? onFieldSubmitted;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final int? maxCharacter;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? suffixIconOnPressed;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        Styles.defaultBorder,
      ),
      borderSide: BorderSide(
        color: borderWidth == 0 ? Colors.transparent : ColorValues.grey10,
        width: borderWidth,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: context.textTheme.titleMedium,
          ),
        if (label != null)
          const SizedBox(
            height: Styles.defaultSpacing,
          ),
        TextFormField(
          initialValue: initialValue,
          enabled: enabled,
          maxLength: maxCharacter,
          controller: controller,
          onChanged: onChanged,
          maxLines: maxLines,
          onFieldSubmitted: onFieldSubmitted,
          validator: isRequired
              ? (validator ?? Validator(context: context).emptyValidator)
              : validator,
          style: context.textTheme.bodyMedium,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            filled: fillColor != null,
            fillColor: fillColor,
            hintStyle: context.textTheme.bodySmallGrey,
            border: border,
            enabledBorder: border,
            focusedErrorBorder: border,
            focusedBorder: border,
            errorBorder: border,
            disabledBorder: border,
            prefixIconConstraints: prefixIcon == null
                ? null
                : const BoxConstraints(
                    minWidth: 58,
                  ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    size: 24,
                    color: ColorValues.grey50,
                  ),
            prefixIconColor: MaterialStateColor.resolveWith(
              (states) => states.contains(MaterialState.focused)
                  ? Theme.of(context).primaryColor
                  : ColorValues.grey50,
            ),
            suffixIcon: suffixIcon == null
                ? null
                : IconButton(
                    icon: Icon(
                      suffixIcon,
                      size: 24,
                      color: ColorValues.grey50,
                    ),
                    onPressed: suffixIconOnPressed,
                  ),
            suffixIconColor: MaterialStateColor.resolveWith(
              (states) => states.contains(MaterialState.focused)
                  ? Theme.of(context).primaryColor
                  : ColorValues.grey50,
            ),
          ),
        ),
      ],
    );
  }
}
