import 'dart:async';
import 'dart:io';

import 'package:bpr_ams/app/common/utils/location_service.dart';
import 'package:bpr_ams/app/data/modules/attendance/attendance_service.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:bpr_ams/app/modules/main/home/controllers/home_controller.dart';
import 'package:bpr_ams/app/widgets/build_custom_snackbar.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ── State machine for the screen ─────────────────────────
enum CheckInStage {
  idle, // camera ready, waiting for tap
  countdown, // 3-2-1 countdown running
  captured, // photo "taken" — show checkmark + action buttons
  confirmCheckOut, // check-out: show confirm dialog (no camera)
  submitting, // sending to API
  success, // confirmed — show success page
}

class MainCheckInOutController extends GetxController with GetTickerProviderStateMixin {
  final authController = Get.find<AuthController>();
  final _attendanceService = AttendanceService();

  // ── Mode ─────────────────────────────────────────────
  late final bool isCheckOut;

  // ── Stage ────────────────────────────────────────────
  final Rx<CheckInStage> stage = CheckInStage.idle.obs;

  // ── Countdown ────────────────────────────────────────
  final RxInt countdown = 3.obs;
  Timer? _countdownTimer;

  // ── Live clock on camera view ─────────────────────────
  final RxString liveTime = ''.obs;
  Timer? _clockTimer;

  // ── Location validation ──────────────────────────────
  final RxBool isLocationValid = false.obs;
  final RxBool isCheckingLocation = true.obs;
  final RxString locationError = ''.obs;
  final RxDouble distanceFromBranch = 0.0.obs;

  // ── Koordinat GPS device (diisi saat validasi lokasi) ──
  double? _deviceLat;
  double? _deviceLng;

  // ── Camera ───────────────────────────────────────────
  CameraController? cameraController;
  final RxBool isCameraReady = false.obs;
  XFile? capturedPhoto;

  // ── Submitting state ─────────────────────────────────
  final RxBool isSubmitting = false.obs;
  final RxString submitError = ''.obs;

  // ── Result data ───────────────────────────────────────
  late DateTime actionTime; // time of check-in or check-out
  String? responseStatus; // status from API response

  String get actionTimeDisplay => '${DateFormat('HH:mm:ss').format(actionTime)} WIB';

  String get checkInStatusText {
    if (isCheckOut) return '';
    // Use status from API response if available
    if (responseStatus != null) {
      return responseStatus == 'TEPAT_WAKTU' ? 'Tepat Waktu' : 'Terlambat';
    }
    final isOnTime = actionTime.hour < 8 || (actionTime.hour == 8 && actionTime.minute == 0);
    return isOnTime ? 'Tepat Waktu' : 'Terlambat';
  }

  String get poinEarned {
    if (isCheckOut) return '';
    final isOnTime = actionTime.hour < 8 || (actionTime.hour == 8 && actionTime.minute == 0);
    final isHalf = actionTime.hour == 8 && actionTime.minute >= 1 && actionTime.minute <= 30;
    if (isOnTime) return '+1 Poin';
    if (isHalf) return '+0.5 Poin';
    return '0 Poin';
  }

  // For check-out: get check-in time and duration from HomeController
  String get storedCheckInTimeDisplay {
    if (!Get.isRegistered<HomeController>()) return '—';
    final home = Get.find<HomeController>();
    return home.checkInTimeDisplay.value;
  }

  String get workDurationDisplay {
    if (!Get.isRegistered<HomeController>()) return '—';
    final home = Get.find<HomeController>();
    final checkInT = home.checkInTime;
    if (checkInT == null) return '—';
    final diff = actionTime.difference(checkInT);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return '${h}j ${m}m';
  }

  // ── User info ─────────────────────────────────────────
  String get branch =>
      authController.pickUserType.value == UserType.employee
          ? authController.employee.value?.branch?.name ?? 'Kantor Pusat'
          : '-';

  // ── Pulse animation (success dots) ───────────────────
  late AnimationController pulseAnim;

  @override
  void onInit() {
    super.onInit();
    // Read mode from args
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    isCheckOut = args['isCheckOut'] == true;

    _startClock();
    pulseAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

    // Validasi lokasi saat masuk halaman
    _validateLocation();

    // Initialize camera (only for check-in, not for check-out)
    if (!isCheckOut) {
      _initCamera();
    }
  }

