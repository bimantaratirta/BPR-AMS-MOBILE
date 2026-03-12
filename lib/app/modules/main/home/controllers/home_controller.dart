import 'dart:async';

import 'package:bpr_ams/app/common/utils/location_service.dart';
import 'package:bpr_ams/app/data/modules/attendance/attendance_service.dart';
import 'package:bpr_ams/app/data/modules/attendance/models/attendance_model.dart';
import 'package:bpr_ams/app/data/modules/point_record/point_record_service.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeController extends GetxController {
  final authController = Get.find<AuthController>();
  final _pointRecordService = PointRecordService();
  final _attendanceService = AttendanceService();

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

  // ---- Attendance points
  final RxDouble attendancePoints = 0.0.obs;
  final RxBool isLoadingPoints = true.obs;

  // ---- Check-in / Check-out state
  final RxBool hasCheckedIn = false.obs;
  final RxBool hasCheckedOut = false.obs;
  final RxBool isInRadius = false.obs;
  final RxBool isLoadingAttendance = true.obs;

  // ---- Location state
  final RxBool isCheckingLocation = true.obs;
  final RxString locationErrorMessage = ''.obs;
  final RxDouble distanceFromBranch = 0.0.obs;

  /// Data attendance hari ini (null jika belum check-in)
  final Rx<AttendanceModel?> todayAttendance = Rx<AttendanceModel?>(null);

  /// ID attendance record saat ini (dari API response)
  final RxnString attendanceId = RxnString();

  /// Waktu ketika user melakukan check-in
  DateTime? checkInTime;

  /// Jam check-in yang ditampilkan, contoh: "07:55:12 WIB"
  final RxString checkInTimeDisplay = ''.obs;

  /// Jam check-out yang ditampilkan, contoh: "17:01:45 WIB"
  final RxString checkOutTimeDisplay = ''.obs;

  /// Status attendance (dari enum API): "Tepat Waktu", "Terlambat", dst.
  final RxString checkInStatus = ''.obs;

  /// Durasi kerja sejak check-in, contoh: "8j 34m"
  final RxString workDuration = ''.obs;

  /// Mapping enum status API ke label tampilan
  static String statusLabel(String? apiStatus) {
    switch (apiStatus) {
      case 'HADIR':
        return 'Tepat Waktu';
      case 'TERLAMBAT':
        return 'Terlambat';
      case 'IZIN_CUTI':
        return 'Izin / Cuti';
      case 'IZIN_SAKIT':
        return 'Izin Sakit';
      case 'IZIN_SETENGAH_HARI':
        return '½ Hari';
      case 'ALPHA':
        return 'Alpha';
      default:
        return apiStatus ?? '-';
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('id_ID', null);
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());

    // Cek lokasi saat init dan periodik setiap 30 detik
    _checkLocationRadius();
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkLocationRadius());

    // Fetch data attendance hari ini & total poin dari API
    _fetchTodayAttendance();
    _fetchTotalPoints();
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('HH:mm:ss').format(now);
    currentDateDisplay.value = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(now);

    // Live timer hanya aktif saat sudah check-in dan BELUM checkout
    if (hasCheckedIn.value && !hasCheckedOut.value && checkInTime != null) {
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

  /// Fetch data attendance hari ini dari API
  Future<void> _fetchTodayAttendance() async {
    final employee = authController.employee.value;
    if (authController.pickUserType.value != UserType.employee || employee == null) {
      isLoadingAttendance.value = false;
      return;
    }

    isLoadingAttendance.value = true;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final response = await _attendanceService.getAttendances(
      queryParameters: {
        'filter': {'date': today, 'employeeId': employee.id, 'branchId': employee.branch?.id},
      },
    );

    if (response.data != null && response.data!.isNotEmpty) {
      final attendance = response.data!.first;
      todayAttendance.value = attendance;
      attendanceId.value = attendance.id;

      // Populate check-in state
      hasCheckedIn.value = attendance.checkInTime != null;
      if (attendance.checkInTime != null) {
        checkInTime = attendance.checkInTime;
        checkInTimeDisplay.value = '${DateFormat('HH:mm:ss').format(attendance.checkInTime!)} WIB';
        checkInStatus.value = statusLabel(attendance.status);
      }

      // Populate check-out state
      hasCheckedOut.value = attendance.checkOutTime != null;
      if (attendance.checkOutTime != null) {
        checkOutTimeDisplay.value = '${DateFormat('HH:mm:ss').format(attendance.checkOutTime!)} WIB';
        // Hitung durasi dari selisih checkIn - checkOut
        if (attendance.checkInTime != null) {
          final diff = attendance.checkOutTime!.difference(attendance.checkInTime!);
          final h = diff.inHours;
          final m = diff.inMinutes % 60;
          workDuration.value = '${h}j ${m}m';
        } else if (attendance.durationMinutes != null && attendance.durationMinutes! > 0) {
          // Fallback ke durationMinutes dari API jika checkInTime tidak ada
          final h = attendance.durationMinutes! ~/ 60;
          final m = attendance.durationMinutes! % 60;
          workDuration.value = '${h}j ${m}m';
        }
      }
    } else {
      // Array kosong → belum check-in sama sekali
      todayAttendance.value = null;
      hasCheckedIn.value = false;
      hasCheckedOut.value = false;
      attendanceId.value = null;
      checkInTime = null;
      checkInTimeDisplay.value = '';
      checkOutTimeDisplay.value = '';
      checkInStatus.value = '';
      workDuration.value = '';
    }

    isLoadingAttendance.value = false;
  }

  /// Refresh data attendance hari ini (dipanggil setelah check-in/out berhasil)
  Future<void> refreshTodayAttendance() async {
    await _fetchTodayAttendance();
  }

  /// Fetch total poin kehadiran dari API
  Future<void> _fetchTotalPoints() async {
    final employee = authController.employee.value;
    if (authController.pickUserType.value != UserType.employee || employee == null) {
      isLoadingPoints.value = false;
      return;
    }

    isLoadingPoints.value = true;

    final response = await _pointRecordService.getPointRecords(
      queryParameters: {
        'filter': {'employeeId': employee.id},
      },
    );

    if (response.data != null) {
      final total = response.data!.fold<int>(0, (sum, r) => sum + (r.points ?? 0));
      attendancePoints.value = total.toDouble();
    }

    isLoadingPoints.value = false;
  }

  /// Refresh poin (dipanggil setelah check-in berhasil)
  Future<void> refreshPoints() async {
    await _fetchTotalPoints();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _locationTimer?.cancel();
    super.onClose();
  }
}
