import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../home/controllers/home_controller.dart';
import '../permit/controllers/main_permit_controller.dart';
import '../history/controllers/main_history_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainController>(MainController(), permanent: true);
    // Tab controllers loaded di sini — IndexedStack instansiasi semua tab sekaligus
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<MainPermitController>(() => MainPermitController(), fenix: true);
    Get.lazyPut<MainHistoryController>(() => MainHistoryController(), fenix: true);
  }
}
