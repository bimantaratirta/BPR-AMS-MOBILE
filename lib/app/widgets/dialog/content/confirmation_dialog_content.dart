import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ConfirmationDialogContent extends StatelessWidget {
  final String? message;
  final String? trueText;
  final String? falseText;
  final VoidCallback? onTruePressed;
  final VoidCallback? onFalsePressed;
  final RxBool? isLoading;

  const ConfirmationDialogContent({
    super.key,
    this.message,
    this.trueText,
    this.falseText,
    this.onTruePressed,
    this.onFalsePressed,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 30.w),
          child: Center(
            child: Text(
              message ?? "Konfirmasi?",
              style: Get.textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Obx(() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SecondaryColor.danger600,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  minimumSize: Size(100.w, 48.h),
                ),
                onPressed: (isLoading?.value ?? false) ? null : (onFalsePressed ?? () => Get.back()),
                child: Text(
                  falseText ?? "Tidak",
                  style: Get.textTheme.labelMedium!.copyWith(color: SecondaryColor.white, fontWeight: FontWeight.bold),
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: MainColor.blue5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                  minimumSize: Size(100.w, 48.h),
                ),
                onPressed: (isLoading?.value ?? false) ? null : (onTruePressed ?? () => Get.back()),
                child:
                    (isLoading?.value ?? false)
                        ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(color: SecondaryColor.white, strokeWidth: 2.0),
                        )
                        : Text(
                          trueText ?? "Ya",
                          style: Get.textTheme.labelMedium!.copyWith(
                            color: SecondaryColor.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
