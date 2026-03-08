import 'package:bpr_ams/app/common/constant/app_constants.dart';
import 'package:bpr_ams/app/data/main/api/api_params_model.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/leave_request/models/leave_request_model.dart';
import 'package:bpr_ams/app/network/api_client.dart';
import 'package:dio/dio.dart';

class LeaveRequestRepository {
  // ── Create ──────────────────────────────────────────────────
  Future<ApiResponseModel<LeaveRequestModel>> createLeaveRequest(FormData formData) async {
    return await apiClient.post(
      ApiParams<LeaveRequestModel>(
        path: AppConstants.leaveRequestPathApi,
        formData: formData,
        fromJson: (json) => LeaveRequestModel.fromJson(json),
      ),
    );
  }

  // ── Get all (with optional query params) ────────────────────
  Future<ApiResponseModel<List<LeaveRequestModel>>> getLeaveRequests({Map<String, dynamic>? queryParameters}) async {
    return await apiClient.get(
      ApiParams<List<LeaveRequestModel>>(
        path: AppConstants.leaveRequestPathApi,
        queryParameters: queryParameters,
        fromJson: (json) {
          if (json is List) {
            return json.map((e) => LeaveRequestModel.fromJson(e)).toList();
          }
          return <LeaveRequestModel>[];
        },
      ),
    );
  }

  // ── Get by ID ───────────────────────────────────────────────
  Future<ApiResponseModel<LeaveRequestModel>> getLeaveRequestById(String id) async {
    return await apiClient.get(
      ApiParams<LeaveRequestModel>(
        path: "${AppConstants.leaveRequestPathApi}/$id",
        fromJson: (json) => LeaveRequestModel.fromJson(json),
      ),
    );
  }

  // ── Update ──────────────────────────────────────────────────
  Future<ApiResponseModel<LeaveRequestModel>> updateLeaveRequest(String id, Map<String, dynamic> body) async {
    return await apiClient.put(
      ApiParams<LeaveRequestModel>(
        path: "${AppConstants.leaveRequestPathApi}/$id",
        body: body,
        fromJson: (json) => LeaveRequestModel.fromJson(json),
      ),
    );
  }

  // ── Delete ──────────────────────────────────────────────────
  Future<ApiResponseModel<LeaveRequestModel>> deleteLeaveRequest(String id) async {
    return await apiClient.delete(
      ApiParams<LeaveRequestModel>(
        path: "${AppConstants.leaveRequestPathApi}/$id",
        fromJson: (json) => LeaveRequestModel.fromJson(json),
      ),
    );
  }
}
