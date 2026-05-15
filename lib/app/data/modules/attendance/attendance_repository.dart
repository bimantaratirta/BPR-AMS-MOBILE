import 'package:bpr_ams/app/common/constant/app_constants.dart';
import 'package:bpr_ams/app/data/main/api/api_params_model.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/attendance/models/attendance_model.dart';
import 'package:bpr_ams/app/network/api_client.dart';
import 'package:dio/dio.dart';

class AttendanceRepository {
  // ── Get all (with optional query params) ────────────────────
  Future<ApiResponseModel<List<AttendanceModel>>> getAttendances({Map<String, dynamic>? queryParameters}) async {
    return await apiClient.get(
      ApiParams<List<AttendanceModel>>(
        path: AppConstants.attendancePathApi,
        queryParameters: queryParameters,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => AttendanceModel.fromJson(e)).toList();
          }
          return <AttendanceModel>[];
        },
      ),
    );
  }

  // ── Get by ID ───────────────────────────────────────────────
  Future<ApiResponseModel<AttendanceModel>> getAttendanceById(String id) async {
    return await apiClient.get(
      ApiParams<AttendanceModel>(
        path: "${AppConstants.attendancePathApi}/$id",
        fromJson: (json) => AttendanceModel.fromJson(json),
      ),
    );
  }

  // ── Create (check-in) ───────────────────────────────────────
  Future<ApiResponseModel<AttendanceModel>> createAttendance(Map<String, dynamic> body) async {
    return await apiClient.post(
      ApiParams<AttendanceModel>(
        path: AppConstants.attendancePathApi,
        body: body,
        fromJson: (json) => AttendanceModel.fromJson(json),
      ),
    );
  }

  // ── Update (check-out) ──────────────────────────────────────
  Future<ApiResponseModel<AttendanceModel>> updateAttendance(String id, Map<String, dynamic> body) async {
    return await apiClient.put(
      ApiParams<AttendanceModel>(
        path: "${AppConstants.attendancePathApi}/$id",
        body: body,
        fromJson: (json) => AttendanceModel.fromJson(json),
      ),
    );
  }

  // ── Check-in (multipart with photo) ─────────────────────────
  // Override timeout 60s — upload foto S3 di server bisa molor saat peak hour.
  Future<ApiResponseModel<AttendanceModel>> checkIn(FormData formData) async {
    return await apiClient.post(
      ApiParams<AttendanceModel>(
        path: AppConstants.checkInPathApi,
        formData: formData,
        fromJson: (json) => AttendanceModel.fromJson(json),
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ),
    );
  }

  // ── Check-out ───────────────────────────────────────────────
  Future<ApiResponseModel<AttendanceModel>> checkOut(Map<String, dynamic> body) async {
    return await apiClient.post(
      ApiParams<AttendanceModel>(
        path: AppConstants.checkOutPathApi,
        body: body,
        fromJson: (json) => AttendanceModel.fromJson(json),
      ),
    );
  }
}
