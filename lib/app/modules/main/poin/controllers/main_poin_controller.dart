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

  // ── Scroll controller untuk infinite scroll & pull-to-refresh ──
  final ScrollController scrollController = ScrollController();

  // ── Total poin (semua waktu) ──────────────────────────────
  final RxDouble totalPoin = 0.0.obs;

  // ── Loading states ──────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;

  // ── Month navigation ────────────────────────────────────
  final Rx<DateTime> selectedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  // ── Records from API ────────────────────────────────────
  final RxList<PointRecordModel> records = <PointRecordModel>[].obs;

  // ── Pagination state ─────────────────────────────────────
  int _currentPage = 1;
  static const int _pageLimit = 10;
  final RxBool hasMore = true.obs;

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
    _resetAndFetch();
  }

  void nextMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month + 1);
    _resetAndFetch();
  }

  // ── Reset pagination & fetch page 1 ──────────────────
  void _resetAndFetch() {
    _currentPage = 1;
    hasMore.value = true;
    records.clear();
    _fetchRecords();
  }

  // ── Pull-to-refresh ───────────────────────────────────
  Future<void> onRefresh() async {
    _scrollToTop();
    _resetAndFetch();
    // Wait until main loading finishes
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      return isLoading.value;
    });
  }

  // ── Load more (infinite scroll) ───────────────────────
  void loadMore() {
    if (!isLoading.value && !isLoadingMore.value && hasMore.value) {
      _currentPage++;
      _fetchRecords(isLoadMore: true);
    }
  }

  // ── Fetch records from API ────────────────────────────
  Future<void> _fetchRecords({bool isLoadMore = false}) async {
    final employee = authController.employee.value;
    if (authController.pickUserType.value != UserType.employee || employee == null) {
      isLoading.value = false;
      return;
    }

    if (isLoadMore) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }

    final month = selectedMonth.value;
    try {
      final response = await _pointRecordService.getPointRecords(
        queryParameters: {
          'pagination': {'page': _currentPage, 'limit': _pageLimit},
          'filter': {
            'employeeId': employee.id,
            'month': '${month.year.toString()}-${month.month.toString().padLeft(2, '0')}',
          },
          'order_by': [
            {'field': 'created_at', 'direction': 'desc'},
          ],
        },
      );

      if (response.data != null) {
        // Filter client-side juga sebagai safeguard jika server tidak memfilter bulan
        final selectedYear = month.year;
        final selectedMonthNum = month.month;
        final newItems =
            response.data!.where((r) {
              if (r.date == null) return false;
              final localDate = r.date!.toLocal();
              return localDate.year == selectedYear && localDate.month == selectedMonthNum;
            }).toList();

        if (isLoadMore) {
          records.addAll(newItems);
        } else {
          records.value = newItems;
        }

        // Determine if there are more pages
        final total = _extractTotal(response.pagination);
        hasMore.value = records.length < total;
      } else {
        hasMore.value = false;
        if (!isLoadMore) records.clear();
      }
    } catch (_) {
      hasMore.value = false;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
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
        'filter': {'employeeId': employee.id},
      },
    );

    if (response.data != null) {
      totalPoin.value = response.data!.fold(0.0, (sum, r) => sum + (r.points ?? 0));
    }
  }

  // ── Extract total count from pagination metadata ──────
  int _extractTotal(dynamic pagination) {
    if (pagination == null) return 0;
    if (pagination is Map) {
      return (pagination['total'] as int?) ?? (pagination['totalItems'] as int?) ?? (pagination['count'] as int?) ?? 0;
    }
    return 0;
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
