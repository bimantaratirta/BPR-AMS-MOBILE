import 'package:intl/date_symbol_data_local.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:bpr_ams/app/modules/android_block/android_block_page.dart';
import 'package:bpr_ams/app/widgets/web_responsive_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/common/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Block Android devices on web — they must use the native app
  if (kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    runApp(const AndroidBlockApp());
    return;
  }

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize Fixed Controller
  Get.put(AuthController());

  deviceOrientation();
  await ScreenUtil.ensureScreenSize();

  runApp(
    kIsWeb && kReleaseMode
        ? const MyApp()
        : DevicePreview(enabled: !kReleaseMode && kIsWeb, builder: (context) => const MyApp()),
  );
}

void deviceOrientation() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      ensureScreenSize: true,
      useInheritedMediaQuery: true,
      enableScaleWH: () => !kIsWeb,
      builder: (_, child) {
        return GetMaterialApp(
          useInheritedMediaQuery: true,
          title: "BPR AMS",
          debugShowCheckedModeBanner: false,
          locale: DevicePreview.locale(context),
          builder: (context, child) {
            // Chain DevicePreview builder (dev only) + web responsive wrapper
            Widget result = child ?? const SizedBox.shrink();
            if (!kReleaseMode && kIsWeb) {
              result = DevicePreview.appBuilder(context, result);
            }
            return WebResponsiveWrapper(child: result);
          },
          theme: AppTheme.getTheme(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
        );
      },
    );
  }
}
