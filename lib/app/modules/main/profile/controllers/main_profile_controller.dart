import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:bpr_ams/app/widgets/build_custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainProfileController extends GetxController {
  final authController = Get.find<AuthController>();

  // ── User info getters ─────────────────────────────────────
  String get name => authController.user.value?.name ?? '-';
  String get email => '${(authController.user.value?.username ?? 'user').toLowerCase().replaceAll(' ', '.')}.bpr.co.id';
  String get nik => authController.user.value?.username ?? '-';
  String get role => authController.user.value?.role ?? '-';
  String get branch => authController.user.value?.branch?.branch ?? '-';

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
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffEC2D30),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await authController.logout();
      Get.offAllNamed('/auth/login');
    }
  }
}
