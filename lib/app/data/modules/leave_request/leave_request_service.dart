import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/leave_request/leave_request_repository.dart';
import 'package:bpr_ams/app/data/modules/leave_request/models/leave_request_model.dart';
import 'package:dio/dio.dart';

class LeaveRequestService {
  final LeaveRequestRepository _repository = LeaveRequestRepository();

  Future<ApiResponseModel<LeaveRequestModel>> createLeaveRequest(FormData formData) async {
    try {
      return await _repository.createLeaveRequest(formData);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<List<LeaveRequestModel>>> getLeaveRequests({Map<String, dynamic>? queryParameters}) async {
    try {
      return await _repository.getLeaveRequests(queryParameters: queryParameters);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<LeaveRequestModel>> getLeaveRequestById(String id) async {
    try {
      return await _repository.getLeaveRequestById(id);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<LeaveRequestModel>> updateLeaveRequest(String id, Map<String, dynamic> body) async {
    try {
      return await _repository.updateLeaveRequest(id, body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<LeaveRequestModel>> deleteLeaveRequest(String id) async {
    try {
      return await _repository.deleteLeaveRequest(id);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }
}
