import 'package:get/get.dart';

import '../controllers/main_permit_controller.dart';

class MainPermitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainPermitController>(
      () => MainPermitController(),
    );
  }
}
