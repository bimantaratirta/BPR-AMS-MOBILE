import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// ── Status type ──────────────────────────────────────────
enum PoinStatus { tepatWaktu, setengahPoin, terlambat, alpha }

// ── Record model ─────────────────────────────────────────
class PoinRecord {
  final String label; // e.g. "Absensi Tepat Waktu"
  final DateTime date;
  final String? checkInTime; // e.g. "07:55", null for alpha
  final PoinStatus status;
  final double poin; // +1, +0.5, 0

  const PoinRecord({required this.label, required this.date, this.checkInTime, required this.status, required this.poin});
}

// ── Controller ───────────────────────────────────────────
class MainPoinController extends GetxController {
  final authController = Get.find<AuthController>();

  // ── Total poin ──────────────────────────────────────
  final RxDouble totalPoin = 15.5.obs;

  // ── Month navigation ────────────────────────────────
  final Rx<DateTime> selectedMonth = DateTime(2026, 2).obs;

  // ── Dummy data keyed by "yyyy-MM" ────────────────────
  final Map<String, List<PoinRecord>> _data = {
    '2026-02': [
      PoinRecord(
        label: 'Absensi Tepat Waktu',
        date: DateTime(2026, 2, 14),
        checkInTime: '07:55',
        status: PoinStatus.tepatWaktu,
        poin: 1.0,
      ),
      PoinRecord(
        label: 'Absensi 08:01–08:30',
        date: DateTime(2026, 2, 13),
        checkInTime: '08:15',
        status: PoinStatus.setengahPoin,
        poin: 0.5,
      ),
      PoinRecord(
        label: 'Absensi Tepat Waktu',
        date: DateTime(2026, 2, 12),
        checkInTime: '07:50',
        status: PoinStatus.tepatWaktu,
        poin: 1.0,
      ),
      PoinRecord(
        label: 'Absensi 08:01–08:30',
        date: DateTime(2026, 2, 11),
        checkInTime: '08:10',
        status: PoinStatus.setengahPoin,
        poin: 0.5,
      ),
      PoinRecord(
        label: 'Absensi 08:01–08:30',
        date: DateTime(2026, 2, 10),
        checkInTime: '08:02',
        status: PoinStatus.setengahPoin,
        poin: 0.5,
      ),
      PoinRecord(
        label: 'Absensi Tepat Waktu',
        date: DateTime(2026, 2, 7),
        checkInTime: '08:00',
        status: PoinStatus.tepatWaktu,
        poin: 1.0,
      ),
      PoinRecord(label: 'Alpha', date: DateTime(2026, 2, 6), checkInTime: null, status: PoinStatus.alpha, poin: 0.0),
      PoinRecord(
        label: 'Absensi Terlambat',
        date: DateTime(2026, 2, 5),
        checkInTime: '08:45',
        status: PoinStatus.terlambat,
        poin: 0.0,
      ),
      PoinRecord(
        label: 'Absensi Tepat Waktu',
        date: DateTime(2026, 2, 4),
        checkInTime: '07:58',
        status: PoinStatus.tepatWaktu,
        poin: 1.0,
      ),
      PoinRecord(
        label: 'Absensi 08:01–08:30',
        date: DateTime(2026, 2, 3),
        checkInTime: '08:20',
        status: PoinStatus.setengahPoin,
        poin: 0.5,
      ),
    ],
    '2026-01': [
      PoinRecord(
        label: 'Absensi Tepat Waktu',
        date: DateTime(2026, 1, 30),
        checkInTime: '07:55',
        status: PoinStatus.tepatWaktu,
        poin: 1.0,
      ),
      PoinRecord(
        label: 'Absensi 08:01–08:30',
        date: DateTime(2026, 1, 29),
        checkInTime: '08:05',
        status: PoinStatus.setengahPoin,
        poin: 0.5,
      ),
    ],
  };

  // ── Current month key ────────────────────────────────
  String get _monthKey => DateFormat('yyyy-MM').format(selectedMonth.value);

  // ── Data for selected month ──────────────────────────
  List<PoinRecord> get records => _data[_monthKey] ?? [];

  // ── Monthly summary ──────────────────────────────────
  double get poinBulanIni => records.fold(0.0, (sum, r) => sum + r.poin);
  int get hariHadir => records.where((r) => r.status != PoinStatus.alpha).length;

  // ── Month display ─────────────────────────────────────
  String get monthDisplay {
    initializeDateFormatting('id_ID', null);
    return DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth.value);
  }

  // ── Navigation ────────────────────────────────────────
  void prevMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month - 1);
  }

  void nextMonth() {
    final m = selectedMonth.value;
    selectedMonth.value = DateTime(m.year, m.month + 1);
  }

  @override
  void onInit() {
    super.onInit();
    initializeDateFormatting('id_ID', null);
  }
}
