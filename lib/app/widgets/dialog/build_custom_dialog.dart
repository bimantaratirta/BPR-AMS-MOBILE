import 'dart:ui';

import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildCustomDialog {
  static Future<void> show({
    required BuildContext context,
    required Widget content,
    final double? height,
    final double? width,
    required EdgeInsetsGeometry padding,
    required double borderRadius,
    final Color? dialogColor,
    final bool barrierDismissible = false,
  }) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.transparent,
      context: context,
      builder:
          (context) => Stack(
            children: [
              Container(
                width: Get.size.width,
                height: Get.size.height,
                color: Colors.transparent,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(color: SecondaryColor.blackCharcoal.withOpacity(0.25)),
                ),
              ),
              BuildDialogWidget(
                content: content,
                height: height,
                width: width,
                padding: padding,
                borderRadius: borderRadius,
                color: dialogColor,
              ),
            ],
          ),
    );
  }
}

// ----------------------------------------------------------------------

class BuildDialogWidget extends StatelessWidget {
  final Widget content;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;

  const BuildDialogWidget({
    super.key,
    required this.content,
    this.height,
    this.width,
    required this.padding,
    required this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? SecondaryColor.white,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: content,
        ),
      ),
    );
  }
}
