import 'dart:io';

import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/main_check_in_out_controller.dart';

class MainCheckInOutView extends GetView<MainCheckInOutController> {
  const MainCheckInOutView({super.key});

  // ── Per-mode colors ──────────────────────────────────
  Color get _accentColor => controller.isCheckOut ? const Color(0xffE84E00) : MainColor.blue2;
  Color get _bgColor => controller.isCheckOut ? const Color(0xffFFF3E8) : const Color(0xffEEF2FF);
  Color get _ringColor => controller.isCheckOut ? const Color(0xffFF8C42) : const Color(0xff4DB6AC);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stage = controller.stage.value;
      if (stage == CheckInStage.success) {
        return _buildSuccessPage();
      }
      if (stage == CheckInStage.submitting) {
        return _buildSubmittingPage();
      }
      if (stage == CheckInStage.confirmCheckOut) {
        return _buildCheckOutConfirmPage();
      }
      return _buildCameraPage(stage);
    });
  }

  // ═══════════════════════════════════════════════════════════
  // CHECK-OUT CONFIRM PAGE (no camera)
  // ═══════════════════════════════════════════════════════════
  Widget _buildCheckOutConfirmPage() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: controller.onCancel,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: SecondaryColor.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(Icons.close_rounded, size: 18.sp, color: SecondaryColor.neutral700),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konfirmasi Check Out',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
                      ),
                      Text(
                        'Pastikan data sudah benar',
                        style: TextStyle(fontSize: 12.sp, color: _accentColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Location status banner ──────────────────────
            Obx(() {
              final isValid = controller.isLocationValid.value;
              final bannerColor = isValid ? SecondaryColor.success700 : SecondaryColor.danger600;
              final bannerIcon = isValid ? Icons.check_circle_rounded : Icons.location_off_rounded;
              final bannerText =
                  isValid
                      ? 'Dalam radius ${controller.distanceFromBranch.value.toStringAsFixed(0)}m'
                      : 'Di luar radius kantor';

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: bannerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: bannerColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(bannerIcon, size: 16.sp, color: bannerColor),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        bannerText,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: bannerColor),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Spacer(),

            // ── Info card ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: SecondaryColor.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 72.w,
                      height: 72.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xffFF8C42), Color(0xffE84E00)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(Icons.logout_rounded, color: Colors.white, size: 36.sp),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Yakin ingin Check Out?',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral700),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Check out akan dicatat pada waktu saat ini',
                      style: TextStyle(fontSize: 13.sp, color: SecondaryColor.neutral400),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    // Time & Branch
                    _infoRow(
                      icon: Icons.access_time_rounded,
                      iconColor: SecondaryColor.neutral500,
                      label: 'Waktu',
                      value: controller.actionTimeDisplay,
                      valueColor: SecondaryColor.neutral700,
                    ),
                    Divider(height: 1, thickness: 1, color: SecondaryColor.neutral200),
                    _infoRow(
                      icon: Icons.location_on_outlined,
                      iconColor: SecondaryColor.neutral500,
                      label: 'Lokasi',
                      value: controller.branch,
                      valueColor: SecondaryColor.neutral700,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ── Buttons ──────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  // Cancel
                  Expanded(
                    child: SizedBox(
                      height: 52.h,
                      child: OutlinedButton(
                        onPressed: controller.onCancel,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: SecondaryColor.neutral300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: SecondaryColor.neutral600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Confirm
                  Expanded(
                    child: SizedBox(
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: controller.onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffE84E00),
                          foregroundColor: SecondaryColor.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          elevation: 0,
                        ),
                        child: Text(
                          'Check Out',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: SecondaryColor.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 36.h),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CAMERA PAGE
  // ═══════════════════════════════════════════════════════════
  Widget _buildCameraPage(CheckInStage stage) {
    final isOut = controller.isCheckOut;
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: controller.onCancel,
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: SecondaryColor.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(Icons.close_rounded, size: 18.sp, color: SecondaryColor.neutral700),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOut ? 'Foto Check Out' : 'Foto Check In',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
                      ),
                      Text(
                        'Ambil foto selfie untuk verifikasi',
                        style: TextStyle(fontSize: 12.sp, color: _accentColor, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ── Location status banner ──────────────────────
            Obx(() {
              final isChecking = controller.isCheckingLocation.value;
              final isValid = controller.isLocationValid.value;

              Color bannerColor;
              IconData bannerIcon;
              String bannerText;

              if (isChecking) {
                bannerColor = SecondaryColor.warning600;
                bannerIcon = Icons.my_location_rounded;
                bannerText = 'Memeriksa lokasi...';
              } else if (isValid) {
                bannerColor = SecondaryColor.success700;
                bannerIcon = Icons.check_circle_rounded;
                bannerText = 'Dalam radius ${controller.distanceFromBranch.value.toStringAsFixed(0)}m';
              } else {
                bannerColor = SecondaryColor.danger600;
                bannerIcon = Icons.location_off_rounded;
                bannerText =
                    controller.locationError.value.isNotEmpty ? controller.locationError.value : 'Di luar radius kantor';
              }

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: bannerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: bannerColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    if (isChecking)
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(strokeWidth: 2, color: bannerColor),
                      )
                    else
                      Icon(bannerIcon, size: 16.sp, color: bannerColor),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        bannerText,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: bannerColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 12.h),

            // ── Camera viewfinder ────────────────────────
            Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.w), child: _buildViewfinder(stage))),

            SizedBox(height: 16.h),

            // ── Status label ──────────────────────────────
            _buildStatusLabel(stage),

            SizedBox(height: 20.h),

            // ── Action buttons ────────────────────────────
            Obx(() {
              final canCapture = controller.isLocationValid.value && !controller.isCheckingLocation.value;
              if (stage == CheckInStage.captured) {
                return _buildConfirmButtons();
              }
              return _buildCaptureButton(stage, enabled: canCapture);
            }),

            SizedBox(height: 36.h),
          ],
        ),
      ),
    );
  }

  // ── Viewfinder ────────────────────────────────────────────
  Widget _buildViewfinder(CheckInStage stage) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xff1A1F2E), borderRadius: BorderRadius.circular(20.r)),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview or captured photo
          if (stage == CheckInStage.captured && controller.capturedPhoto != null)
            // Show captured photo
            Image.file(File(controller.capturedPhoto!.path), fit: BoxFit.cover)
          else if (!controller.isCheckOut)
            // Show live camera preview
            Obx(() {
              if (controller.isCameraReady.value && controller.cameraController != null) {
                return Transform.scale(
                  scaleX: -1, // Mirror front camera
                  child: CameraPreview(controller.cameraController!),
                );
              }
              return const Center(child: CircularProgressIndicator(color: Colors.white54));
            })
          else
            // Check-out: no camera, just dark background
            CustomPaint(painter: _GridPainter()),

          // Camera grid overlay (only during live preview)
          if (stage != CheckInStage.captured) CustomPaint(painter: _GridPainter()),

          // Face oval
          Positioned.fill(child: _FaceOverlay(stage: stage, ringColor: _ringColor)),

          // Branch name
          Positioned(
            top: 14.h,
            left: 14.w,
            child: Obx(
              () => Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 13.sp, color: SecondaryColor.success500),
                  SizedBox(width: 4.w),
                  Text(
                    controller.branch,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: SecondaryColor.white),
                  ),
                ],
              ),
            ),
          ),

          // Live clock
          Positioned(
            top: 14.h,
            right: 14.w,
            child: Obx(
              () => Text(
                controller.liveTime.value,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: SecondaryColor.white),
              ),
            ),
          ),

          // Verifikasi label
          Positioned(
            bottom: 14.h,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.security_rounded, size: 13.sp, color: SecondaryColor.success500),
                  SizedBox(width: 5.w),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: SecondaryColor.white),
                      children: [
                        const TextSpan(text: 'Verifikasi '),
                        const TextSpan(text: 'wajah ', style: TextStyle(color: Color(0xff4AEDB4))),
                        const TextSpan(text: 'aktif'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Countdown
          if (stage == CheckInStage.countdown)
            Center(child: Obx(() => _CountdownBubble(number: controller.countdown.value))),
        ],
      ),
    );
  }

  // ── Submitting page (loading) ───────────────────────────────
  Widget _buildSubmittingPage() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 48.w, height: 48.w, child: CircularProgressIndicator(strokeWidth: 4, color: _accentColor)),
            SizedBox(height: 20.h),
            Text(
              controller.isCheckOut ? 'Memproses Check Out...' : 'Memproses Check In...',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: SecondaryColor.neutral600),
            ),
            SizedBox(height: 8.h),
            Text('Mohon tunggu sebentar', style: TextStyle(fontSize: 13.sp, color: SecondaryColor.neutral400)),
          ],
        ),
      ),
    );
  }

  // ── Status label ──────────────────────────────────────────
  Widget _buildStatusLabel(CheckInStage stage) {
    final text = switch (stage) {
      CheckInStage.idle => 'Posisikan wajah Anda di dalam lingkaran',
      CheckInStage.countdown => 'Bersiap...',
      CheckInStage.captured => 'Foto berhasil diambil!',
      _ => '',
    };
    final color = stage == CheckInStage.captured ? _accentColor : SecondaryColor.neutral500;
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        color: color,
        fontWeight: stage == CheckInStage.captured ? FontWeight.w600 : FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    );
  }

  // ── Capture button ────────────────────────────────────────
  Widget _buildCaptureButton(CheckInStage stage, {bool enabled = true}) {
    final canTap = stage == CheckInStage.idle && enabled;
    return GestureDetector(
      onTap: canTap ? controller.onCaptureButtonTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 68.w,
        height: 68.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: canTap ? _accentColor : SecondaryColor.neutral300,
          boxShadow: canTap ? [BoxShadow(color: _accentColor.withOpacity(0.45), blurRadius: 20, spreadRadius: 3)] : [],
        ),
        child: Icon(Icons.camera_alt_rounded, color: SecondaryColor.white, size: 30.sp),
      ),
    );
  }

  // ── Confirm buttons ───────────────────────────────────────
  Widget _buildConfirmButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _iconCircleBtn(
          icon: Icons.refresh_rounded,
          color: SecondaryColor.white,
          iconColor: SecondaryColor.neutral600,
          size: 56.w,
          onTap: controller.onRetry,
        ),
        SizedBox(width: 20.w),
        _iconCircleBtn(
          icon: Icons.check_rounded,
          color: SecondaryColor.success700,
          iconColor: SecondaryColor.white,
          size: 68.w,
          onTap: controller.onConfirm,
          shadow: true,
        ),
        SizedBox(width: 20.w),
        _iconCircleBtn(
          icon: Icons.close_rounded,
          color: SecondaryColor.white,
          iconColor: SecondaryColor.neutral600,
          size: 56.w,
          onTap: controller.onCancel,
        ),
      ],
    );
  }

  Widget _iconCircleBtn({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required double size,
    required VoidCallback onTap,
    bool shadow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow:
              shadow
                  ? [BoxShadow(color: SecondaryColor.success700.withOpacity(0.4), blurRadius: 20, spreadRadius: 3)]
                  : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Icon(icon, size: 26.sp, color: iconColor),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SUCCESS PAGE
  // ═══════════════════════════════════════════════════════════
  Widget _buildSuccessPage() {
    final isOut = controller.isCheckOut;
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Success circle
              _SuccessCheckmark(anim: controller.pulseAnim, isCheckOut: isOut),

              SizedBox(height: 24.h),

              Text(
                isOut ? 'Check Out Berhasil!' : 'Check In Berhasil!',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
              ),
              SizedBox(height: 6.h),
              Text(
                isOut ? 'Terima kasih atas kerja keras Anda hari ini' : 'Kehadiran Anda telah tercatat',
                style: TextStyle(fontSize: 14.sp, color: SecondaryColor.neutral500),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              // Info card
              isOut ? _buildCheckOutInfoCard() : _buildCheckInInfoCard(),

              const Spacer(),

              // Back button — color matches theme
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOut ? SecondaryColor.neutral700 : MainColor.blue2,
                    foregroundColor: SecondaryColor.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    elevation: 0,
                  ),
                  child: Text(
                    isOut ? 'Kembali' : 'Kembali ke Beranda',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: SecondaryColor.white),
                  ),
                ),
              ),

              SizedBox(height: 12.h),
              Text(
                'Otomatis kembali dalam beberapa detik...',
                style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral400),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Check-In success info ──────────────────────────────────
  Widget _buildCheckInInfoCard() {
    final ctrl = controller;
    return _infoCard([
      _infoRow(
        icon: Icons.access_time_rounded,
        iconColor: SecondaryColor.neutral500,
        label: 'Waktu',
        value: ctrl.actionTimeDisplay,
        valueColor: SecondaryColor.neutral700,
      ),
      _divider(),
      _infoRow(
        icon: Icons.verified_user_outlined,
        iconColor: SecondaryColor.neutral500,
        label: 'Status',
        value: ctrl.checkInStatusText,
        valueColor: ctrl.checkInStatusText == 'Tepat Waktu' ? SecondaryColor.success700 : SecondaryColor.warning600,
        dot: ctrl.checkInStatusText == 'Tepat Waktu' ? SecondaryColor.success700 : SecondaryColor.warning600,
      ),
      _divider(),
      _infoRow(
        icon: Icons.location_on_outlined,
        iconColor: SecondaryColor.neutral500,
        label: 'Lokasi',
        value: ctrl.branch,
        valueColor: SecondaryColor.neutral700,
      ),
      _divider(),
      _infoRow(
        icon: Icons.star_outline_rounded,
        iconColor: SecondaryColor.warning600,
        label: 'Poin',
        value: ctrl.poinEarned,
        valueColor: SecondaryColor.success700,
      ),
    ]);
  }

  // ── Check-Out success info ─────────────────────────────────
  Widget _buildCheckOutInfoCard() {
    final ctrl = controller;
    return _infoCard([
      _infoRow(
        icon: Icons.access_time_rounded,
        iconColor: SecondaryColor.neutral500,
        label: 'Check In',
        value: ctrl.storedCheckInTimeDisplay,
        valueColor: SecondaryColor.neutral700,
      ),
      _divider(),
      _infoRow(
        icon: Icons.access_time_rounded,
        iconColor: SecondaryColor.neutral500,
        label: 'Check Out',
        value: ctrl.actionTimeDisplay,
        valueColor: SecondaryColor.neutral700,
      ),
      _divider(),
      _infoRow(
        icon: Icons.language_outlined,
        iconColor: SecondaryColor.neutral500,
        label: 'Lokasi',
        value: ctrl.branch,
        valueColor: SecondaryColor.neutral700,
      ),
      _divider(),
      _infoRow(
        icon: Icons.access_time_rounded,
        iconColor: SecondaryColor.neutral500,
        label: 'Total Durasi',
        value: ctrl.workDurationDisplay,
        valueColor: SecondaryColor.neutral700,
      ),
    ]);
  }

  Widget _infoCard(List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: SecondaryColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(children: rows),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
    Color? dot,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: iconColor),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11.sp, color: SecondaryColor.neutral400)),
              SizedBox(height: 3.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dot != null) ...[
                    Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
                    SizedBox(width: 5.w),
                  ],
                  Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: valueColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, thickness: 1, color: SecondaryColor.neutral200);
}

