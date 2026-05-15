import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/common/constant/app_assets.dart';
import 'package:bpr_ams/app/data/main/bottom_navigation/bottom_navigation_item_model.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';

class MainController extends GetxController {
  // ---- Dependencies
  final authController = Get.find<AuthController>();

  // ---- State
  final RxInt currentIndex = 0.obs;
  final RxList<BottomNavigationItemModel> sidebarSettings = <BottomNavigationItemModel>[].obs;
  // Lazy-load: tab cuma di-build saat pertama dibuka. HOME ter-mark default.
  final RxSet<int> visitedTabs = <int>{HOME_INDEX}.obs;
  late Disposer _roleDisposer;

  // Index konstanta
  static const int HOME_INDEX = 0;
  static const int PERMIT_INDEX = 1;
  static const int HISTORY_INDEX = 2;

  // Total tab — sinkron dengan IndexedStack di MainView
  static const int TAB_COUNT = 3;

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

  // ====== NAVIGASI ANTAR TAB (IndexedStack) ======
  void changePage(int index) {
    final safeIndex = index.clamp(0, TAB_COUNT - 1);
    visitedTabs.add(safeIndex);
    if (currentIndex.value == safeIndex) return;
    currentIndex.value = safeIndex;
  }

  // ====== Lifecycle ======
  @override
  void onInit() {
    super.onInit();

    final userType = authController.pickUserType.value;
    sidebarSettings.assignAll(_buildItems(userType));

    _roleDisposer = ever(authController.pickUserType, (UserType? newUserType) {
      sidebarSettings.assignAll(_buildItems(newUserType));
      if (currentIndex.value >= TAB_COUNT) currentIndex.value = HOME_INDEX;
    });
  }

  void stopListeners() {
    _roleDisposer();
  }
}
