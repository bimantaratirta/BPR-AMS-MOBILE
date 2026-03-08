import 'package:bpr_ams/app/data/modules/attendance/attendance_service.dart';
import 'package:bpr_ams/app/data/modules/attendance/models/attendance_model.dart';
import 'package:bpr_ams/app/data/modules/leave_request/leave_request_service.dart';
import 'package:bpr_ams/app/data/modules/leave_request/models/leave_request_model.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// ── Controller ───────────────────────────────────────────────
class MainHistoryController extends GetxController {
  final AttendanceService _attendanceService = AttendanceService();
  final LeaveRequestService _leaveRequestService = LeaveRequestService();
  final AuthController _authController = Get.find<AuthController>();

  // ---- Scroll controller untuk infinite scroll + pull-to-refresh
  final ScrollController scrollController = ScrollController();

  // ---- Tab (0 = Absensi, 1 = Izin)
  final RxInt selectedTab = 0.obs;

  // ---- Month navigation
  final Rx<DateTime> selectedMonth = DateTime(2026, 3).obs;

  // ---- Loading states
  final RxBool isLoadingAbsensi = false.obs;
  final RxBool isLoadingIzin = false.obs;
  final RxBool isLoadingMoreAbsensi = false.obs;
  final RxBool isLoadingMoreIzin = false.obs;

  // ---- Pagination state – Absensi
  int _absensiPage = 1;
  static const int _pageLimit = 10;
  final RxBool hasMoreAbsensi = true.obs;

  // ---- Pagination state – Izin
  int _izinPage = 1;
  final RxBool hasMoreIzin = true.obs;

  // ---- Data from API
  final RxList<AttendanceModel> attendances = <AttendanceModel>[].obs;
  final RxList<LeaveRequestModel> leaveRequests = <LeaveRequestModel>[].obs;

  // ── Absensi list for selected month ──
  List<AttendanceModel> get absensiList {
    return List<AttendanceModel>.from(attendances);
  }

  // ── Absensi summary ──
  int get absensiHadir => absensiList.where((r) => r.status == 'HADIR').length;
  int get absensiTerlambat => absensiList.where((r) => r.status == 'TERLAMBAT').length;
  int get absensiAlpha => absensiList.where((r) => r.status == 'ALPHA').length;

  // ── Izin list  ──
  List<LeaveRequestModel> get izinList {
    return List<LeaveRequestModel>.from(leaveRequests);
  }

  // ── Izin summary ──
  int get izinDisetujui => izinList.where((r) => r.status == 'APPROVED').length;
  int get izinMenunggu => izinList.where((r) => r.status == 'PENDING').length;
  int get izinDitolak => izinList.where((r) => r.status == 'REJECTED').length;

