import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BuildDynamicProgressBar extends StatelessWidget {
  final String label;
  final int value;
  final double maxValue;
  final dynamic barColor;

  const BuildDynamicProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (maxValue == 0) ? 0.0 : (value / maxValue);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                label,
                style: Get.textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w400, color: SecondaryColor.neutral500),
              ),
              Text(
                value.toString(),
                style: Get.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w400,
                  color: (barColor is Color) ? SecondaryColor.neutral500 : MainColor.blue1,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(color: Color(0xFFF0F0F7), borderRadius: BorderRadius.circular(10)),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 20,
                      width: constraints.maxWidth * percentage,
                      decoration: BoxDecoration(
                        color: (barColor is Color) ? barColor : null,
                        gradient: (barColor is LinearGradient) ? barColor : null,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
