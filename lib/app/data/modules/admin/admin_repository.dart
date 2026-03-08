import 'package:bpr_ams/app/common/constant/app_constants.dart';
import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/main/api/api_params_model.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/admin/models/admin_model.dart';
import 'package:bpr_ams/app/data/modules/auth/models/login_response_model.dart';
import 'package:bpr_ams/app/network/api_client.dart';

class AdminRepository {
  final Helper helper = Helper();

  Future<ApiResponseModel<LoginResponseModel>> loginAdmin(Map<String, dynamic> body) async {
    return await apiClient.post(
      ApiParams<LoginResponseModel>(
        path: "${AppConstants.authAdminPathApi}/login",
        body: body,
        fromJson: (json) => LoginResponseModel.fromJson(json),
      ),
    );
  }

  Future<ApiResponseModel<AdminModel>> register(Map<String, dynamic> body) async {
    return await apiClient.post(
      ApiParams(
        path: "${AppConstants.authAdminPathApi}/register",
        body: body,
        fromJson: (json) => AdminModel.fromJson(json),
      ),
    );
  }

  Future<ApiResponseModel<AdminModel>> getAdminById(String id) async {
    return await apiClient.get(
      ApiParams<AdminModel>(path: "${AppConstants.adminPathApi}/$id", fromJson: (json) => AdminModel.fromJson(json)),
    );
  }

  Future<ApiResponseModel<AdminModel>> updateAdmin(String id, Map<String, dynamic> body) async {
    return await apiClient.put(
      ApiParams<AdminModel>(
        path: "${AppConstants.adminPathApi}/$id",
        body: body,
        fromJson: (json) => AdminModel.fromJson(json),
      ),
    );
  }
}
