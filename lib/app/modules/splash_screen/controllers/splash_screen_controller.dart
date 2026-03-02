import 'package:bpr_ams/app/routes/app_pages.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    startSplashScreen();
  }

  void startSplashScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.AUTH_LOGIN);
    });
  }
}
