import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/main_profile_controller.dart';

class MainProfileView extends GetView<MainProfileController> {
  const MainProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF2FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AppBar custom ──────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(4.w, 12.h, 20.w, 8.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: SecondaryColor.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: 20.sp, color: SecondaryColor.neutral700),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Profil',
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
                  ),
                ],
              ),
            ),

            // ── Content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    _buildProfileCard(),
                    SizedBox(height: 16.h),
                    _buildMenuCard(),
                    SizedBox(height: 32.h),
                    _buildVersionFooter(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Profile card
  // ─────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: SecondaryColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Obx(
        () => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(color: MainColor.blue2, shape: BoxShape.circle),
              child: Icon(Icons.person_rounded, color: SecondaryColor.white, size: 34.sp),
            ),
            SizedBox(width: 16.w),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.name,
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral700),
                  ),
                  SizedBox(height: 5.h),
                  _infoRow(Icons.email_outlined, controller.email),
                  SizedBox(height: 3.h),
                  _infoRow(Icons.badge_outlined, '${controller.nik} • ${controller.role} • ${controller.branch}'),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Verified badge
            Container(
              width: 30.w,
              height: 30.w,
              decoration: BoxDecoration(color: MainColor.blueLight1, shape: BoxShape.circle),
              child: Icon(Icons.verified_rounded, color: MainColor.blue2, size: 18.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13.sp, color: SecondaryColor.neutral400),
        SizedBox(width: 5.w),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500, height: 1.4))),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Menu card
  // ─────────────────────────────────────────────
  Widget _buildMenuCard() {
    return Container(
      decoration: BoxDecoration(
        color: SecondaryColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // _menuItem(
          //   icon: Icons.notifications_outlined,
          //   iconBgColor: MainColor.blueLight1,
          //   iconColor: MainColor.blue2,
          //   label: 'Notifikasi',
          //   onTap: controller.onNotifikasiTap,
          //   showDivider: true,
          // ),
          // _menuItem(
          //   icon: Icons.settings_outlined,
          //   iconBgColor: MainColor.blueLight1,
          //   iconColor: MainColor.blue2,
          //   label: 'Pengaturan',
          //   onTap: controller.onPengaturanTap,
          //   showDivider: true,
          // ),
          _menuItem(
            icon: Icons.logout_rounded,
            iconBgColor: const Color(0xffFFE2F2),
            iconColor: SecondaryColor.danger600,
            label: 'Keluar',
            labelColor: SecondaryColor.danger600,
            onTap: controller.onKeluarTap,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    Color? labelColor,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(icon, size: 20.sp, color: iconColor),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: labelColor ?? SecondaryColor.neutral700,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: SecondaryColor.neutral300, size: 22.sp),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, thickness: 1, indent: 18.w, endIndent: 18.w, color: SecondaryColor.neutral200),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Version footer
  // ─────────────────────────────────────────────
  Widget _buildVersionFooter() {
    return Text(
      'BPR AMS v1.0.0',
      style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral400, fontWeight: FontWeight.w400),
    );
  }
}
