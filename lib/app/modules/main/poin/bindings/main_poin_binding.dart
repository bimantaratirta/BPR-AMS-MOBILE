import 'package:get/get.dart';

import '../controllers/main_poin_controller.dart';

class MainPoinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainPoinController>(
      () => MainPoinController(),
    );
  }
}
