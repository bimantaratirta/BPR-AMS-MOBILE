import 'package:get/get.dart';

import '../controllers/main_profile_controller.dart';

class MainProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainProfileController>(
      () => MainProfileController(),
    );
  }
}
