import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/attendance/attendance_repository.dart';
import 'package:bpr_ams/app/data/modules/attendance/models/attendance_model.dart';
import 'package:dio/dio.dart';

class AttendanceService {
  final AttendanceRepository _repository = AttendanceRepository();

  Future<ApiResponseModel<List<AttendanceModel>>> getAttendances({Map<String, dynamic>? queryParameters}) async {
    try {
      return await _repository.getAttendances(queryParameters: queryParameters);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<AttendanceModel>> getAttendanceById(String id) async {
    try {
      return await _repository.getAttendanceById(id);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<AttendanceModel>> createAttendance(Map<String, dynamic> body) async {
    try {
      return await _repository.createAttendance(body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<AttendanceModel>> updateAttendance(String id, Map<String, dynamic> body) async {
    try {
      return await _repository.updateAttendance(id, body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  // ── Check-in (multipart with photo) ─────────────────────────
  Future<ApiResponseModel<AttendanceModel>> checkIn(FormData formData) async {
    try {
      return await _repository.checkIn(formData);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  // ── Check-out ───────────────────────────────────────────────
  Future<ApiResponseModel<AttendanceModel>> checkOut(Map<String, dynamic> body) async {
    try {
      return await _repository.checkOut(body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }
}
