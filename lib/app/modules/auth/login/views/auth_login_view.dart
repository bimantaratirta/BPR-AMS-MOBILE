import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/common/constant/app_assets.dart';
import 'package:bpr_ams/app/widgets/build_custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../controllers/auth_login_controller.dart';

class AuthLoginView extends GetView<AuthLoginController> {
  const AuthLoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 36, vertical: 75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(alignment: Alignment.topCenter, child: Image.asset(ImageAssets.logoBpr, scale: 4)),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Text(
                          "BPR Sahabat Sejati",
                          style: Get.textTheme.displayMedium!.copyWith(fontWeight: FontWeight.w900, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Sistem Kehadiran Karyawan",
                          style: Get.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            color: MainColor.greyLight1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email",
                        style: Get.textTheme.labelMedium!.copyWith(letterSpacing: 1, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      BuildCustomTextFormField(
                        hintText: "Masukkan email...",
                        controller: controller.emailController,
                        maxLines: 1,
                        isReadOnly: false,
                        isEnable: true,
                        withInputFormatter: false,
                      ),
                      controller.validationErrors['email'] != null
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                controller.validationErrors['email'] ?? '',
                                style: Get.textTheme.bodySmall!.copyWith(color: Colors.red),
                              ),
                            ],
                          )
                          : const SizedBox.shrink(),
                      SizedBox(height: 16),
                      Text(
                        "Password",
                        style: Get.textTheme.labelMedium!.copyWith(letterSpacing: 1, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      BuildCustomTextFormField(
                        hintText: "Masukkan password...",
                        controller: controller.passwordController,
                        maxLines: 1,
                        textInputType: TextInputType.visiblePassword,
                        obscureText: !controller.isPasswordVisible.value,
                        suffixIcon: IconButton(
                          onPressed: () => controller.togglePasswordVisible(),
                          icon:
                              controller.isPasswordVisible.value
                                  ? SvgPicture.asset(IconAssets.eye, height: 20.h)
                                  : SvgPicture.asset(IconAssets.eyeClosed, height: 20.h),
                        ),
                        isReadOnly: false,
                        isEnable: true,
                        withInputFormatter: false,
                      ),
                      controller.validationErrors['password'] != null
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text(
                                controller.validationErrors['password'] ?? '',
                                style: Get.textTheme.bodySmall!.copyWith(color: Colors.red),
                              ),
                            ],
                          )
                          : const SizedBox.shrink(),
                    ],
                  ),
                  SizedBox(height: 16),
                  Align(alignment: Alignment.centerRight, child: Text("Lupa Password?", style: Get.textTheme.bodyMedium!)),
                  SizedBox(height: 32),
                  Obx(() {
                    final isFormValid = controller.isFormValid.value;

                    final VoidCallback? action =
                        (isFormValid && !controller.isLoading.value) ? () => controller.login(context) : null;

                    return ElevatedButton(
                      onPressed: action,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: MainColor.blue5,
                        disabledBackgroundColor: SecondaryColor.neutral500,
                        minimumSize: Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (controller.isLoading.value)
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: const CircularProgressIndicator(color: SecondaryColor.white, strokeWidth: 2),
                              )
                            else
                              Text(
                                "Masuk",
                                style: Get.textTheme.labelMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: SecondaryColor.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
