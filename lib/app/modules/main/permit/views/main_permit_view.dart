import 'package:bpr_ams/app/common/constant/app_colors.dart';
import 'package:bpr_ams/app/widgets/build_navigation/build_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/main_permit_controller.dart';

class MainPermitView extends GetView<MainPermitController> {
  const MainPermitView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEEF2FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengajuan Izin',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: SecondaryColor.neutral700),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Ajukan permohonan cuti atau izin',
                    style: TextStyle(fontSize: 13.sp, color: MainColor.greyNormal, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            // ── Scrollable form ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: SecondaryColor.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildJenisIzin(),
                      SizedBox(height: 20.h),
                      _buildDateRow(context),
                      SizedBox(height: 20.h),
                      _buildAlasan(),
                      SizedBox(height: 20.h),
                      _buildLampiran(),
                      SizedBox(height: 28.h),
                      _buildSubmitButton(),
                    ],
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
  // Jenis Izin Dropdown
  // ─────────────────────────────────────────────
  Widget _buildJenisIzin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Jenis Izin'),
        SizedBox(height: 8.h),
        Obx(
          () => _dropdownField(
            value: controller.selectedJenisIzin.value,
            hint: 'Pilih jenis izin',
            items: controller.jenisIzinOptions,
            onChanged: controller.selectJenisIzin,
          ),
        ),
      ],
    );
  }

  Widget _dropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: _inputDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(fontSize: 14.sp, color: SecondaryColor.neutral400)),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: SecondaryColor.neutral400, size: 22.sp),
          style: TextStyle(fontSize: 14.sp, color: SecondaryColor.neutral700, fontWeight: FontWeight.w500),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Tanggal Row
  // ─────────────────────────────────────────────
  Widget _buildDateRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildDateField(context, isMulai: true)),
        SizedBox(width: 12.w),
        Expanded(child: _buildDateField(context, isMulai: false)),
      ],
    );
  }

  Widget _buildDateField(BuildContext context, {required bool isMulai}) {
    return Obx(() {
      final date = isMulai ? controller.tanggalMulai.value : controller.tanggalSelesai.value;
      final dateStr = date != null ? DateFormat('dd/MM/yyyy').format(date) : 'dd/mm/yyyy';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(isMulai ? 'Tanggal Mulai' : 'Tanggal Selesai'),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () => isMulai ? controller.pickTanggalMulai(context) : controller.pickTanggalSelesai(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
              decoration: _inputDecoration(),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16.sp,
                    color: date != null ? MainColor.blue2 : SecondaryColor.neutral400,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: date != null ? SecondaryColor.neutral700 : SecondaryColor.neutral400,
                      fontWeight: date != null ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // ─────────────────────────────────────────────
  // Alasan TextField
  // ─────────────────────────────────────────────
  Widget _buildAlasan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Alasan'),
        SizedBox(height: 8.h),
        Container(
          decoration: _inputDecoration(),
          child: TextField(
            controller: controller.alasanController,
            maxLines: 5,
            minLines: 4,
            style: TextStyle(fontSize: 14.sp, color: SecondaryColor.neutral700),
            decoration: InputDecoration(
              hintText: 'Tuliskan alasan izin Anda...',
              hintStyle: TextStyle(fontSize: 14.sp, color: SecondaryColor.neutral400),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Lampiran Upload Area
  // ─────────────────────────────────────────────
  Widget _buildLampiran() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Lampiran'),
        SizedBox(height: 8.h),
        Obx(() {
          final fileName = controller.attachedFileName.value;
          if (fileName != null) {
            return _attachedFileChip(fileName);
          }
          return GestureDetector(
            onTap: controller.pickAttachment,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 28.h),
              decoration: BoxDecoration(
                color: MainColor.blueLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: MainColor.blueLightActive.withOpacity(0.5), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_outlined, size: 32.sp, color: MainColor.blue2),
                  SizedBox(height: 8.h),
                  Text(
                    'Upload Dokumen',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: MainColor.blue2),
                  ),
                  SizedBox(height: 4.h),
                  Text('PDF, JPG, PNG (maks. 5MB)', style: TextStyle(fontSize: 11.sp, color: SecondaryColor.neutral400)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _attachedFileChip(String fileName) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xffE4F2FE),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: MainColor.blue2.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 20.sp, color: MainColor.blue2),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              fileName,
              style: TextStyle(fontSize: 13.sp, color: MainColor.blue2, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: controller.removeAttachment,
            child: Icon(Icons.close_rounded, size: 18.sp, color: SecondaryColor.neutral400),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Submit Button
  // ─────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return Obx(() {
      final loading = controller.isLoading.value;
      return SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: loading ? null : controller.submitIzin,
          style: ElevatedButton.styleFrom(
            backgroundColor: MainColor.blue2,
            foregroundColor: SecondaryColor.white,
            disabledBackgroundColor: MainColor.blueLight1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            elevation: 0,
          ),
          child:
              loading
                  ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(color: SecondaryColor.white, strokeWidth: 2.5),
                  )
                  : Text(
                    'Ajukan Izin',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: SecondaryColor.white),
                  ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  Widget _label(String text) {
    return Text(text, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: SecondaryColor.neutral700));
  }

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: SecondaryColor.neutral100,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: SecondaryColor.neutral300, width: 1),
    );
  }
}
