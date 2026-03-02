import 'package:bpr_ams/app/common/constant/app_constants.dart';
import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/main/api/api_params_model.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/user/models/user_model.dart';
import 'package:bpr_ams/app/network/api_client.dart';

class UserRepository {
  final Helper helper = Helper();

  Future<ApiResponseModel<List<UserModel>>> getAllUsers(String paramsEncoded) async {
    return await apiClient.get(
      ApiParams<List<UserModel>>(
        path: "${AppConstants.userEndpoint}$paramsEncoded",
        fromJson: (json) => helper.listParser(json, UserModel.fromJson),
      ),
    );
  }

  Future<ApiResponseModel<List<UserModel>>> getAllLoBySlo(String id, String paramsEncoded) async {
    return await apiClient.get(
      ApiParams<List<UserModel>>(
        path: "${AppConstants.userLoBySloEndpoint}/$id$paramsEncoded",
        fromJson: (json) => helper.listParser(json, UserModel.fromJson),
      ),
    );
  }

  Future<ApiResponseModel<List<UserModel>>> getAllSloByAm(String id, String paramsEncoded) async {
    return await apiClient.get(
      ApiParams<List<UserModel>>(
        path: "${AppConstants.userSloByAmEndpoint}/$id$paramsEncoded",
        fromJson: (json) => helper.listParser(json, UserModel.fromJson),
      ),
    );
  }

  Future<ApiResponseModel<UserModel>> getUserById(String id) async {
    return await apiClient.get(
      ApiParams(path: "${AppConstants.userEndpoint}/$id", fromJson: (json) => UserModel.fromJson(json)),
    );
  }
}
