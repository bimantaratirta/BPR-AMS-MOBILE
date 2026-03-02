import 'package:get/get.dart';

import '../controllers/main_check_in_out_controller.dart';

class MainCheckInOutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainCheckInOutController>(
      () => MainCheckInOutController(),
    );
  }
}
