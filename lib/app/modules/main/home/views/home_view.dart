import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/routes/app_pages.dart';
import 'package:bpr_ams/app/widgets/build_navigation/build_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  // ─── Warna tema berdasarkan state ───────────────────────────
  Color get _bgColor =>
      controller.hasCheckedIn.value
          ? const Color(0xffFFF3E8) // warm peach (sudah check-in)
          : const Color(0xffEEF2FF); // biru muda (belum check-in)

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
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
                // Card check-in info hanya muncul setelah check-in
                if (controller.hasCheckedIn.value) ...[_buildCheckedInInfoCard(), SizedBox(height: 12.h)],
                SizedBox(height: 20.h),
                _buildClock(),
                SizedBox(height: 8.h),
                // Durasi kerja hanya muncul setelah check-in
                if (controller.hasCheckedIn.value) _buildWorkDuration(),
                SizedBox(height: 24.h),
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
                checkedIn
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
    final checkedIn = controller.hasCheckedIn.value;
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
              decoration: BoxDecoration(
                color: checkedIn ? const Color(0xffFF6B2C) : MainColor.blue2,
                borderRadius: BorderRadius.circular(12.r),
              ),
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
  // Check-in Info Card (hanya muncul saat sudah check-in)
  // ─────────────────────────────────────────────
  Widget _buildCheckedInInfoCard() {
    final isOnTime = controller.checkInStatus.value == 'Tepat Waktu';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(color: const Color(0xffE5F5EC), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.check_circle_outline_rounded, color: SecondaryColor.success700, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check In Hari Ini',
                  style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 2.h),
                Text(
                  controller.checkInTimeDisplay.value,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral700),
                ),
              ],
            ),
          ),
          // Status chip
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isOnTime ? const Color(0xffE5F5EC) : const Color(0xffFFEBEE),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: BoxDecoration(
                    color: isOnTime ? SecondaryColor.success700 : SecondaryColor.danger600,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  controller.checkInStatus.value,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isOnTime ? SecondaryColor.success700 : SecondaryColor.danger600,
                  ),
                ),
              ],
            ),
          ),
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
  // Check In / Check Out Button
  // ─────────────────────────────────────────────
  Widget _buildCheckButton() {
    final checkedIn = controller.hasCheckedIn.value;

    return Center(
      child: GestureDetector(
        onTap:
            checkedIn
                ? () => Get.toNamed('${Routes.MAIN}${Routes.MAIN_CHECK_IN_OUT}', arguments: {'isCheckOut': true})
                : () => Get.toNamed('${Routes.MAIN}${Routes.MAIN_CHECK_IN_OUT}'),
        child: Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: checkedIn ? [const Color(0xffFF8C42), const Color(0xffE84E00)] : [MainColor.blue3, MainColor.blue5],
              center: Alignment.center,
              radius: 0.85,
            ),
            boxShadow: [
              BoxShadow(
                color: (checkedIn ? const Color(0xffFF6B2C) : MainColor.blue2).withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: 4,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(checkedIn ? Icons.logout_rounded : Icons.fingerprint_rounded, color: SecondaryColor.white, size: 48.sp),
              SizedBox(height: 6.h),
              Text(
                checkedIn ? 'Check Out' : 'Check In',
                style: TextStyle(color: SecondaryColor.white, fontWeight: FontWeight.w600, fontSize: 13.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Location Card
  // ─────────────────────────────────────────────
  Widget _buildLocationCard() {
    final dotColor = controller.isInRadius.value ? SecondaryColor.success700 : SecondaryColor.danger600;
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
                      painter: _MapGridPainter(
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
          // Status chip
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                SizedBox(width: 6.w),
                Text(
                  controller.isInRadius.value ? 'Dalam Radius' : 'Di Luar Radius',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: dotColor),
                ),
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

class _MapGridPainter extends CustomPainter {
  final Color lineColor;
  const _MapGridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 0.8;
    for (double y = 0; y < size.height; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter old) => old.lineColor != lineColor;
}
