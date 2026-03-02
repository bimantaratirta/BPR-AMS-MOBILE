import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildValidationErrorText extends StatelessWidget {
  final String? errorMessage;
  final double? alignmentWidth;

  const BuildValidationErrorText({super.key, required this.errorMessage, this.alignmentWidth});

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Row(
            children: [
              SizedBox(width: alignmentWidth ?? Get.size.width * 0.22),
              Text(errorMessage!, style: Get.textTheme.bodySmall!.copyWith(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }
}
