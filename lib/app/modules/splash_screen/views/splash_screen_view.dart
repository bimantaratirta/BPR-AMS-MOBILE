import 'package:bpr_ams/app/common/constant/app_assets.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final _ = Get.put(SplashScreenController());
    return Scaffold(body: SafeArea(child: Center(child: Image.asset(ImageAssets.logoBpr, scale: 3))));
  }
}
