import 'package:get/get.dart';

import '../controllers/main_history_controller.dart';

class MainHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHistoryController>(
      () => MainHistoryController(),
    );
  }
}
