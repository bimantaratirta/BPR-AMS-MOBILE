import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bpr_ams/app/widgets/build_custom_snackbar.dart';

class MainPermitController extends GetxController {
  // ─── Jenis Izin options ───────────────────────────────────
  final List<String> jenisIzinOptions = [
    'Izin Cuti',
    'Izin Sakit',
    'Izin Setengah Hari',
    'Izin Keperluan Keluarga',
    'Izin Dinas Luar',
  ];

  final RxnString selectedJenisIzin = RxnString(null);

  // ─── Tanggal ──────────────────────────────────────────────
  final Rx<DateTime?> tanggalMulai = Rx<DateTime?>(null);
  final Rx<DateTime?> tanggalSelesai = Rx<DateTime?>(null);

  // ─── Alasan ───────────────────────────────────────────────
  final TextEditingController alasanController = TextEditingController();

  // ─── Lampiran (filename placeholder) ─────────────────────
  final RxnString attachedFileName = RxnString(null);

  // ─── Loading ──────────────────────────────────────────────
  final RxBool isLoading = false.obs;

  // ─── Validation helpers ───────────────────────────────────
  bool get isFormValid =>
      selectedJenisIzin.value != null &&
      tanggalMulai.value != null &&
      tanggalSelesai.value != null &&
      alasanController.text.trim().isNotEmpty;

  void selectJenisIzin(String? value) => selectedJenisIzin.value = value;

  Future<void> pickTanggalMulai(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggalMulai.value ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      tanggalMulai.value = picked;
      // Reset tanggal selesai jika sebelum mulai
      if (tanggalSelesai.value != null && tanggalSelesai.value!.isBefore(picked)) {
        tanggalSelesai.value = null;
      }
    }
  }

  Future<void> pickTanggalSelesai(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggalSelesai.value ?? (tanggalMulai.value ?? DateTime.now()),
      firstDate: tanggalMulai.value ?? DateTime(2024),
      lastDate: DateTime(2027),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) tanggalSelesai.value = picked;
  }

  Future<void> pickAttachment() async {
    // Placeholder: di produksi gunakan file_picker package
    attachedFileName.value = 'dokumen_izin.pdf';
  }

  void removeAttachment() => attachedFileName.value = null;

  Future<void> submitIzin() async {
    if (!isFormValid) {
      CustomSnackbar(
        message: 'Mohon lengkapi semua field yang diperlukan.',
        type: CustomSnackbarType.error,
      ).show(Get.overlayContext!);
      return;
    }

    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 2)); // Simulasi API call
    isLoading.value = false;

    CustomSnackbar(
      message: 'Pengajuan izin Anda telah berhasil dikirim.',
      type: CustomSnackbarType.success,
    ).show(Get.overlayContext!);

    // Reset form
    _resetForm();
  }

  void _resetForm() {
    selectedJenisIzin.value = null;
    tanggalMulai.value = null;
    tanggalSelesai.value = null;
    alasanController.clear();
    attachedFileName.value = null;
  }

  @override
  void onClose() {
    alasanController.dispose();
    super.onClose();
  }
}
