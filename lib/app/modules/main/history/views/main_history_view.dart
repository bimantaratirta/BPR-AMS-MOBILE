import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/data/modules/attendance/models/attendance_model.dart';
import 'package:bpr_ams/app/data/modules/leave_request/models/leave_request_model.dart';
import 'package:bpr_ams/app/modules/main/history/controllers/main_history_controller.dart';
import 'package:bpr_ams/app/widgets/build_navigation/build_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class MainHistoryView extends GetView<MainHistoryController> {
  const MainHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF2FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            Expanded(
              child: Obx(
                () => NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // Trigger load-more when within 200px of the bottom
                    if (notification is ScrollUpdateNotification) {
                      final metrics = notification.metrics;
                      if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                        controller.loadMore();
                      }
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    color: MainColor.blue2,
                    onRefresh: controller.onRefresh,
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      // Always scrollable so pull-to-refresh works even when content is short
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          _buildMonthSelector(),
                          SizedBox(height: 12.h),
                          _buildTabSwitcher(),
                          SizedBox(height: 16.h),
                          _buildSummaryCard(),
                          SizedBox(height: 20.h),
                          controller.selectedTab.value == 0 ? _buildAbsensiList() : _buildIzinList(),
                          // Bottom loader for infinite scroll
                          _buildBottomLoader(),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BuildBottomNavigationBar(),
    );
  }

  // ─────────────────────────────────────────────
  // Top bar
  // ─────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Text(
        'Riwayat',
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Month Selector
  // ─────────────────────────────────────────────
  Widget _buildMonthSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: SecondaryColor.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _arrowBtn(Icons.chevron_left_rounded, controller.prevMonth),
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 18.sp, color: SecondaryColor.neutral500),
              SizedBox(width: 8.w),
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
  // Tab Switcher
  // ─────────────────────────────────────────────
  Widget _buildTabSwitcher() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: SecondaryColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [_tabItem('Absensi', 0), _tabItem('Izin', 1)]),
    );
  }

  Widget _tabItem(String label, int index) {
    final isActive = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isActive ? MainColor.blue2 : Colors.transparent,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? SecondaryColor.white : SecondaryColor.neutral500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Summary Cards
  // ─────────────────────────────────────────────
  Widget _buildSummaryCard() {
    final isAbsensi = controller.selectedTab.value == 0;

    final List<_SummaryItem> items =
        isAbsensi
            ? [
              _SummaryItem('Hadir', controller.absensiHadir, SecondaryColor.success700),
              _SummaryItem('Terlambat', controller.absensiTerlambat, SecondaryColor.warning600),
              _SummaryItem('Alpha', controller.absensiAlpha, SecondaryColor.danger600),
            ]
            : [
              _SummaryItem('Disetujui', controller.izinDisetujui, SecondaryColor.success700),
              _SummaryItem('Menunggu', controller.izinMenunggu, SecondaryColor.warning600),
              _SummaryItem('Ditolak', controller.izinDitolak, SecondaryColor.danger600),
            ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: SecondaryColor.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAbsensi ? 'RINGKASAN ABSENSI' : 'RINGKASAN IZIN',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: SecondaryColor.neutral400,
              letterSpacing: 0.6,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) => _buildSummaryColumn(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(_SummaryItem item) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8.w, height: 8.w, decoration: BoxDecoration(color: item.color, shape: BoxShape.circle)),
            SizedBox(width: 5.w),
            Text(item.label, style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral600)),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          '${item.count}',
          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Absensi List (using AttendanceModel from API)
  // ─────────────────────────────────────────────
  Widget _buildAbsensiList() {
    if (controller.isLoadingAbsensi.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: CircularProgressIndicator(color: MainColor.blue2),
        ),
      );
    }

    final list = controller.absensiList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.format_list_bulleted_rounded, 'RIWAYAT ABSENSI'),
        SizedBox(height: 12.h),
        if (list.isEmpty)
          _emptyState('Tidak ada data absensi\npada bulan ini')
        else
          ...list.map((r) => _buildAbsensiCard(r)),
      ],
    );
  }

  Widget _buildAbsensiCard(AttendanceModel r) {
    initializeDateFormatting('id_ID', null);
    final dateStr = r.date != null ? DateFormat('EEEE, d MMM yyyy', 'id_ID').format(r.date!) : '-';

    final Color borderColor;
    final Color statusColor;
    final String statusText = MainHistoryController.attendanceStatusLabel(r.status);

    switch (r.status) {
      case 'HADIR':
        borderColor = SecondaryColor.success700;
        statusColor = SecondaryColor.success700;
        break;
      case 'TERLAMBAT':
        borderColor = SecondaryColor.warning600;
        statusColor = SecondaryColor.warning600;
        break;
      case 'ALPHA':
        borderColor = SecondaryColor.danger600;
        statusColor = SecondaryColor.danger600;
        break;
      case 'IZIN_CUTI':
      case 'IZIN_SAKIT':
      case 'IZIN_SETENGAH_HARI':
        borderColor = MainColor.blue2;
        statusColor = MainColor.blue2;
        break;
      default:
        borderColor = SecondaryColor.neutral400;
        statusColor = SecondaryColor.neutral400;
    }

    final checkInStr = MainHistoryController.formatTime(r.checkInTime);
    final checkOutStr = MainHistoryController.formatTime(r.checkOutTime);
    final durationStr = MainHistoryController.formatDuration(r.durationMinutes);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    dateStr,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral700),
                  ),
                ),
                Text(statusText, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: statusColor)),
              ],
            ),
            SizedBox(height: 6.h),
            _iconRow(Icons.access_time_rounded, '$checkInStr — $checkOutStr'),
            SizedBox(height: 3.h),
            _iconRow(Icons.timer_outlined, 'Durasi: $durationStr'),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Izin List (using LeaveRequestModel from API)
  // ─────────────────────────────────────────────
  Widget _buildIzinList() {
    if (controller.isLoadingIzin.value) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: CircularProgressIndicator(color: MainColor.blue2),
        ),
      );
    }

    final list = controller.izinList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.description_outlined, 'RIWAYAT IZIN'),
        SizedBox(height: 12.h),
        if (list.isEmpty) _emptyState('Tidak ada data izin\npada bulan ini') else ...list.map((r) => _buildIzinCard(r)),
      ],
    );
  }

  Widget _buildIzinCard(LeaveRequestModel r) {
    initializeDateFormatting('id_ID', null);
    final Color borderColor;
    final Color statusColor;
    final String statusText = MainHistoryController.leaveStatusLabel(r.status);

    switch (r.status) {
      case 'APPROVED':
        borderColor = SecondaryColor.success700;
        statusColor = SecondaryColor.success700;
        break;
      case 'PENDING':
        borderColor = SecondaryColor.warning600;
        statusColor = SecondaryColor.warning600;
        break;
      case 'REJECTED':
        borderColor = SecondaryColor.danger600;
        statusColor = SecondaryColor.danger600;
        break;
      default:
        borderColor = SecondaryColor.neutral400;
        statusColor = SecondaryColor.neutral400;
    }

    final startStr = r.startDate != null ? DateFormat('d MMM yyyy', 'id_ID').format(r.startDate!) : '-';
    final endStr = r.endDate != null ? DateFormat('d MMM yyyy', 'id_ID').format(r.endDate!) : '-';
    final dateRange = startStr == endStr ? startStr : '$startStr — $endStr';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  MainHistoryController.leaveTypeLabel(r.type),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: SecondaryColor.neutral700),
                ),
                Text(statusText, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: statusColor)),
              ],
            ),
            SizedBox(height: 5.h),
            _iconRow(Icons.access_time_rounded, dateRange),
            SizedBox(height: 4.h),
            Text(r.reason ?? '-', style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500)),
            if (r.rejectReason != null && r.rejectReason!.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(color: const Color(0xffFFEBEE), borderRadius: BorderRadius.circular(8.r)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALASAN PENOLAKAN',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: SecondaryColor.danger600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(r.rejectReason!, style: TextStyle(fontSize: 12.sp, color: SecondaryColor.danger600)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Bottom loader indicator for infinite scroll
  // ─────────────────────────────────────────────
  Widget _buildBottomLoader() {
    final isLoadingMore =
        controller.selectedTab.value == 0 ? controller.isLoadingMoreAbsensi.value : controller.isLoadingMoreIzin.value;

    final hasMore = controller.selectedTab.value == 0 ? controller.hasMoreAbsensi.value : controller.hasMoreIzin.value;

    final isInitialLoading =
        controller.selectedTab.value == 0 ? controller.isLoadingAbsensi.value : controller.isLoadingIzin.value;

    if (isInitialLoading) return const SizedBox.shrink();

    if (isLoadingMore) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: MainColor.blue2),
          ),
        ),
      );
    }

    if (!hasMore &&
        (controller.selectedTab.value == 0 ? controller.attendances.isNotEmpty : controller.leaveRequests.isNotEmpty)) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text('— Semua data telah dimuat —', style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral400)),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 17.sp, color: MainColor.blue2),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: MainColor.blue2, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _iconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13.sp, color: SecondaryColor.neutral400),
        SizedBox(width: 5.w),
        Text(text, style: TextStyle(fontSize: 12.sp, color: SecondaryColor.neutral500)),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48.sp, color: SecondaryColor.neutral300),
            SizedBox(height: 12.h),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: SecondaryColor.neutral400)),
          ],
        ),
      ),
    );
  }
}

// ── Internal model ─────────────────────────────
class _SummaryItem {
  final String label;
  final int count;
  final Color color;
  const _SummaryItem(this.label, this.count, this.color);
}