  // ── Camera initialization ─────────────────────────────
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      // Find front camera
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController!.initialize();
      isCameraReady.value = true;
    } catch (e) {
      debugPrint('Camera init error: $e');
      isCameraReady.value = false;
    }
  }

  void _startClock() {
    liveTime.value = DateFormat('HH.mm.ss').format(DateTime.now());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      liveTime.value = DateFormat('HH.mm.ss').format(DateTime.now());
    });
  }

  /// Validasi apakah device dalam radius branch
  Future<void> _validateLocation() async {
    final employee = authController.employee.value;
    final branchData = employee?.branch;

    // Jika bukan employee atau tidak ada data branch, skip validasi
    if (authController.pickUserType.value != UserType.employee ||
        branchData == null ||
        branchData.latitude == null ||
        branchData.longitude == null ||
        branchData.radius == null) {
      isLocationValid.value = true;
      isCheckingLocation.value = false;
      return;
    }

    isCheckingLocation.value = true;
    locationError.value = '';

    final result = await LocationService.checkRadius(
      branchLat: branchData.latitude!,
      branchLng: branchData.longitude!,
      radiusInMeters: branchData.radius!,
    );

    isLocationValid.value = result.isInRadius;
    distanceFromBranch.value = result.distance;

    // Simpan koordinat GPS asli untuk dipakai pada saat submit
    if (result.deviceLat != null && result.deviceLng != null) {
      _deviceLat = result.deviceLat;
      _deviceLng = result.deviceLng;
    }

    if (result.error != null) {
      locationError.value = result.error!;
    }

    isCheckingLocation.value = false;

    // Jika di luar radius, tampilkan pesan error
    if (!result.isInRadius && result.error == null) {
      locationError.value =
          'Anda berada ${result.distance.toStringAsFixed(0)}m dari kantor. '
          'Radius yang diizinkan: ${branchData.radius}m.';
    }
  }

  // ── Trigger capture (check-in) or confirm (check-out) ──
  void onCaptureButtonTap() async {
    if (stage.value != CheckInStage.idle) return;

    // Re-validasi lokasi sebelum capture
    await _validateLocation();

    if (!isLocationValid.value) {
      final context = Get.context;
      if (context != null) {
        final errorMsg =
            locationError.value.isNotEmpty
                ? locationError.value
                : 'Anda di luar radius kantor. Tidak dapat melakukan ${isCheckOut ? "check out" : "check in"}.';
        CustomSnackbar(message: errorMsg, type: CustomSnackbarType.error).show(context);
      }
      return;
    }

    if (isCheckOut) {
      // Check-out: langsung ke konfirmasi (tanpa camera/countdown)
      actionTime = DateTime.now();
      stage.value = CheckInStage.confirmCheckOut;
    } else {
      // Check-in: mulai countdown + ambil foto
      stage.value = CheckInStage.countdown;
      countdown.value = 3;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
        if (countdown.value > 1) {
          countdown.value--;
        } else {
          t.cancel();
          actionTime = DateTime.now();

          // Take photo for check-in
          if (cameraController != null && cameraController!.value.isInitialized) {
            try {
              final xFile = await cameraController!.takePicture();
              // Save to temp directory
              final tempDir = await getTemporaryDirectory();
              final fileName = 'checkin_${DateTime.now().millisecondsSinceEpoch}.jpg';
              final savedPath = p.join(tempDir.path, fileName);
              await File(xFile.path).copy(savedPath);
              capturedPhoto = XFile(savedPath);
            } catch (e) {
              debugPrint('Error taking photo: $e');
            }
          }

          stage.value = CheckInStage.captured;
        }
      });
    }
  }

  // ── Retry ─────────────────────────────────────────────
  void onRetry() {
    _countdownTimer?.cancel();
    capturedPhoto = null;
    submitError.value = '';
    stage.value = CheckInStage.idle;
    countdown.value = 3;
  }

  // ── Confirm ───────────────────────────────────────────
  Future<void> onConfirm() async {
    isSubmitting.value = true;
    submitError.value = '';
    stage.value = CheckInStage.submitting;

    try {
      if (isCheckOut) {
        await _performCheckOut();
      } else {
        await _performCheckIn();
      }
    } catch (e) {
      isSubmitting.value = false;
      submitError.value = 'Terjadi kesalahan: ${e.toString()}';
      // Go back to appropriate stage for retry
      stage.value = isCheckOut ? CheckInStage.confirmCheckOut : CheckInStage.captured;
      _showError(submitError.value);
    }
  }

  /// Check if API response indicates an error (code != 200/201 or has errors)
  bool _isApiError(dynamic response) {
    if (response.error != null) return true;
    if (response.errors != null) return true;
    if (response.code != null && response.code != 200 && response.code != 201) return true;
    if (response.status == 'BAD_REQUEST' || response.status == 'error') return true;
    return false;
  }

  /// Get error message from API response
  String _getApiErrorMessage(dynamic response) {
    if (response.message != null && response.message!.isNotEmpty) {
      return response.message!;
    }
    if (response.error != null) {
      return response.error.toString();
    }
    return 'Terjadi kesalahan yang tidak diketahui';
  }

  Future<void> _performCheckIn() async {
    final employee = authController.employee.value;
    if (employee == null) {
      isSubmitting.value = false;
      submitError.value = 'Data employee tidak ditemukan';
      stage.value = CheckInStage.captured;
      _showError(submitError.value);
      return;
    }

    // Build FormData dengan koordinat GPS asli
    final formData = FormData.fromMap({'checkInLat': _deviceLat ?? 0.0, 'checkInLng': _deviceLng ?? 0.0});

    // Add photo if captured
    if (capturedPhoto != null) {
      final file = await MultipartFile.fromFile(capturedPhoto!.path, filename: p.basename(capturedPhoto!.path));
      formData.files.add(MapEntry('checkInPhoto', file));
    }

    final response = await _attendanceService.checkIn(formData);

    isSubmitting.value = false;

    // Check for API errors (including 400 BAD_REQUEST)
    if (_isApiError(response)) {
      final errorMsg = _getApiErrorMessage(response);
      submitError.value = errorMsg;
      stage.value = CheckInStage.captured;
      _showError(errorMsg);
      return;
    }

    // Success — update HomeController with API response
    responseStatus = response.data?.status;
    stage.value = CheckInStage.success;

    await Future.delayed(const Duration(milliseconds: 300));

    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      home.hasCheckedIn.value = true;
      home.checkInTime = actionTime;
      home.checkInTimeDisplay.value = '${DateFormat('HH:mm:ss').format(actionTime)} WIB';

      // Use API response status
      if (response.data?.status != null) {
        home.checkInStatus.value = response.data!.status == 'TEPAT_WAKTU' ? 'Tepat Waktu' : 'Terlambat';
      } else {
        final isOnTime = actionTime.hour < 8 || (actionTime.hour == 8 && actionTime.minute == 0);
        home.checkInStatus.value = isOnTime ? 'Tepat Waktu' : 'Terlambat';
      }

      home.workDuration.value = '0j 0m';

      // Store attendance ID for check-out
      if (response.data?.id != null) {
        home.attendanceId.value = response.data!.id;
      }
    }

    // Auto-back after 4 seconds
    Future.delayed(const Duration(seconds: 4), () => Get.back());
  }

  Future<void> _performCheckOut() async {
    final body = {'checkOutLat': _deviceLat ?? 0.0, 'checkOutLng': _deviceLng ?? 0.0};

    final response = await _attendanceService.checkOut(body);

    isSubmitting.value = false;

    // Check for API errors (including 400 BAD_REQUEST)
    if (_isApiError(response)) {
      final errorMsg = _getApiErrorMessage(response);
      submitError.value = errorMsg;
      stage.value = CheckInStage.confirmCheckOut;
      _showError(errorMsg);
      return;
    }

    // Success
    stage.value = CheckInStage.success;

    await Future.delayed(const Duration(milliseconds: 300));

    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      home.hasCheckedIn.value = false;
      home.checkInTime = null;
      home.checkInTimeDisplay.value = '';
      home.checkInStatus.value = '';
      home.workDuration.value = '';
      home.attendanceId.value = null;
    }

    // Auto-back after 4 seconds
    Future.delayed(const Duration(seconds: 4), () => Get.back());
  }

  void _showError(String message) {
    final context = Get.context;
    if (context != null) {
      CustomSnackbar(message: message, type: CustomSnackbarType.error).show(context);
    }
  }

  // ── Cancel ────────────────────────────────────────────
  void onCancel() => Get.back();

  @override
  void onClose() {
    _clockTimer?.cancel();
    _countdownTimer?.cancel();
    cameraController?.dispose();
    pulseAnim.dispose();
    super.onClose();
  }
}
