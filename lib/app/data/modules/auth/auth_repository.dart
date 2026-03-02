import 'package:bpr_ams/app/common/constant/app_constants.dart';
import 'package:bpr_ams/app/data/main/api/api_params_model.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/auth/models/login_response_model.dart';
import 'package:bpr_ams/app/data/modules/user/models/user_model.dart';
import 'package:bpr_ams/app/network/api_client.dart';

class AuthRepository {
  Future<ApiResponseModel<LoginResponseModel>> login(Map<String, dynamic> body) async {
    return await apiClient.post(
      ApiParams<LoginResponseModel>(
        path: AppConstants.loginEndpoint,
        body: body,
        fromJson: (json) => LoginResponseModel.fromJson(json),
      ),
    );
  }

  Future<ApiResponseModel> register(Map<String, dynamic> body) async {
    return await apiClient.post(ApiParams(path: AppConstants.registerEndpoint, body: body, fromJson: (json) => null));
  }

  Future<ApiResponseModel<UserModel>> me() async {
    return await apiClient.get(
      ApiParams<UserModel>(path: AppConstants.meEndpoint, fromJson: (json) => UserModel.fromJson(json)),
    );
  }

  Future<ApiResponseModel> updateProfile(Map<String, dynamic> body) async {
    return await apiClient.put(ApiParams(path: AppConstants.meEndpoint, body: body, fromJson: (json) => null));
  }
}
