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

  // ---- Scroll controller untuk pull-to-refresh scroll-to-top
  final ScrollController scrollController = ScrollController();

  // ---- Tab (0 = Absensi, 1 = Izin)
  final RxInt selectedTab = 0.obs;

  // ---- Month navigation
  final Rx<DateTime> selectedMonth = DateTime(2026, 3).obs;

  // ---- Loading states
  final RxBool isLoadingAbsensi = false.obs;
  final RxBool isLoadingIzin = false.obs;

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
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    _resetAndFetch();
  }

  // ── Clear & fetch active tab pakai filter terkini ──
  void _resetAndFetch() {
    if (selectedTab.value == 0) {
      attendances.clear();
      fetchAttendances();
    } else {
      leaveRequests.clear();
      fetchLeaveRequests();
    }
  }

  // ── Pull-to-refresh — refresh kedua tab ──
  Future<void> onRefresh() async {
    _scrollToTop();
    attendances.clear();
    leaveRequests.clear();
    await Future.wait([
      fetchAttendances(),
      fetchLeaveRequests(),
    ]);
  }

  // ── Fetch attendance data from API (semua data 1 bulan) ──
  Future<void> fetchAttendances() async {
    isLoadingAbsensi.value = true;

    final employeeId = _authController.employee.value?.id;
    if (employeeId == null) {
      isLoadingAbsensi.value = false;
      return;
    }

    try {
      final response = await _attendanceService.getAttendances(
        queryParameters: {
          'get_all': true,
          'filter': {
            'month': "${selectedMonth.value.year.toString()}-${selectedMonth.value.month.toString().padLeft(2, '0')}",
            'employeeId': employeeId,
          },
          'order_by': [
            {'field': 'createdAt', 'direction': 'desc'},
          ],
        },
      );

      if ((response.code == 200 || response.code == 201) && response.data != null) {
        attendances.value = response.data!;
      }
    } catch (_) {
      // ignore
    } finally {
      isLoadingAbsensi.value = false;
    }
  }

  // ── Fetch leave requests from API (semua data 1 bulan) ──
  Future<void> fetchLeaveRequests() async {
    isLoadingIzin.value = true;

    final employeeId = _authController.employee.value?.id;
    if (employeeId == null) {
      isLoadingIzin.value = false;
      return;
    }

    try {
      final response = await _leaveRequestService.getLeaveRequests(
        queryParameters: {
          'get_all': true,
          'filter': {
            'month': "${selectedMonth.value.year.toString()}-${selectedMonth.value.month.toString().padLeft(2, '0')}",
            'employeeId': employeeId,
          },
          'order_by': [
            {'field': 'createdAt', 'direction': 'desc'},
          ],
        },
      );

      if ((response.code == 200 || response.code == 201) && response.data != null) {
        leaveRequests.value = response.data!;
      }
    } catch (_) {
      // ignore
    } finally {
      isLoadingIzin.value = false;
    }
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
    final now = DateTime.now();
    selectedMonth.value = DateTime(now.year, now.month);
    fetchAttendances();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
