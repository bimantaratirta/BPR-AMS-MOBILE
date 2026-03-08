import 'dart:async';

import 'package:bpr_ams/app/common/utils/location_service.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeController extends GetxController {
  final authController = Get.find<AuthController>();

  // ---- Live clock
  final RxString currentTime = ''.obs;
  Timer? _timer;
  Timer? _locationTimer;

  // ---- Derived from user
  String get userName =>
      authController.pickUserType.value == UserType.employee
          ? authController.employee.value?.name ?? '-'
          : authController.admin.value?.name ?? '-';
  String get userNik =>
      authController.pickUserType.value == UserType.employee ? authController.employee.value?.nik ?? '-' : '-';
  String get userRole =>
      authController.pickUserType.value == UserType.employee ? authController.employee.value?.role ?? '-' : '-';
  String get userBranch =>
      authController.pickUserType.value == UserType.employee ? authController.employee.value?.branch?.name ?? '-' : '-';

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
  final RxBool isInRadius = false.obs;

  // ---- Location state
  final RxBool isCheckingLocation = true.obs;
  final RxString locationErrorMessage = ''.obs;
  final RxDouble distanceFromBranch = 0.0.obs;

  /// ID attendance record saat ini (dari API response)
  final RxnString attendanceId = RxnString();

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

    // Cek lokasi saat init dan periodik setiap 30 detik
    _checkLocationRadius();
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkLocationRadius());
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

  /// Memeriksa apakah device berada dalam radius branch.
  Future<void> _checkLocationRadius() async {
    final employee = authController.employee.value;
    final branch = employee?.branch;

    // Hanya untuk employee yang punya data branch lengkap
    if (authController.pickUserType.value != UserType.employee ||
        branch == null ||
        branch.latitude == null ||
        branch.longitude == null ||
        branch.radius == null) {
      isInRadius.value = true; // default true jika bukan employee / tidak ada data branch
      isCheckingLocation.value = false;
      return;
    }

    isCheckingLocation.value = true;
    locationErrorMessage.value = '';

    final result = await LocationService.checkRadius(
      branchLat: branch.latitude!,
      branchLng: branch.longitude!,
      radiusInMeters: branch.radius!,
    );

    isInRadius.value = result.isInRadius;
    distanceFromBranch.value = result.distance;

    if (result.error != null) {
      locationErrorMessage.value = result.error!;
    }

    isCheckingLocation.value = false;
  }

  /// Refresh lokasi manual (bisa dipanggil dari UI)
  Future<void> refreshLocation() async {
    await _checkLocationRadius();
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
    _locationTimer?.cancel();
    super.onClose();
  }
}
