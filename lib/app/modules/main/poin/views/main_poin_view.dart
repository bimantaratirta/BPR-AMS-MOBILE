import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/data/modules/point_record/models/point_record_model.dart';
import 'package:bpr_ams/app/modules/main/poin/controllers/main_poin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MainPoinView extends GetView<MainPoinController> {
  const MainPoinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF2FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AppBar ─────────────────────────────────
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
                    'Poin Saya',
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
                  ),
                ],
              ),
            ),

            // ── Scrollable body with pull-to-refresh ──
            Expanded(
              child: Obx(
                () => RefreshIndicator(
                  color: MainColor.blue2,
                  onRefresh: controller.onRefresh,
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4.h),
                        _buildTotalPoinCard(),
                        SizedBox(height: 16.h),
                        _buildAturanPoinCard(),
                        SizedBox(height: 16.h),
                        _buildMonthSelector(),
                        SizedBox(height: 12.h),
                        _buildMonthSummaryCard(),
                        SizedBox(height: 20.h),
                        _buildRiwayatHeader(),
                        SizedBox(height: 10.h),
                        _buildRiwayatList(),
                        SizedBox(height: 20.h),
                      ],
                    ),
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
  // Total Poin Card
  // ─────────────────────────────────────────────
  Widget _buildTotalPoinCard() {
    return _card(
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(color: const Color(0xffFFF7E1), borderRadius: BorderRadius.circular(14.r)),
            child: Icon(Icons.star_outline_rounded, color: SecondaryColor.warning600, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${controller.totalPoin.value}',
                style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
              ),
              Text('Total Poin Kehadiran', style: TextStyle(fontSize: 13.sp, color: SecondaryColor.neutral500)),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Aturan Poin Card
  // ─────────────────────────────────────────────
  Widget _buildAturanPoinCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14.sp, color: SecondaryColor.neutral400),
              SizedBox(width: 6.w),
              Text(
                'ATURAN POIN',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: SecondaryColor.neutral400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _aturanRow(
            icon: Icons.check_circle_outline_rounded,
            iconColor: SecondaryColor.success700,
            label: 'Sampai 08:00',
            poinText: '+1 Poin',
            poinColor: SecondaryColor.success700,
          ),
          Divider(height: 18.h, thickness: 1, color: SecondaryColor.neutral200),
          _aturanRow(
            icon: Icons.access_time_rounded,
            iconColor: SecondaryColor.warning600,
            label: '08:01 – 08:30',
            poinText: '+0.5 Poin',
            poinColor: SecondaryColor.warning600,
          ),
          Divider(height: 18.h, thickness: 1, color: SecondaryColor.neutral200),
          _aturanRow(
            icon: Icons.cancel_outlined,
            iconColor: SecondaryColor.neutral400,
            label: 'Setelah 08:30 (Terlambat)',
            poinText: '0 Poin',
            poinColor: SecondaryColor.neutral500,
          ),
        ],
      ),
    );
  }

  Widget _aturanRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String poinText,
    required Color poinColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: iconColor),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: SecondaryColor.neutral700, fontWeight: FontWeight.w500),
          ),
        ),
        Text(poinText, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: poinColor)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Month Selector
  // ─────────────────────────────────────────────
  Widget _buildMonthSelector() {
    return _card(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _arrowBtn(Icons.chevron_left_rounded, controller.prevMonth),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 17.sp, color: SecondaryColor.neutral500),
              SizedBox(width: 7.w),
              Text(
                controller.monthDisplay,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: SecondaryColor.neutral700),
              ),
            ],
          ),
          _arrowBtn(Icons.chevron_right_rounded, controller.nextMonth),
        ],
      ),
    );
  }

  Widget _arrowBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(color: SecondaryColor.neutral100, borderRadius: BorderRadius.circular(8.r)),
        child: Icon(icon, size: 20.sp, color: SecondaryColor.neutral600),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Monthly Summary Card
  // ─────────────────────────────────────────────
  Widget _buildMonthSummaryCard() {
    return _card(
      child: Row(
        children: [
          Expanded(
            child: _summaryCol(
              Icons.star_outline_rounded,
              SecondaryColor.success700,
              const Color(0xffE5F5EC),
              '+${controller.poinBulanIni}',
              'Bulan Ini',
            ),
          ),
          Container(width: 1, height: 50.h, color: SecondaryColor.neutral200),
          Expanded(
            child: _summaryCol(
              Icons.calendar_today_outlined,
              MainColor.blue2,
              MainColor.blueLight1,
              '${controller.hariHadir}',
              'Hari Hadir',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCol(IconData icon, Color iconColor, Color iconBg, String value, String label) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12.r)),
          child: Icon(icon, size: 22.sp, color: iconColor),
        ),
        SizedBox(height: 8.h),
        Text(value, style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700)),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Riwayat header
  // ─────────────────────────────────────────────
  Widget _buildRiwayatHeader() {
    return Text(
      'RIWAYAT POIN',
      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral400, letterSpacing: 0.6),
    );
  }

  // ─────────────────────────────────────────────
  // Riwayat list
  // ─────────────────────────────────────────────
  Widget _buildRiwayatList() {
    if (controller.isLoading.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: CircularProgressIndicator(color: MainColor.blue2),
        ),
      );
    }

    final list = controller.records;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48.sp, color: SecondaryColor.neutral300),
              SizedBox(height: 12.h),
              Text(
                'Belum ada riwayat poin\npada bulan ini',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: SecondaryColor.neutral400),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: list.map((r) => _buildPoinCard(r)).toList());
  }

  Widget _buildPoinCard(PointRecordModel r) {
    initializeDateFormatting('id_ID', null);

    final status = controller.getStatus(r.type);
    final label = controller.getLabel(r.type);
    final poin = r.points ?? 0;

    final Color borderColor;
    final Color iconColor;
    final IconData icon;
    final Color poinColor;
    final String poinStr;

    switch (status) {
      case PoinStatus.tepatWaktu:
        borderColor = SecondaryColor.success700;
        iconColor = SecondaryColor.success700;
        icon = Icons.check_circle_outline_rounded;
        poinColor = SecondaryColor.success700;
        poinStr = '+$poin';
        break;
      case PoinStatus.setengahPoin:
        borderColor = SecondaryColor.warning600;
        iconColor = SecondaryColor.warning600;
        icon = Icons.access_time_rounded;
        poinColor = SecondaryColor.warning600;
        poinStr = '+$poin';
        break;
      case PoinStatus.terlambat:
        borderColor = SecondaryColor.neutral300;
        iconColor = SecondaryColor.neutral400;
        icon = Icons.access_time_rounded;
        poinColor = SecondaryColor.neutral600;
        poinStr = '0';
        break;
      case PoinStatus.alpha:
        borderColor = SecondaryColor.danger600;
        iconColor = SecondaryColor.danger600;
        icon = Icons.cancel_outlined;
        poinColor = SecondaryColor.neutral600;
        poinStr = '0';
        break;
    }

    final dateStr = r.date != null ? DateFormat('d MMM yyyy', 'id_ID').format(r.date!.toLocal()) : '-';
    final timeStr = r.checkInTime != null ? ' • ${controller.getCheckInTimeDisplay(r)}' : '';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: SecondaryColor.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 22.sp, color: iconColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral700),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 12.sp, color: SecondaryColor.neutral400),
                      SizedBox(width: 4.w),
                      Text('$dateStr$timeStr', style: TextStyle(fontSize: 11.sp, color: SecondaryColor.neutral500)),
                    ],
                  ),
                ],
              ),
            ),
            Text(poinStr, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: poinColor)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: SecondaryColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: child,
    );
  }
}
