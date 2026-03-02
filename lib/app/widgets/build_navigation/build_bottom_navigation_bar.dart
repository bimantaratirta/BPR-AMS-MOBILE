import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/modules/main/controllers/main_controller.dart';
import 'package:bpr_ams/app/widgets/build_navigation/build_bottom_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BuildBottomNavigationBar extends GetView<MainController> {
  const BuildBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MainController>()) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final items = controller.sidebarSettings;
      final activeIndex = controller.currentIndex.value;

      return Container(
        decoration: BoxDecoration(
          color: SecondaryColor.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isActive = activeIndex == item.index;
                return BuildBottomNavigationBarItem(
                  key: ValueKey(item.index),
                  isActive: isActive,
                  data: item,
                  index: item.index,
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}
