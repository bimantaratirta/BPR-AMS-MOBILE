import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../common/constant/app_colors.dart';

class BuildCustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType textInputType;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final double borderRadius;
  final int maxLines;
  final bool isReadOnly;
  final bool isEnable;
  final bool withInputFormatter;
  final List<TextInputFormatter>? formatter;
  final Function(String?)? onChanged;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final bool useOnTapOutside;

  const BuildCustomTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.textInputType = TextInputType.text,
    this.validator,
    this.borderRadius = 8,
    this.obscureText = false,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.suffixIcon,
    required this.maxLines,
    required this.isReadOnly,
    required this.isEnable,
    this.onChanged,
    required this.withInputFormatter,
    this.formatter,
    this.contentPadding,
    this.fillColor,
    this.useOnTapOutside = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: isReadOnly,
      enabled: isEnable,
      onChanged: onChanged,
      onTapOutside: useOnTapOutside
          ? (event) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          : null,
      controller: controller,
      maxLines: maxLines,
      keyboardType: textInputType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      inputFormatters: withInputFormatter ? formatter : [],
      style: Get.textTheme.bodyMedium!.copyWith(color: isEnable ? SecondaryColor.fontColour : SecondaryColor.neutral500),
      decoration: InputDecoration(
        fillColor: fillColor ?? SecondaryColor.neutral100,
        filled: true,
        hintText: hintText,
        hintStyle: Get.textTheme.bodyMedium!.copyWith(color: SecondaryColor.neutral500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(width: 2, color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(width: 2, color: Colors.transparent),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(width: 2, color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(width: 2, color: MainColor.blueLight3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(width: 2, color: SecondaryColor.danger600),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(width: 2, color: SecondaryColor.danger600),
        ),
        contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
