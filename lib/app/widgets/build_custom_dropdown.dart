import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BuildDropdown extends StatelessWidget {
  final String selectedValue;
  final String selectedLabel;
  final String hintText;
  final List<Map<String, String>> itemDropdown;
  final void Function(String?)? onChanged;

  final EdgeInsetsGeometry? buttonPadding;
  final double? buttonBorderWidth;
  final Color? buttonBorderColor;
  final Color? buttonFocusedBorderColor;
  final double? buttonBorderRadius;
  final Color? buttonBackgroundColor;
  final Color? buttonTextColor;
  final double? buttonHeight;
  final double? buttonWidth;
  final double? iconSize;
  final double? iconRightGap;

  const BuildDropdown({
    super.key,
    required this.selectedValue,
    required this.selectedLabel,
    required this.itemDropdown,
    required this.onChanged,
    this.hintText = "Select item",
    this.buttonPadding,
    this.buttonBorderWidth,
    this.buttonBorderColor,
    this.buttonFocusedBorderColor,
    this.buttonBorderRadius,
    this.buttonBackgroundColor,
    this.buttonHeight,
    this.buttonWidth,
    this.iconSize,
    this.iconRightGap,
    this.buttonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = (buttonBorderRadius ?? 8).toDouble();
    final double bw = (buttonBorderWidth ?? 2).toDouble();
    final Color nonFocusColor = buttonBorderColor ?? Colors.transparent;
    final Color focusColor = buttonFocusedBorderColor ?? MainColor.blueLight3;
    final double _iconSize = (iconSize ?? 24);
    // final double _iconRightGap = (iconRightGap ?? 12);

    return SizedBox(
      width: buttonWidth ?? double.infinity,
      height: buttonHeight ?? 50.h,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          value: selectedValue.isNotEmpty ? selectedValue : null,
          hint: Text(
            hintText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Get.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.normal,
              color: onChanged == null ? MainColor.blueLight3 : SecondaryColor.neutral500,
            ),
          ),
          items:
              itemDropdown.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(
                    item['label'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Get.textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.normal,
                      color: SecondaryColor.blackCharcoal,
                    ),
                  ),
                );
              }).toList(),
          selectedItemBuilder: (context) {
            return itemDropdown.map((item) {
              final label = item['label'] ?? '';
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Get.textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.normal,
                        color: onChanged != null ? buttonTextColor ?? MainColor.blueLight3 : SecondaryColor.neutral500,
                      ),
                    ),
                  ),
                ],
              );
            }).toList();
          },
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(
            width: double.infinity,
            height: buttonHeight ?? 40.h,
            padding: buttonPadding ?? const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: onChanged != null ? buttonBackgroundColor ?? MainColor.blueLight2 : SecondaryColor.neutral200,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: nonFocusColor, width: bw),
            ),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: _iconSize),
            iconEnabledColor: focusColor,
          ),
          dropdownStyleData: DropdownStyleData(
            elevation: 0,
            offset: Offset(0, -8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: SecondaryColor.white,
              border: Border.all(color: SecondaryColor.neutral400),
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: 35.h,
            overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.pressed)) {
                return MainColor.greenLightHover;
              }
              return null;
            }),
          ),
        ),
      ),
    );
  }
}
