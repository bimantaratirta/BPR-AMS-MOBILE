import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/modules/admin/admin_service.dart';
import 'package:bpr_ams/app/data/modules/employee/employee_service.dart';
import 'package:bpr_ams/app/data/storage/storage_client.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:bpr_ams/app/routes/app_pages.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    startSplashScreen();
  }

  Future<void> startSplashScreen() async {
    // Minimal splash duration
    await Future.delayed(const Duration(seconds: 2));

    // ── Cek apakah token masih valid ──────────────────────────
    if (!StorageClient.isTokenExpired()) {
      final restored = await _tryRestoreSession();
      if (restored) {
        Get.offAllNamed(Routes.MAIN);
        return;
      }
    }

    // Token expired / tidak ada / gagal restore → ke halaman login
    Get.offAllNamed(Routes.AUTH_LOGIN);
  }

  /// Mencoba restore sesi dari token tersimpan.
  /// Mengembalikan `true` jika berhasil fetch data user.
  Future<bool> _tryRestoreSession() async {
    try {
      final token = StorageClient.getAccessToken();
      if (token == null) return false;

      final payload = Helper().decodeJwt(token);
      if (payload == null) return false;

      final userId = payload['id'] as String?;
      if (userId == null || userId.isEmpty) return false;

      final userTypeStr = StorageClient.getUserType();
      final userType = UserType.fromString(userTypeStr);
      if (userType == null) return false;

      final authController = Get.find<AuthController>();
      authController.pickUserType.value = userType;

      // Fetch data user terbaru dari API
      if (userType == UserType.employee) {
        final response = await EmployeeService().getEmployeeById(userId);
        if ((response.code == 200 || response.code == 201) && response.data != null) {
          authController.employee.value = response.data;
          authController.employee.refresh();
          return true;
        }
      } else {
        final response = await AdminService().getAdminById(userId);
        if ((response.code == 200 || response.code == 201) && response.data != null) {
          authController.admin.value = response.data;
          authController.admin.refresh();
          return true;
        }
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
