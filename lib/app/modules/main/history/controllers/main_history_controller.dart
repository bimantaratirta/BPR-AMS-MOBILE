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

  // ── Computed: current month key ──
  String get _monthKey => DateFormat('yyyy-MM').format(selectedMonth.value);

  // ── Absensi list for selected month ──
  List<AttendanceModel> get absensiList {
    final m = selectedMonth.value;
    return attendances.where((r) {
        if (r.date == null) return false;
        return r.date!.year == m.year && r.date!.month == m.month;
      }).toList()
      ..sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
  }

  // ── Absensi summary ──
  int get absensiHadir => absensiList.where((r) => r.status == 'HADIR').length;
  int get absensiTerlambat => absensiList.where((r) => r.status == 'TERLAMBAT').length;
  int get absensiAlpha => absensiList.where((r) => r.status == 'ALPHA').length;

  // ── Izin list for selected month (filtered from API data) ──
  List<LeaveRequestModel> get izinList {
    final m = selectedMonth.value;
    return leaveRequests.where((r) {
      if (r.startDate == null) return false;
      return r.startDate!.year == m.year && r.startDate!.month == m.month;
    }).toList();
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
    _fetchCurrentTabData();
  }

  void nextMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month + 1);
    _fetchCurrentTabData();
  }

  void selectTab(int index) {
    selectedTab.value = index;
    _fetchCurrentTabData();
  }

  void _fetchCurrentTabData() {
    if (selectedTab.value == 0) {
      fetchAttendances();
    } else {
      fetchLeaveRequests();
    }
  }

  // ── Fetch attendance data from API ──
  Future<void> fetchAttendances() async {
    isLoadingAbsensi.value = true;

    final employeeId = _authController.employee.value?.id;
    if (employeeId == null) {
      isLoadingAbsensi.value = false;
      return;
    }

    try {
      final response = await _attendanceService.getAttendances(queryParameters: {'employeeId': employeeId});

      if ((response.code == 200 || response.code == 201) && response.data != null) {
        attendances.value = response.data!;
      }
    } catch (_) {
      // Silently handle error
    } finally {
      isLoadingAbsensi.value = false;
    }
  }

  // ── Fetch leave requests from API ──
  Future<void> fetchLeaveRequests() async {
    isLoadingIzin.value = true;

    final employeeId = _authController.employee.value?.id;
    if (employeeId == null) {
      isLoadingIzin.value = false;
      return;
    }

    try {
      final response = await _leaveRequestService.getLeaveRequests(queryParameters: {'employeeId': employeeId});

      if ((response.code == 200 || response.code == 201) && response.data != null) {
        leaveRequests.value = response.data!;
      }
    } catch (_) {
      // Silently handle error
    } finally {
      isLoadingIzin.value = false;
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
}
