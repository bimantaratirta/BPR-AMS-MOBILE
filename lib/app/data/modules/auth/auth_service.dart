import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/auth/auth_repository.dart';
import 'package:bpr_ams/app/data/modules/auth/models/login_response_model.dart';
import 'package:bpr_ams/app/data/modules/user/models/user_model.dart';
import 'package:bpr_ams/app/data/storage/storage_client.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AuthService {
  final AuthRepository _authRepository = AuthRepository();
  final AuthController _authController = Get.find<AuthController>();

  Future<ApiResponseModel<LoginResponseModel>> login(Map<String, dynamic> body) async {
    try {
      final response = await _authRepository.login(body);
      if ((response.code == 200 || response.code == 201) && response.data != null) {
        if (response.data is LoginResponseModel) {
          if (response.data?.token != null &&
              response.data?.token?.accessToken != null &&
              response.data?.token?.refreshToken != null) {
            final jwtPayload = Helper().decodeJwt(response.data!.token!.accessToken!);
            final roleStringFromJwt = jwtPayload?['role'] as String?;
            final userRole = UserRole.fromString(roleStringFromJwt);
            _authController.pickRole.value = userRole;
            await StorageClient.saveToken(response.data!.token!.accessToken!, response.data!.token!.refreshToken!);
          }
        }

        final meResponse = await me();
        if ((meResponse.code == 200 || meResponse.code == 201) && meResponse.data != null) {
          _authController.user.value = meResponse.data;
          _authController.user.refresh();
        }
      }
      return response;
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel> register(Map<String, dynamic> body) async {
    try {
      return await _authRepository.register(body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<UserModel>> me() async {
    try {
      return await _authRepository.me();
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await _authRepository.updateProfile(body);
      if (response.code == 200 || response.code == 201) {
        final meResponse = await me();
        if ((meResponse.code == 200 || meResponse.code == 201) && meResponse.data != null) {
          _authController.user.value = meResponse.data;
          _authController.user.refresh();
        }
      }
      return response;
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }
}
