import 'package:bpr_ams/app/widgets/build_navigation/build_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_controller.dart';
import '../home/views/home_view.dart';
import '../permit/views/main_permit_view.dart';
import '../history/views/main_history_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  // Tab non-aktif yang belum pernah dibuka pakai placeholder kosong → controller
  // gak ke-instantiate, gak fire API. Setelah dikunjungi pertama kali, tab masuk
  // visitedTabs dan keep-alive di IndexedStack.
  Widget _tab(int index) {
    if (!controller.visitedTabs.contains(index)) {
      return const SizedBox.shrink();
    }
    switch (index) {
      case MainController.HOME_INDEX:
        return const HomeView();
      case MainController.PERMIT_INDEX:
        return const MainPermitView();
      case MainController.HISTORY_INDEX:
        return const MainHistoryView();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (controller.currentIndex.value != MainController.HOME_INDEX) {
          controller.changePage(MainController.HOME_INDEX);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: List.generate(MainController.TAB_COUNT, _tab),
          ),
        ),
        bottomNavigationBar: const BuildBottomNavigationBar(),
      ),
    );
  }
}
