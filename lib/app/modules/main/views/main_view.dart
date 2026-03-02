import 'package:bpr_ams/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final didPop = await Get.rootDelegate.popRoute();
        return !didPop;
      },
      child: Scaffold(body: GetRouterOutlet(initialRoute: Routes.MAIN_HOME)),
    );
  }
}
