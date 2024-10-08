import 'package:flutter/material.dart';
import 'package:perairan_ngale/shared/color_values.dart';
import 'package:perairan_ngale/shared/styles.dart';
import 'package:perairan_ngale/utils/extensions.dart';
import 'package:perairan_ngale/utils/validator.dart';

class CustomDropdownField<T> extends StatelessWidget {
  const CustomDropdownField({
    required this.value,
    super.key,
    this.hintText,
    this.prefixIcon,
    this.fillColor,
    this.borderWidth = 1,
    this.label,
    this.isRequired = true,
    this.validator,
    required this.items,
    required this.onChanged,
    this.enabled,
    this.suffixIcon,
    this.suffixIconOnPressed,
  });

  final T? value;
  final String? hintText;
  final bool? enabled;
  final String? label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color? fillColor;
  final double borderWidth;
  final bool isRequired;
  final String? Function(T?)? validator;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
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
        InputDecorator(
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isDense: true,
              isExpanded: true,
              items: items,
              onChanged: onChanged,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
