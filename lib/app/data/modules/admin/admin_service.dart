import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/auth/models/login_response_model.dart';
import 'package:bpr_ams/app/data/modules/admin/admin_repository.dart';
import 'package:bpr_ams/app/data/modules/admin/models/admin_model.dart';

class AdminService {
  final AdminRepository _adminRepository = AdminRepository();
  final Helper helper = Helper();

  Future<ApiResponseModel<AdminModel>> getAdminById(String id) async {
    try {
      return await _adminRepository.getAdminById(id);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<AdminModel>> updateAdmin(String id, Map<String, dynamic> body) async {
    try {
      return await _adminRepository.updateAdmin(id, body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<AdminModel>> register(Map<String, dynamic> body) async {
    try {
      return await _adminRepository.register(body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<LoginResponseModel>> loginAdmin(Map<String, dynamic> body) async {
    try {
      return await _adminRepository.loginAdmin(body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }
}