// ════════════════════════════════════════════════════════════
// Custom painter: camera grid
// ════════════════════════════════════════════════════════════
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.07)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke;
    for (int i = 1; i < 3; i++) {
      final x = size.width * i / 3;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ════════════════════════════════════════════════════════════
// Face oval with dashed ring, color-keyed to mode
// ════════════════════════════════════════════════════════════
class _FaceOverlay extends StatelessWidget {
  final CheckInStage stage;
  final Color ringColor;
  const _FaceOverlay({required this.stage, required this.ringColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200.w,
        height: 200.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: Size(200.w, 200.w), painter: _DashedCirclePainter(stage: stage, ringColor: ringColor)),
            if (stage == CheckInStage.idle)
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(Icons.person_outline_rounded, size: 44.sp, color: Colors.white.withOpacity(0.5)),
              ),
            if (stage == CheckInStage.captured)
              Container(
                width: 80.w,
                height: 80.w,
                decoration: const BoxDecoration(color: Color(0xff0C9D61), shape: BoxShape.circle),
                child: Icon(Icons.check_rounded, size: 44.sp, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final CheckInStage stage;
  final Color ringColor;
  _DashedCirclePainter({required this.stage, required this.ringColor});

  @override
  void paint(Canvas canvas, Size size) {
    final isCapture = stage == CheckInStage.captured;
    final paint =
        Paint()
          ..color = isCapture ? const Color(0xff0C9D61) : ringColor
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dashCount = 30;
    final dashLength = (2 * 3.14159 * radius) / (dashCount * 2);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * 2 * 3.14159 / dashCount;
      final sweepAngle = dashLength / radius;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) => old.stage != stage || old.ringColor != ringColor;
}

// ════════════════════════════════════════════════════════════
// Animated countdown bubble
// ════════════════════════════════════════════════════════════
class _CountdownBubble extends StatefulWidget {
  final int number;
  const _CountdownBubble({required this.number});

  @override
  State<_CountdownBubble> createState() => _CountdownBubbleState();
}

class _CountdownBubbleState extends State<_CountdownBubble> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(_CountdownBubble old) {
    super.didUpdateWidget(old);
    if (old.number != widget.number) _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
        child: Center(
          child: Text(
            '${widget.number}',
            style: TextStyle(fontSize: 44.sp, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

// ════════════════════════════════════════════════════════════
// Success checkmark with animated confetti dots
// ════════════════════════════════════════════════════════════
class _SuccessCheckmark extends StatelessWidget {
  final AnimationController anim;
  final bool isCheckOut;
  const _SuccessCheckmark({required this.anim, required this.isCheckOut});

  @override
  Widget build(BuildContext context) {
    final shadowColor = isCheckOut ? const Color(0xffFF6B2C) : SecondaryColor.success700;

    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) {
        final t = anim.value;
        return SizedBox(
          width: 160.w,
          height: 160.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dots — warmer palette for check-out
              _dot(isCheckOut ? Colors.orange : Colors.orange, Offset(-55.w * (0.9 + t * 0.1), -40.h * (0.9 + t * 0.1)), 10),
              _dot(
                isCheckOut ? Colors.pink.shade300 : Colors.purple,
                Offset(55.w * (0.9 + t * 0.1), -45.h * (0.9 + t * 0.1)),
                8,
              ),
              _dot(
                isCheckOut ? const Color(0xffFF8C42) : Colors.blue,
                Offset(-50.w * (0.9 + t * 0.1), 45.h * (0.9 + t * 0.1)),
                9,
              ),
              _dot(
                isCheckOut ? Colors.yellow.shade600 : const Color(0xff4AEDB4),
                Offset(52.w * (0.9 + t * 0.1), 48.h * (0.9 + t * 0.1)),
                10,
              ),

              // Circle
              Container(
                width: 96.w,
                height: 96.w,
                decoration:
                    isCheckOut
                        ? BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xffFF8C42), Color(0xffE84E00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.35), blurRadius: 24, spreadRadius: 4)],
                        )
                        : BoxDecoration(
                          shape: BoxShape.circle,
                          color: SecondaryColor.success700,
                          boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.35), blurRadius: 24, spreadRadius: 4)],
                        ),
                child: Icon(Icons.check_rounded, color: Colors.white, size: 52.sp),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dot(Color color, Offset offset, double size) {
    return Positioned(
      left: 80.w + offset.dx - size / 2,
      top: 80.h + offset.dy - size / 2,
      child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    );
  }
}
