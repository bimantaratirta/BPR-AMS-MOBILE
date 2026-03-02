import 'dart:async';

import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:bpr_ams/app/modules/main/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ── State machine for the screen ─────────────────────────
enum CheckInStage {
  idle, // camera ready, waiting for tap
  countdown, // 3-2-1 countdown running
  captured, // photo "taken" — show checkmark + action buttons
  success, // confirmed — show success page
}

class MainCheckInOutController extends GetxController with GetTickerProviderStateMixin {
  final authController = Get.find<AuthController>();

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

  // ── Result data ───────────────────────────────────────
  late DateTime actionTime; // time of check-in or check-out

  String get actionTimeDisplay => '${DateFormat('HH:mm:ss').format(actionTime)} WIB';

  String get checkInStatusText {
    if (isCheckOut) return '';
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
  String get branch => authController.user.value?.branch?.branch ?? 'Kantor Pusat';

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
  }

  void _startClock() {
    liveTime.value = DateFormat('HH.mm.ss').format(DateTime.now());
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      liveTime.value = DateFormat('HH.mm.ss').format(DateTime.now());
    });
  }

  // ── Trigger countdown ─────────────────────────────────
  void onCaptureButtonTap() {
    if (stage.value != CheckInStage.idle) return;
    stage.value = CheckInStage.countdown;
    countdown.value = 3;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown.value > 1) {
        countdown.value--;
      } else {
        t.cancel();
        actionTime = DateTime.now();
        stage.value = CheckInStage.captured;
      }
    });
  }

  // ── Retry ─────────────────────────────────────────────
  void onRetry() {
    _countdownTimer?.cancel();
    stage.value = CheckInStage.idle;
    countdown.value = 3;
  }

  // ── Confirm ───────────────────────────────────────────
  Future<void> onConfirm() async {
    stage.value = CheckInStage.success;

    await Future.delayed(const Duration(milliseconds: 300));

    // Update HomeController state
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      if (isCheckOut) {
        home.hasCheckedIn.value = false;
        home.checkInTime = null;
        home.checkInTimeDisplay.value = '';
        home.checkInStatus.value = '';
        home.workDuration.value = '';
      } else {
        home.hasCheckedIn.value = true;
        home.checkInTime = actionTime;
        home.checkInTimeDisplay.value = '${DateFormat('HH:mm:ss').format(actionTime)} WIB';
        final isOnTime = actionTime.hour < 8 || (actionTime.hour == 8 && actionTime.minute == 0);
        home.checkInStatus.value = isOnTime ? 'Tepat Waktu' : 'Terlambat';
        home.workDuration.value = '0j 0m';
      }
    }

    // Auto-back after 4 seconds
    Future.delayed(const Duration(seconds: 4), () => Get.back());
  }

  // ── Cancel ────────────────────────────────────────────
  void onCancel() => Get.back();

  @override
  void onClose() {
    _clockTimer?.cancel();
    _countdownTimer?.cancel();
    pulseAnim.dispose();
    super.onClose();
  }
}
