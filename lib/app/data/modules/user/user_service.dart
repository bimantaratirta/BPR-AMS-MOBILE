import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/user/models/user_model.dart';
import 'package:bpr_ams/app/data/modules/user/user_repository.dart';

class UserService {
  final UserRepository _userRepository = UserRepository();
  final Helper helper = Helper();

  Future<ApiResponseModel<List<UserModel>>> getAllUsers([Map<String, dynamic>? params]) async {
    try {
      final String paramsEncoded = helper.encodeQueryParams(params ?? {});
      return await _userRepository.getAllUsers(paramsEncoded);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<List<UserModel>>> getAllLoBySlo({required String id, Map<String, dynamic>? params}) async {
    try {
      final Map<String, dynamic> queryParams = params ?? {};
      final String paramsEncoded = helper.encodeQueryParams(queryParams);
      return await _userRepository.getAllLoBySlo(id, paramsEncoded);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<List<UserModel>>> getAllSloByAm({required String id, Map<String, dynamic>? params}) async {
    try {
      final Map<String, dynamic> queryParams = params ?? {};
      final String paramsEncoded = helper.encodeQueryParams(queryParams);
      return await _userRepository.getAllSloByAm(id, paramsEncoded);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<UserModel>> getUserById(String id) async {
    try {
      return await _userRepository.getUserById(id);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }
}
