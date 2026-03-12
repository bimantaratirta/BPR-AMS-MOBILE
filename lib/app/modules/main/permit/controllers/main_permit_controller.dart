import 'package:bpr_ams/app/data/modules/leave_request/leave_request_service.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:bpr_ams/app/widgets/build_custom_snackbar.dart';

class MainPermitController extends GetxController {
  final LeaveRequestService _leaveRequestService = LeaveRequestService();
  final AuthController _authController = Get.find<AuthController>();

  // ─── Jenis Izin options (mapped to API enum values) ─────────
  final Map<String, String> jenisIzinMap = {
    'Izin Cuti': 'IZIN_CUTI',
    'Izin Sakit': 'IZIN_SAKIT',
    'Izin Setengah Hari': 'IZIN_SETENGAH_HARI',
  };

  List<String> get jenisIzinOptions => jenisIzinMap.keys.toList();

  final RxnString selectedJenisIzin = RxnString(null);

  // ─── Tanggal ──────────────────────────────────────────────
  final Rx<DateTime?> tanggalMulai = Rx<DateTime?>(null);
  final Rx<DateTime?> tanggalSelesai = Rx<DateTime?>(null);

  // ─── Alasan ───────────────────────────────────────────────
  final TextEditingController alasanController = TextEditingController();

  // ─── Lampiran (real file) ─────────────────────────────────
  final RxnString attachedFileName = RxnString(null);
  PlatformFile? _pickedFile;

  // ─── Loading & Validation ─────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;
  final RxMap<String, String> validationErrors = <String, String>{}.obs;

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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
      withReadStream: false,
    );

    if (result != null && result.files.isNotEmpty) {
      _pickedFile = result.files.first;
      attachedFileName.value = _pickedFile!.name;
    }
  }

  void removeAttachment() {
    _pickedFile = null;
    attachedFileName.value = null;
  }

  Future<void> submitIzin() async {
    validationErrors.clear();
    message.value = '';

    if (!isFormValid) {
      CustomSnackbar(
        message: 'Mohon lengkapi semua field yang diperlukan.',
        type: CustomSnackbarType.error,
      ).show(Get.overlayContext!);
      return;
    }

    isLoading.value = true;

    try {
      final employeeId = _authController.employee.value?.id;
      if (employeeId == null) {
        CustomSnackbar(
          message: 'Gagal mendapatkan data karyawan. Silakan login ulang.',
          type: CustomSnackbarType.error,
        ).show(Get.overlayContext!);
        isLoading.value = false;
        return;
      }

      // Map selected jenis izin to API enum value
      final leaveType = jenisIzinMap[selectedJenisIzin.value] ?? 'IZIN_CUTI';

      final startDateStr = tanggalMulai.value!.toIso8601String();
      final endDateStr = tanggalSelesai.value!.toIso8601String();

      // Build FormData
      final formData = FormData.fromMap({
        'type': leaveType,
        'startDate': startDateStr,
        'endDate': endDateStr,
        'reason': alasanController.text.trim(),
        // 'employeeId': employeeId,
      });

      // Add attachment file if present
      if (_pickedFile != null && _pickedFile!.path != null) {
        formData.files.add(
          MapEntry('attachment', await MultipartFile.fromFile(_pickedFile!.path!, filename: _pickedFile!.name)),
        );
      }

      final response = await _leaveRequestService.createLeaveRequest(formData);

      if (response.code == 200 || response.code == 201) {
        CustomSnackbar(
          message: 'Pengajuan izin Anda telah berhasil dikirim.',
          type: CustomSnackbarType.success,
        ).show(Get.overlayContext!);

        // Reset form
        _resetForm();
      } else if (response.code == 422) {
        // Handle validation errors from API
        if (response.errors is Map<String, dynamic> && response.errors['validation'] is Map<String, dynamic>) {
          final validationErrorsMap = response.errors['validation'] as Map<String, dynamic>;
          validationErrorsMap.forEach((fieldKey, errorList) {
            if (errorList is List && errorList.isNotEmpty) {
              validationErrors[fieldKey] = errorList[0].toString();
            }
          });
          validationErrors.refresh();
          message.value =
              response.error ?? response.errors['message'] ?? response.message ?? 'Validasi gagal. Periksa input Anda.';
        } else if (response.error != null) {
          message.value = response.error.toString();
        } else {
          message.value = 'Validasi gagal. Periksa input Anda.';
        }

        CustomSnackbar(
          message: message.value.isNotEmpty ? message.value : 'Validasi gagal.',
          type: CustomSnackbarType.warning,
        ).show(Get.overlayContext!);
      } else {
        String errorMsg =
            response.errors?.toString() ??
            response.error?.toString() ??
            response.message ??
            'Gagal mengirim pengajuan izin.';
        message.value = errorMsg;
        CustomSnackbar(message: errorMsg, type: CustomSnackbarType.error).show(Get.overlayContext!);
      }
    } catch (e) {
      CustomSnackbar(message: 'Terjadi kesalahan: $e', type: CustomSnackbarType.error).show(Get.overlayContext!);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    selectedJenisIzin.value = null;
    tanggalMulai.value = null;
    tanggalSelesai.value = null;
    alasanController.clear();
    _pickedFile = null;
    attachedFileName.value = null;
  }

  @override
  void onClose() {
    alasanController.dispose();
    super.onClose();
  }
}
