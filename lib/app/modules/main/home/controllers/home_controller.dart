import 'dart:async';

import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeController extends GetxController {
  final authController = Get.find<AuthController>();

  // ---- Live clock
  final RxString currentTime = ''.obs;
  Timer? _timer;

  // ---- Derived from user
  String get userName => authController.user.value?.name ?? '-';
  String get userNik => authController.user.value?.username ?? '-';
  String get userRole => authController.user.value?.role ?? '-';
  String get userBranch => authController.user.value?.branch?.branch ?? '-';

  // ---- Greeting / header
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String get greetingEmoji {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return '👋';
    if (hour >= 11 && hour < 15) return '☀️';
    if (hour >= 15 && hour < 18) return '🌤️';
    return '🌙';
  }

  // ---- Date display (Rabu, 25 Februari 2026)
  final RxString currentDateDisplay = ''.obs;

  // ---- Attendance points (placeholder)
  final RxDouble attendancePoints = 15.5.obs;

  // ---- Check-in state
  final RxBool hasCheckedIn = false.obs;
  final RxBool isInRadius = true.obs;

  /// Waktu ketika user melakukan check-in
  DateTime? checkInTime;

  /// Jam check-in yang ditampilkan, contoh: "07:55:12 WIB"
  final RxString checkInTimeDisplay = ''.obs;

  /// Status ketepatan waktu: "Tepat Waktu" / "Terlambat"
  final RxString checkInStatus = ''.obs;

  /// Durasi kerja sejak check-in, contoh: "8j 34m"
  final RxString workDuration = ''.obs;

  // ---- Jam check-in dianggap tepat waktu jika <= 08:00
  static const int _onTimeLimitHour = 8;
  static const int _onTimeLimitMinute = 0;

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('id_ID', null);
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('HH:mm:ss').format(now);
    currentDateDisplay.value = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    if (hasCheckedIn.value && checkInTime != null) {
      final diff = now.difference(checkInTime!);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      workDuration.value = '${hours}j ${minutes}m';
    }
  }

  void onCheckInTap() {
    if (!isInRadius.value) return;

    if (!hasCheckedIn.value) {
      // --- CHECK IN ---
      final now = DateTime.now();
      checkInTime = now;

      // Format: "07:55:12 WIB"
      checkInTimeDisplay.value = '${DateFormat('HH:mm:ss').format(now)} WIB';

      // Tepat waktu jika jam:menit <= 08:00
      final isOnTime = now.hour < _onTimeLimitHour || (now.hour == _onTimeLimitHour && now.minute <= _onTimeLimitMinute);
      checkInStatus.value = isOnTime ? 'Tepat Waktu' : 'Terlambat';

      // Reset durasi
      workDuration.value = '0j 0m';

      hasCheckedIn.value = true;
    } else {
      // --- CHECK OUT ---
      hasCheckedIn.value = false;
      checkInTime = null;
      checkInTimeDisplay.value = '';
      checkInStatus.value = '';
      workDuration.value = '';
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
