import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:bpr_ams/app/widgets/build_custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MainProfileController extends GetxController {
  final authController = Get.find<AuthController>();

  // ── User info getters ─────────────────────────────────────
  String get name =>
      authController.pickUserType.value == UserType.employee
          ? authController.employee.value?.name ?? '-'
          : authController.admin.value?.name ?? '-';
  String get email =>
      authController.pickUserType.value == UserType.employee
          ? authController.employee.value?.email ?? '-'
          : authController.admin.value?.email ?? '-';
  String get nik => authController.pickUserType.value == UserType.employee ? authController.employee.value?.nik ?? '-' : '-';
  String get role =>
      authController.pickUserType.value == UserType.employee ? authController.employee.value?.role ?? '-' : '-';
  String get branch =>
      authController.pickUserType.value == UserType.employee ? authController.employee.value?.branch?.name ?? '-' : '-';

  // ── Loading state untuk proses logout ─────────────────────
  final RxBool isLoggingOut = false.obs;

  // ── Menu actions ──────────────────────────────────────────
  void onNotifikasiTap() {
    CustomSnackbar(
      message: 'Halaman Notifikasi belum tersedia.',
      type: CustomSnackbarType.warning,
    ).show(Get.overlayContext!);
  }

  void onPengaturanTap() {
    CustomSnackbar(
      message: 'Halaman Pengaturan belum tersedia.',
      type: CustomSnackbarType.warning,
    ).show(Get.overlayContext!);
  }

  Future<void> onKeluarTap() async {
    final confirmed = await _showLogoutBottomSheet();
    if (confirmed == true) {
      isLoggingOut.value = true;
      await authController.logout();
      isLoggingOut.value = false;
      Get.offAllNamed('/auth/login');
    }
  }

  Future<bool?> _showLogoutBottomSheet() {
    return Get.bottomSheet<bool>(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
        decoration: BoxDecoration(
          color: SecondaryColor.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(28.r), topRight: Radius.circular(28.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(color: SecondaryColor.neutral200, borderRadius: BorderRadius.circular(4.r)),
            ),

            SizedBox(height: 8.h),

            // ── Icon ──
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(color: const Color(0xffFFE2E2), shape: BoxShape.circle),
              child: Icon(Icons.logout_rounded, size: 34.sp, color: SecondaryColor.danger600),
            ),

            SizedBox(height: 20.h),

            // ── Title ──
            Text(
              'Keluar dari Akun?',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
            ),

            SizedBox(height: 8.h),

            // ── Subtitle ──
            Text(
              'Anda akan keluar dari sesi ini.\nLogin kembali diperlukan untuk mengakses aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: SecondaryColor.neutral500, height: 1.5),
            ),

            SizedBox(height: 28.h),

            // ── Buttons ──
            Row(
              children: [
                // Batal
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(result: false),
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(color: SecondaryColor.neutral100, borderRadius: BorderRadius.circular(14.r)),
                      child: Center(
                        child: Text(
                          'Batal',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral600),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Keluar
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(result: true),
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [SecondaryColor.danger600, const Color(0xffC0392B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: SecondaryColor.danger600.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout_rounded, color: Colors.white, size: 16.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'Ya, Keluar',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
    );
  }
}
