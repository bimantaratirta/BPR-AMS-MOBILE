import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/routes/app_pages.dart';
import 'package:bpr_ams/app/widgets/build_custom_painter.dart';
import 'package:bpr_ams/app/widgets/build_custom_snackbar.dart';
import 'package:bpr_ams/app/widgets/build_navigation/build_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // ─── Warna tema berdasarkan state ───────────────────────────
  Color get _bgColor {
    if (controller.hasCheckedOut.value) return const Color(0xffF0FFF4); // hijau muda (selesai)
    if (controller.hasCheckedIn.value) return const Color(0xffFFF3E8); // warm peach (check-in)
    return const Color(0xffEEF2FF); // biru muda (belum check-in)
  }

  /// Warna chip status berdasarkan enum
  Color _statusColor(String status) {
    switch (status) {
      case 'Tepat Waktu':
        return SecondaryColor.success700;
      case 'Terlambat':
        return SecondaryColor.warning600;
      case 'Izin / Cuti':
      case 'Izin Sakit':
      case '½ Hari':
        return MainColor.blue2;
      case 'Alpha':
        return SecondaryColor.danger600;
      default:
        return SecondaryColor.neutral500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child:
              controller.isLoadingAttendance.value
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 20.h),
                        _buildEmployeeCard(),
                        SizedBox(height: 12.h),
                        _buildPointsCard(),
                        SizedBox(height: 12.h),
                        // Card check-in/out info hanya muncul setelah check-in
                        if (controller.hasCheckedIn.value) ...[_buildCheckedInInfoCard(), SizedBox(height: 12.h)],
                        SizedBox(height: 20.h),
                        _buildClock(),
                        SizedBox(height: 8.h),
                        // Durasi kerja hanya muncul setelah check-in & belum checkout
                        if (controller.hasCheckedIn.value && !controller.hasCheckedOut.value) _buildWorkDuration(),
                        SizedBox(height: 24.h),
                        _buildModeToggle(),
                        _buildCheckButton(),
                        SizedBox(height: 28.h),
                        _buildLocationCard(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
        ),
        bottomNavigationBar: const BuildBottomNavigationBar(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    final checkedIn = controller.hasCheckedIn.value;
    final done = controller.hasCheckedOut.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.currentDateDisplay.value,
          style: TextStyle(fontSize: 13.sp, color: SecondaryColor.neutral500, fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: Text(
                done
                    ? 'Absensi Selesai ✅'
                    : checkedIn
                    ? 'Check Out ${controller.greetingEmoji}'
                    : '${controller.greeting}, ${controller.userName} ${controller.greetingEmoji}',
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Employee Card
  // ─────────────────────────────────────────────
  Widget _buildEmployeeCard() {
    final done = controller.hasCheckedOut.value;
    final checkedIn = controller.hasCheckedIn.value;
    final accentColor =
        done
            ? SecondaryColor.success700
            : checkedIn
            ? const Color(0xffFF6B2C)
            : MainColor.blue2;
    return GestureDetector(
      onTap: () => Get.toNamed('${Routes.MAIN}${Routes.MAIN_PROFILE}'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.person_rounded, color: SecondaryColor.white, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: SecondaryColor.neutral700),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${controller.userNik} • ${controller.userRole} • ${controller.userBranch}',
                    style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: SecondaryColor.neutral400, size: 22.sp),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Points Card
  // ─────────────────────────────────────────────
  Widget _buildPointsCard() {
    return GestureDetector(
      onTap: () => Get.toNamed('${Routes.MAIN}${Routes.MAIN_POIN}'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(color: const Color(0xffFFF7E1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(Icons.star_rounded, color: SecondaryColor.warning600, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.attendancePoints.value} Poin',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: SecondaryColor.neutral700),
                  ),
                  SizedBox(height: 2.h),
                  Text('Total poin kehadiran Anda', style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: SecondaryColor.neutral400, size: 22.sp),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Check-in Info Card (muncul saat sudah check-in)
  // ─────────────────────────────────────────────
  Widget _buildCheckedInInfoCard() {
    final status = controller.checkInStatus.value;
    final statusColor = _statusColor(status);
    final isDone = controller.hasCheckedOut.value;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // ── Baris Check-in
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(color: const Color(0xffE5F5EC), borderRadius: BorderRadius.circular(12.r)),
                child: Icon(Icons.login_rounded, color: SecondaryColor.success700, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check In',
                      style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      controller.checkInTimeDisplay.value.isEmpty ? "-" : controller.checkInTimeDisplay.value,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral700),
                    ),
                  ],
                ),
              ),
              // Status chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20.r)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7.w,
                      height: 7.w,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 5.w),
                    Text(status, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: statusColor)),
                  ],
                ),
              ),
            ],
          ),
          // ── Baris Check-out (hanya tampil jika sudah checkout)
          if (isDone) ...[
            Divider(height: 20.h, thickness: 1, color: SecondaryColor.neutral100),
            Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(color: const Color(0xffFFF7E1), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(Icons.logout_rounded, color: SecondaryColor.warning600, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check Out',
                        style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        controller.checkOutTimeDisplay.value,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral700),
                      ),
                    ],
                  ),
                ),
                if (controller.workDuration.value.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(color: SecondaryColor.neutral100, borderRadius: BorderRadius.circular(20.r)),
                    child: Text(
                      controller.workDuration.value,
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: SecondaryColor.neutral600),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Live Clock
  // ─────────────────────────────────────────────
  Widget _buildClock() {
    final parts = controller.currentTime.value.split(':');
    if (parts.length != 3) return const SizedBox.shrink();
    final hh = parts[0];
    final mm = parts[1];
    final ss = parts[2];

    final colonColor = controller.hasCheckedIn.value ? const Color(0xffFF6B2C) : MainColor.blue2;

    return Center(
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 52.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700, letterSpacing: 2),
          children: [
            TextSpan(text: hh),
            TextSpan(text: ':', style: TextStyle(color: colonColor, fontSize: 52.sp)),
            TextSpan(text: mm),
            TextSpan(text: ':', style: TextStyle(color: colonColor, fontSize: 52.sp)),
            TextSpan(text: ss),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Work Duration (hanya saat sudah check-in)
  // ─────────────────────────────────────────────
  Widget _buildWorkDuration() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 15.sp, color: SecondaryColor.neutral500),
          SizedBox(width: 4.w),
          Text('Durasi kerja: ', style: TextStyle(fontSize: 13.sp, color: SecondaryColor.neutral500)),
          Text(
            controller.workDuration.value,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xffFF6B2C)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Manual Mode Toggle
  // ─────────────────────────────────────────────
  Widget _buildModeToggle() {
    if (controller.hasCheckedOut.value) return const SizedBox.shrink(); // Hide if completely done

    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: SecondaryColor.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => controller.hasCheckedIn.value = false,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: !controller.hasCheckedIn.value ? MainColor.blue2 : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Check In',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: !controller.hasCheckedIn.value ? FontWeight.w700 : FontWeight.w500,
                    color: !controller.hasCheckedIn.value ? SecondaryColor.white : SecondaryColor.neutral500,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => controller.hasCheckedIn.value = true,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: controller.hasCheckedIn.value ? const Color(0xffFF6B2C) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Check Out',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: controller.hasCheckedIn.value ? FontWeight.w700 : FontWeight.w500,
                    color: controller.hasCheckedIn.value ? SecondaryColor.white : SecondaryColor.neutral500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Check In / Check Out Button
  // ─────────────────────────────────────────────
  Widget _buildCheckButton() {
    final checkedIn = controller.hasCheckedIn.value;
    final isDone = controller.hasCheckedOut.value;
    final inRadius = controller.isInRadius.value;
    final isChecking = controller.isCheckingLocation.value;

    // Jika sudah selesai (checkin + checkout), tombol greyed out
    final isDisabled = isDone || (!inRadius && !isChecking);
    final canAct = !isDone && !isChecking && inRadius;

    Color gradStart, gradEnd, shadowColor;
    IconData btnIcon;
    String btnLabel;

    if (isDone) {
      gradStart = SecondaryColor.success700;
      gradEnd = const Color(0xff1B8C4E);
      shadowColor = SecondaryColor.success700;
      btnIcon = Icons.check_circle_rounded;
      btnLabel = 'Selesai';
    } else if (!inRadius || isChecking) {
      gradStart = SecondaryColor.neutral400;
      gradEnd = SecondaryColor.neutral500;
      shadowColor = SecondaryColor.neutral400;
      btnIcon = isChecking ? Icons.my_location_rounded : Icons.location_off_rounded;
      btnLabel = isChecking ? 'Cek Lokasi' : 'Di Luar Area';
    } else if (checkedIn) {
      gradStart = const Color(0xffFF8C42);
      gradEnd = const Color(0xffE84E00);
      shadowColor = const Color(0xffFF6B2C);
      btnIcon = Icons.logout_rounded;
      btnLabel = 'Check Out';
    } else {
      gradStart = MainColor.blue3;
      gradEnd = MainColor.blue5;
      shadowColor = MainColor.blue2;
      btnIcon = Icons.fingerprint_rounded;
      btnLabel = 'Check In';
    }

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (!canAct) {
                if (isDone) return; // sudah selesai, tidak bisa tap
                final ctx = Get.context;
                if (ctx == null) return;
                if (isChecking) {
                  CustomSnackbar(message: 'Sedang memeriksa lokasi...', type: CustomSnackbarType.warning).show(ctx);
                } else {
                  final errorMsg =
                      controller.locationErrorMessage.value.isNotEmpty
                          ? controller.locationErrorMessage.value
                          : 'Anda di luar radius kantor.';
                  CustomSnackbar(message: errorMsg, type: CustomSnackbarType.error).show(ctx);
                }
                return;
              }
              if (checkedIn) {
                // Langsung ke konfirmasi checkout (tanpa kamera)
                Get.toNamed('${Routes.MAIN}${Routes.MAIN_CHECK_IN_OUT}', arguments: {'isCheckOut': true});
              } else {
                Get.toNamed('${Routes.MAIN}${Routes.MAIN_CHECK_IN_OUT}');
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [gradStart, gradEnd], center: Alignment.center, radius: 0.85),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(isDisabled ? 0.2 : 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isChecking && !isDone)
                    SizedBox(
                      width: 36.w,
                      height: 36.w,
                      child: CircularProgressIndicator(strokeWidth: 3, color: SecondaryColor.white),
                    )
                  else
                    Icon(btnIcon, color: SecondaryColor.white, size: 48.sp),
                  SizedBox(height: 6.h),
                  Text(
                    btnLabel,
                    style: TextStyle(color: SecondaryColor.white, fontWeight: FontWeight.w600, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
          ),
          if (!inRadius && !isChecking && !isDone) ...[
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () => controller.refreshLocation(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: SecondaryColor.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 16.sp, color: MainColor.blue2),
                    SizedBox(width: 6.w),
                    Text(
                      'Refresh Lokasi',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: MainColor.blue2),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (isDone) ...[
            SizedBox(height: 10.h),
            Text(
              'Absensi hari ini sudah selesai',
              style: TextStyle(fontSize: 12.sp, color: SecondaryColor.success700, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Location Card
  // ─────────────────────────────────────────────
  Widget _buildLocationCard() {
    final isChecking = controller.isCheckingLocation.value;
    final dotColor =
        isChecking
            ? SecondaryColor.warning600
            : controller.isInRadius.value
            ? SecondaryColor.success700
            : SecondaryColor.danger600;
    final mapDotColor = controller.hasCheckedIn.value ? const Color(0xffFF6B2C) : MainColor.blue2;

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_rounded, color: mapDotColor, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Anda',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: SecondaryColor.neutral700),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        controller.userBranch.isNotEmpty && controller.userBranch != '-'
                            ? '${controller.userBranch} - BPR Sahabat Sejati'
                            : 'BPR Sahabat Sejati',
                        style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Map placeholder
          Container(
            height: 140.h,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: controller.hasCheckedIn.value ? const Color(0xffF2E8DC) : const Color(0xffE8EEF8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: CustomPaint(
                      painter: BuildCustomPainter(
                        lineColor: controller.hasCheckedIn.value ? const Color(0xffE0CDB8) : const Color(0xffCDD8EE),
                      ),
                    ),
                  ),
                ),
                // Radius circle
                Center(
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mapDotColor.withOpacity(0.12),
                      border: Border.all(
                        color: mapDotColor.withOpacity(0.3),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: mapDotColor,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: mapDotColor.withOpacity(0.4), blurRadius: 6, spreadRadius: 2)],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Status chip + distance info
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isChecking)
                      SizedBox(
                        width: 12.w,
                        height: 12.w,
                        child: CircularProgressIndicator(strokeWidth: 2, color: SecondaryColor.warning600),
                      )
                    else
                      Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                    SizedBox(width: 6.w),
                    Text(
                      isChecking
                          ? 'Memeriksa lokasi...'
                          : controller.isInRadius.value
                          ? 'Dalam Radius'
                          : 'Di Luar Radius',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: dotColor),
                    ),
                  ],
                ),
                if (!isChecking && controller.distanceFromBranch.value > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Jarak: ${controller.distanceFromBranch.value.toStringAsFixed(0)}m dari kantor',
                    style: TextStyle(fontSize: 11.sp, color: SecondaryColor.neutral500),
                  ),
                ],
                if (!isChecking && controller.locationErrorMessage.value.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    controller.locationErrorMessage.value,
                    style: TextStyle(fontSize: 11.sp, color: SecondaryColor.danger600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: SecondaryColor.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
    );
  }
}
