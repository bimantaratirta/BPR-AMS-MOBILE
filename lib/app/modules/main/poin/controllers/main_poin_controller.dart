import 'package:bpr_ams/app/data/modules/point_record/models/point_record_model.dart';
import 'package:bpr_ams/app/data/modules/point_record/point_record_service.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// ── Status type ──────────────────────────────────────────
enum PoinStatus { tepatWaktu, setengahPoin, terlambat, alpha }

// ── Controller ───────────────────────────────────────────
class MainPoinController extends GetxController {
  final authController = Get.find<AuthController>();
  final _pointRecordService = PointRecordService();

  // ── Scroll controller untuk pull-to-refresh scroll-to-top ──
  final ScrollController scrollController = ScrollController();

  // ── Total poin (semua waktu) ──────────────────────────────
  final RxDouble totalPoin = 0.0.obs;

  // ── Loading state ──────────────────────────────────────
  final RxBool isLoading = true.obs;

  // ── Month navigation ────────────────────────────────────
  final Rx<DateTime> selectedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  // ── Records from API ────────────────────────────────────
  final RxList<PointRecordModel> records = <PointRecordModel>[].obs;

  // ── Monthly summary ──────────────────────────────────────
  double get poinBulanIni => records.fold(0.0, (sum, r) => sum + (r.points ?? 0));
  int get hariHadir => records.where((r) => r.type != 'ALPHA').length;

  // ── Month display ─────────────────────────────────────────
  String get monthDisplay {
    initializeDateFormatting('id_ID', null);
    return DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth.value);
  }

  // ── Get PoinStatus from type string ────────────────────
  PoinStatus getStatus(String? type) {
    switch (type) {
      case 'HADIR':
        return PoinStatus.tepatWaktu;
      case 'SETENGAH_POIN':
        return PoinStatus.setengahPoin;
      case 'TERLAMBAT':
        return PoinStatus.terlambat;
      case 'ALPHA':
        return PoinStatus.alpha;
      default:
        return PoinStatus.terlambat;
    }
  }

  // ── Get label from type ────────────────────────────────
  String getLabel(String? type) {
    switch (type) {
      case 'HADIR':
        return 'Absensi Tepat Waktu';
      case 'SETENGAH_POIN':
        return 'Absensi 08:01-08:30';
      case 'TERLAMBAT':
        return 'Absensi Terlambat';
      case 'ALPHA':
        return 'Alpha';
      default:
        return 'Absensi';
    }
  }

  // ── Get check-in time display ──────────────────────────
  String getCheckInTimeDisplay(PointRecordModel record) {
    if (record.checkInTime == null) return '-';
    return DateFormat('HH:mm').format(record.checkInTime!.toLocal());
  }

  // ── Navigation ────────────────────────────────────────
  void prevMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month - 1);
    _fetchRecords();
  }

  void nextMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month + 1);
    _fetchRecords();
  }

  // ── Pull-to-refresh ───────────────────────────────────
  Future<void> onRefresh() async {
    _scrollToTop();
    await Future.wait([
      _fetchRecords(),
      _fetchTotalPoints(),
    ]);
  }

  // ── Fetch records from API (semua data 1 bulan) ──────
  Future<void> _fetchRecords() async {
    final employee = authController.employee.value;
    if (authController.pickUserType.value != UserType.employee || employee == null) {
      isLoading.value = false;
      return;
    }

    isLoading.value = true;

    final month = selectedMonth.value;
    try {
      final response = await _pointRecordService.getPointRecords(
        queryParameters: {
          'get_all': true,
          'filter': {
            'employeeId': employee.id,
            'month': '${month.year.toString()}-${month.month.toString().padLeft(2, '0')}',
          },
          'order_by': [
            {'field': 'createdAt', 'direction': 'desc'},
          ],
        },
      );

      if (response.data != null) {
        records.value = response.data!;
      } else {
        records.clear();
      }
    } catch (_) {
      records.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch total poin dari semua record (tanpa filter bulan) untuk kartu total
  Future<void> _fetchTotalPoints() async {
    final employee = authController.employee.value;
    if (authController.pickUserType.value != UserType.employee || employee == null) {
      return;
    }

    final response = await _pointRecordService.getPointRecords(
      queryParameters: {
        'get_all': true,
        'filter': {'employeeId': employee.id},
      },
    );

    if (response.data != null) {
      totalPoin.value = response.data!.fold(0.0, (sum, r) => sum + (r.points ?? 0));
    }
  }

  // ── Scroll to top helper ──────────────────────────────
  void _scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('id_ID', null);
    _fetchRecords();
    _fetchTotalPoints();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
