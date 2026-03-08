import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/common/constant/app_assets.dart';
import 'package:bpr_ams/app/data/main/bottom_navigation/bottom_navigation_item_model.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:bpr_ams/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';

class MainController extends GetxController {
  // ---- Dependencies
  final authController = Get.find<AuthController>();

  // ---- State
  final RxInt currentIndex = 0.obs;
  final RxList<BottomNavigationItemModel> sidebarSettings = <BottomNavigationItemModel>[].obs;
  late Disposer _roleDisposer;

  // Index konstanta
  static const int HOME_INDEX = 0;
  static const int PERMIT_INDEX = 1;
  static const int HISTORY_INDEX = 2;

  // ====== ROUTE MAPS per role (child dari /main) ======
  // Urutan list = urutan tab di bottom nav untuk role tsb.
  List<String> generateRoutes(UserType? userType) {
    return [Routes.MAIN_HOME, Routes.MAIN_PERMIT, Routes.MAIN_HISTORY];
  }

  // ====== BUILD SIDEBAR (BOTTOM NAV) ITEMS SESUAI ROLE ======
  List<BottomNavigationItemModel> _buildItems(UserType? userType) {
    final items = <BottomNavigationItemModel>[];

    items.addAll([
      BottomNavigationItemModel(
        onTap: () => changePage(HOME_INDEX),
        index: HOME_INDEX,
        iconPath: IconAssets.house,
        iconColor: MainColor.blue5,
        label: 'Beranda',
        labelStyle: Get.textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w500, color: MainColor.blue5),
      ),
      BottomNavigationItemModel(
        onTap: () => changePage(PERMIT_INDEX),
        index: PERMIT_INDEX,
        iconPath: IconAssets.calendar,
        iconColor: MainColor.blue5,
        label: 'Izin',
        labelStyle: Get.textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w500, color: MainColor.blue5),
      ),
      BottomNavigationItemModel(
        onTap: () => changePage(HISTORY_INDEX),
        index: HISTORY_INDEX,
        iconPath: IconAssets.clock,
        iconColor: MainColor.blue5,
        label: 'Histori',
        labelStyle: Get.textTheme.labelMedium!.copyWith(fontWeight: FontWeight.w500, color: MainColor.blue5),
      ),
    ]);

    return items;
  }

  // ====== NAVIGASI ANTAR TAB ======
  void changePage(int index) {
    final userType = authController.pickUserType.value;
    final routes = generateRoutes(userType);

    // clamp index jika out of range
    final safeIndex = index.clamp(0, routes.length - 1);
    if (currentIndex.value == safeIndex) return;

    currentIndex.value = safeIndex;
    final childPath = routes[safeIndex]; // contoh: Routes.MAIN_HOME, Routes.NASABAH, dst.

    Get.rootDelegate.toNamed('${Routes.MAIN}$childPath');
  }

  // Panggil ini setelah login jika perlu
  void navigateToHome() {
    currentIndex.value = 0; // Home
    Get.rootDelegate.offNamed('${Routes.MAIN}${Routes.MAIN_HOME}');
  }

  // Sinkronkan index saat deep-link / refresh web mengarah ke child tertentu
  void syncIndexFromLocation() {
    final userType = authController.pickUserType.value;
    final routes = generateRoutes(userType);

    final location = Get.rootDelegate.currentConfiguration?.location ?? '';
    // location contoh: /main/home, /main/report, ...
    final matched = routes.indexWhere((r) => location.endsWith(r));
    if (matched != -1) {
      currentIndex.value = matched;
    } else {
      // fallback ke Home
      currentIndex.value = 0;
    }
  }

  // ====== Lifecycle ======
  @override
  void onInit() {
    super.onInit();

    final userType = authController.pickUserType.value;
    sidebarSettings.assignAll(_buildItems(userType));

    // Simpan disposer yang dikembalikan oleh ever()
    _roleDisposer = ever(authController.pickUserType, (UserType? newUserType) {
      final newItems = _buildItems(newUserType);
      sidebarSettings.assignAll(newItems);

      final routes = generateRoutes(newUserType);
      if (currentIndex.value >= routes.length) {
        currentIndex.value = 0;
      }
      final childPath = routes[currentIndex.value];

      Get.rootDelegate.offNamed('${Routes.MAIN}$childPath');
    });

    syncIndexFromLocation();
  }

  void stopListeners() {
    _roleDisposer();
  }
}
