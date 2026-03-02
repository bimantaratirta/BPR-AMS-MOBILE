import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// ── Model: Absensi ────────────────────────────────────────────
class AbsensiRecord {
  final DateTime date;
  final String checkIn; // e.g. "07:55:12"
  final String checkOut; // e.g. "17:02:45"
  final String duration; // e.g. "8j 57m"
  final bool isOnTime; // true = Tepat Waktu, false = Terlambat

  const AbsensiRecord({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.duration,
    required this.isOnTime,
  });
}

// ── Model: Izin ──────────────────────────────────────────────
enum IzinStatus { disetujui, menunggu, ditolak }

class IzinRecord {
  final String type; // e.g. "Izin Cuti"
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final IzinStatus status;
  final String? rejectionNote; // isi hanya kalau ditolak

  const IzinRecord({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.rejectionNote,
  });
}

// ── Controller ───────────────────────────────────────────────
class MainHistoryController extends GetxController {
  // ---- Tab (0 = Absensi, 1 = Izin)
  final RxInt selectedTab = 0.obs;

  // ---- Month navigation
  final Rx<DateTime> selectedMonth = DateTime(2026, 2).obs;

  // ---- Dummy datasets keyed by "yyyy-MM"
  final Map<String, List<AbsensiRecord>> _absensiData = {
    '2026-02': [
      AbsensiRecord(
        date: DateTime(2026, 2, 14),
        checkIn: '07:55:12',
        checkOut: '17:02:45',
        duration: '8j 57m',
        isOnTime: true,
      ),
      AbsensiRecord(
        date: DateTime(2026, 2, 13),
        checkIn: '08:15:18',
        checkOut: '17:15:30',
        duration: '8j 43m',
        isOnTime: false,
      ),
      AbsensiRecord(
        date: DateTime(2026, 2, 12),
        checkIn: '07:50:44',
        checkOut: '17:00:12',
        duration: '9j 4m',
        isOnTime: true,
      ),
      AbsensiRecord(
        date: DateTime(2026, 2, 11),
        checkIn: '08:10:05',
        checkOut: '17:05:33',
        duration: '8j 55m',
        isOnTime: false,
      ),
      AbsensiRecord(
        date: DateTime(2026, 2, 10),
        checkIn: '08:02:19',
        checkOut: '17:01:08',
        duration: '8j 58m',
        isOnTime: false,
      ),
      AbsensiRecord(
        date: DateTime(2026, 2, 7),
        checkIn: '07:45:00',
        checkOut: '17:00:00',
        duration: '9j 15m',
        isOnTime: true,
      ),
      AbsensiRecord(
        date: DateTime(2026, 2, 6),
        checkIn: '07:58:33',
        checkOut: '17:10:20',
        duration: '9j 11m',
        isOnTime: true,
      ),
      AbsensiRecord(
        date: DateTime(2026, 2, 5),
        checkIn: '07:52:01',
        checkOut: '17:00:55',
        duration: '9j 8m',
        isOnTime: true,
      ),
      AbsensiRecord(
        date: DateTime(2026, 2, 4),
        checkIn: '08:20:00',
        checkOut: '17:00:00',
        duration: '8j 40m',
        isOnTime: false,
      ),
      AbsensiRecord(
        date: DateTime(2026, 2, 3),
        checkIn: '07:48:00',
        checkOut: '17:05:00',
        duration: '9j 17m',
        isOnTime: true,
      ),
    ],
    '2026-01': [
      AbsensiRecord(
        date: DateTime(2026, 1, 30),
        checkIn: '07:55:00',
        checkOut: '17:00:00',
        duration: '9j 5m',
        isOnTime: true,
      ),
      AbsensiRecord(
        date: DateTime(2026, 1, 29),
        checkIn: '08:05:00',
        checkOut: '17:00:00',
        duration: '8j 55m',
        isOnTime: false,
      ),
      AbsensiRecord(
        date: DateTime(2026, 1, 28),
        checkIn: '07:50:00',
        checkOut: '17:00:00',
        duration: '9j 10m',
        isOnTime: true,
      ),
    ],
  };

  final Map<String, List<IzinRecord>> _izinData = {
    '2026-02': [
      IzinRecord(
        type: 'Izin Cuti',
        startDate: DateTime(2026, 1, 10),
        endDate: DateTime(2026, 1, 12),
        reason: 'Acara keluarga',
        status: IzinStatus.disetujui,
      ),
      IzinRecord(
        type: 'Izin Sakit',
        startDate: DateTime(2026, 1, 25),
        endDate: DateTime(2026, 1, 26),
        reason: 'Demam dan flu',
        status: IzinStatus.disetujui,
      ),
      IzinRecord(
        type: 'Izin Setengah Hari',
        startDate: DateTime(2026, 2, 5),
        endDate: DateTime(2026, 2, 5),
        reason: 'Urusan pribadi',
        status: IzinStatus.menunggu,
      ),
      IzinRecord(
        type: 'Izin Cuti',
        startDate: DateTime(2026, 2, 20),
        endDate: DateTime(2026, 2, 22),
        reason: 'Liburan keluarga',
        status: IzinStatus.ditolak,
        rejectionNote: 'Jadwal bertabrakan dengan audit cabang',
      ),
    ],
    '2026-01': [
      IzinRecord(
        type: 'Izin Sakit',
        startDate: DateTime(2026, 1, 5),
        endDate: DateTime(2026, 1, 6),
        reason: 'Sakit kepala',
        status: IzinStatus.disetujui,
      ),
    ],
  };

  // ── Computed: current month key ──
  String get _monthKey => DateFormat('yyyy-MM').format(selectedMonth.value);

  // ── Absensi list for selected month ──
  List<AbsensiRecord> get absensiList => _absensiData[_monthKey] ?? [];

  // ── Absensi summary ──
  int get absensiHadir => absensiList.length;
  int get absensiTerlambat => absensiList.where((r) => !r.isOnTime).length;
  int get absensiAlpha => _alphaCount;
  int get _alphaCount {
    // Hitung hari kerja pada bulan tsb - jumlah record
    final m = selectedMonth.value;
    int workdays = 0;
    final daysInMonth = DateUtils.getDaysInMonth(m.year, m.month);
    for (int d = 1; d <= daysInMonth; d++) {
      final wd = DateTime(m.year, m.month, d).weekday;
      if (wd != DateTime.saturday && wd != DateTime.sunday) workdays++;
    }
    return (workdays - absensiList.length).clamp(0, 99);
  }

  // ── Izin list for selected month ──
  List<IzinRecord> get izinList => _izinData[_monthKey] ?? [];

  // ── Izin summary ──
  int get izinDisetujui => izinList.where((r) => r.status == IzinStatus.disetujui).length;
  int get izinMenunggu => izinList.where((r) => r.status == IzinStatus.menunggu).length;
  int get izinDitolak => izinList.where((r) => r.status == IzinStatus.ditolak).length;

  // ── Month display string ──
  String get monthDisplay {
    initializeDateFormatting('id_ID', null);
    return DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth.value);
  }

  // ── Navigation ──
  void prevMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month - 1);
  }

  void nextMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month + 1);
  }

  void selectTab(int index) => selectedTab.value = index;

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('id_ID', null);
  }
}