  // ── Month display string ──
  String get monthDisplay {
    initializeDateFormatting('id_ID', null);
    return DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth.value);
  }

  // ── Navigation ──
  void prevMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month - 1);
    _resetAndFetch();
  }

  void nextMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month + 1);
    _resetAndFetch();
  }

  void selectTab(int index) {
    selectedTab.value = index;
    _resetAndFetch();
  }

  // ── Reset pagination & fetch page 1 ──
  void _resetAndFetch() {
    if (selectedTab.value == 0) {
      _absensiPage = 1;
      hasMoreAbsensi.value = true;
      attendances.clear();
      fetchAttendances();
    } else {
      _izinPage = 1;
      hasMoreIzin.value = true;
      leaveRequests.clear();
      fetchLeaveRequests();
    }
  }

  // ── Pull-to-refresh ──
  Future<void> onRefresh() async {
    _scrollToTop();
    _resetAndFetch();
    // Wait until loading finishes
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (selectedTab.value == 0) return isLoadingAbsensi.value;
      return isLoadingIzin.value;
    });
  }

  // ── Load more (infinite scroll) ──
  void loadMore() {
    if (selectedTab.value == 0) {
      if (!isLoadingAbsensi.value && !isLoadingMoreAbsensi.value && hasMoreAbsensi.value) {
        _absensiPage++;
        fetchAttendances(isLoadMore: true);
      }
    } else {
      if (!isLoadingIzin.value && !isLoadingMoreIzin.value && hasMoreIzin.value) {
        _izinPage++;
        fetchLeaveRequests(isLoadMore: true);
      }
    }
  }

  // ── Fetch attendance data from API ──
  Future<void> fetchAttendances({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isLoadingMoreAbsensi.value = true;
    } else {
      isLoadingAbsensi.value = true;
    }

    final employeeId = _authController.employee.value?.id;
    if (employeeId == null) {
      isLoadingAbsensi.value = false;
      isLoadingMoreAbsensi.value = false;
      return;
    }

    try {
      final response = await _attendanceService.getAttendances(
        queryParameters: {
          'pagination': {'page': _absensiPage, 'limit': _pageLimit},
          'filter': {
            'month': "${selectedMonth.value.year.toString()}-${selectedMonth.value.month.toString().padLeft(2, '0')}",
            'employeeId': employeeId,
          },
          'order_by': [
            {'field': 'created_at', 'direction': 'desc'},
          ],
        },
      );

      if ((response.code == 200 || response.code == 201) && response.data != null) {
        final newItems = response.data!;
        if (isLoadMore) {
          attendances.addAll(newItems);
        } else {
          attendances.value = newItems;
        }

        // Determine if there are more pages
        final total = _extractTotal(response.pagination);
        hasMoreAbsensi.value = attendances.length < total;
      } else {
        hasMoreAbsensi.value = false;
      }
    } catch (_) {
      hasMoreAbsensi.value = false;
    } finally {
      isLoadingAbsensi.value = false;
      isLoadingMoreAbsensi.value = false;
    }
  }

  // ── Fetch leave requests from API ──
  Future<void> fetchLeaveRequests({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isLoadingMoreIzin.value = true;
    } else {
      isLoadingIzin.value = true;
    }

    final employeeId = _authController.employee.value?.id;
    if (employeeId == null) {
      isLoadingIzin.value = false;
      isLoadingMoreIzin.value = false;
      return;
    }

    try {
      final response = await _leaveRequestService.getLeaveRequests(
        queryParameters: {
          'pagination': {'page': _izinPage, 'limit': _pageLimit},
          'filter': {
            'month': "${selectedMonth.value.year.toString()}-${selectedMonth.value.month.toString().padLeft(2, '0')}",
            'employeeId': employeeId,
          },
          'order_by': [
            {'field': 'created_at', 'direction': 'desc'},
          ],
        },
      );

      if ((response.code == 200 || response.code == 201) && response.data != null) {
        final newItems = response.data!;
        if (isLoadMore) {
          leaveRequests.addAll(newItems);
        } else {
          leaveRequests.value = newItems;
        }

        final total = _extractTotal(response.pagination);
        hasMoreIzin.value = leaveRequests.length < total;
      } else {
        hasMoreIzin.value = false;
      }
    } catch (_) {
      hasMoreIzin.value = false;
    } finally {
      isLoadingIzin.value = false;
      isLoadingMoreIzin.value = false;
    }
  }

  // ── Extract total count from pagination metadata ──
  int _extractTotal(dynamic pagination) {
    if (pagination == null) return 0;
    if (pagination is Map) {
      return (pagination['total'] as int?) ?? (pagination['totalItems'] as int?) ?? (pagination['count'] as int?) ?? 0;
    }
    return 0;
  }

  // ── Scroll to top helper ──
  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // ── Helper: Map attendance status to display label ──
  static String attendanceStatusLabel(String? status) {
    switch (status) {
      case 'HADIR':
        return 'Tepat Waktu';
      case 'TERLAMBAT':
        return 'Terlambat';
      case 'IZIN_CUTI':
        return 'Izin Cuti';
      case 'IZIN_SAKIT':
        return 'Izin Sakit';
      case 'IZIN_SETENGAH_HARI':
        return 'Izin Setengah Hari';
      case 'ALPHA':
        return 'Alpha';
      default:
        return status ?? '-';
    }
  }

  // ── Helper: Map leave type to display label ──
  static String leaveTypeLabel(String? type) {
    switch (type) {
      case 'IZIN_CUTI':
        return 'Izin Cuti';
      case 'IZIN_SAKIT':
        return 'Izin Sakit';
      case 'IZIN_SETENGAH_HARI':
        return 'Izin Setengah Hari';
      default:
        return type ?? '-';
    }
  }

  // ── Helper: Map leave status to display label ──
  static String leaveStatusLabel(String? status) {
    switch (status) {
      case 'APPROVED':
        return 'Disetujui';
      case 'PENDING':
        return 'Menunggu';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status ?? '-';
    }
  }

  // ── Helper: Format duration from minutes ──
  static String formatDuration(int? minutes) {
    if (minutes == null) return '-';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}j ${mins}m';
  }

  // ── Helper: Format time from DateTime ──
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--:--';
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('id_ID', null);
    // Set bulan ke bulan ini
    final now = DateTime.now();
    selectedMonth.value = DateTime(now.year, now.month);

    // Fetch initial data
    fetchAttendances();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
