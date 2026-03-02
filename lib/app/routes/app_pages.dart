import 'package:get/get.dart';

import '../modules/auth/login/bindings/auth_login_binding.dart';
import '../modules/auth/login/views/auth_login_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/check_in_out/bindings/main_check_in_out_binding.dart';
import '../modules/main/check_in_out/views/main_check_in_out_view.dart';
import '../modules/main/history/bindings/main_history_binding.dart';
import '../modules/main/history/views/main_history_view.dart';
import '../modules/main/home/bindings/home_binding.dart';
import '../modules/main/home/views/home_view.dart';
import '../modules/main/permit/bindings/main_permit_binding.dart';
import '../modules/main/permit/views/main_permit_view.dart';
import '../modules/main/poin/bindings/main_poin_binding.dart';
import '../modules/main/poin/views/main_poin_view.dart';
import '../modules/main/profile/bindings/main_profile_binding.dart';
import '../modules/main/profile/views/main_profile_view.dart';
import '../modules/main/views/main_view.dart';
import '../modules/splash_screen/bindings/splash_screen_binding.dart';
import '../modules/splash_screen/views/splash_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
        name: _Paths.MAIN_HOME,
        page: () => const HomeView(),
        binding: HomeBinding()),
    GetPage(
        name: _Paths.SPLASH_SCREEN,
        page: () => const SplashScreenView(),
        binding: SplashScreenBinding()),
    GetPage(
        name: _Paths.AUTH + _Paths.LOGIN,
        page: () => const AuthLoginView(),
        binding: AuthLoginBinding()),
    GetPage(
      name: _Paths.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
      children: [
        GetPage(
            name: _Paths.MAIN_PERMIT,
            page: () => const MainPermitView(),
            binding: MainPermitBinding()),
        GetPage(
            name: _Paths.MAIN_HISTORY,
            page: () => const MainHistoryView(),
            binding: MainHistoryBinding()),
        GetPage(
          name: _Paths.MAIN_PROFILE,
          page: () => const MainProfileView(),
          binding: MainProfileBinding(),
        ),
        GetPage(
          name: _Paths.MAIN_POIN,
          page: () => const MainPoinView(),
          binding: MainPoinBinding(),
        ),
        GetPage(
          name: _Paths.MAIN_CHECK_IN_OUT,
          page: () => const MainCheckInOutView(),
          binding: MainCheckInOutBinding(),
        ),
      ],
    ),
  ];
}
