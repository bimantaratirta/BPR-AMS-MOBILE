import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/admin/admin_service.dart';
import 'package:bpr_ams/app/data/modules/admin/models/admin_model.dart';
import 'package:bpr_ams/app/data/modules/auth/models/login_response_model.dart';
import 'package:bpr_ams/app/data/modules/employee/employee_service.dart';
import 'package:bpr_ams/app/data/modules/employee/models/employee_model.dart';
import 'package:bpr_ams/app/data/storage/storage_client.dart';
import 'package:bpr_ams/app/modules/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AuthService {
  final AuthController _authController = Get.find<AuthController>();
  final EmployeeService _employeeService = EmployeeService();
  final AdminService _adminService = AdminService();

  // ─── Employee ────────────────────────────────────────────────────────────────

  Future<ApiResponseModel<LoginResponseModel>> loginEmployee(Map<String, dynamic> body) async {
    try {
      final response = await _employeeService.loginEmployee(body);
      if ((response.code == 200 || response.code == 201) && response.data != null) {
        final token = response.data!;
        if (token.accessToken != null && token.refreshToken != null) {
          final jwtPayload = Helper().decodeJwt(token.accessToken!);
          final userType = UserType.fromString(jwtPayload?['userType'] as String?);
          _authController.pickUserType.value = userType;
          await StorageClient.saveToken(token.accessToken!, token.refreshToken!);

          final meResponse = await _employeeService.getEmployeeById(jwtPayload?['id'] as String? ?? '');
          if ((meResponse.code == 200 || meResponse.code == 201) && meResponse.data != null) {
            _authController.employee.value = meResponse.data;
            _authController.employee.refresh();
          }
        }
      }
      return response;
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<EmployeeModel>> registerEmployee(Map<String, dynamic> body) async {
    try {
      return await _employeeService.register(body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<EmployeeModel>> updateProfileEmployee(String id, Map<String, dynamic> body) async {
    try {
      final response = await _employeeService.updateEmployee(id, body);
      if ((response.code == 200 || response.code == 201) && response.data != null) {
        _authController.employee.value = response.data;
        _authController.employee.refresh();
      }
      return response;
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  // ─── Admin ───────────────────────────────────────────────────────────────────

  Future<ApiResponseModel<LoginResponseModel>> loginAdmin(Map<String, dynamic> body) async {
    try {
      final response = await _adminService.loginAdmin(body);
      if ((response.code == 200 || response.code == 201) && response.data != null) {
        final token = response.data!;
        if (token.accessToken != null && token.refreshToken != null) {
          final jwtPayload = Helper().decodeJwt(token.accessToken!);
          final userType = UserType.fromString(jwtPayload?['userType'] as String?);
          _authController.pickUserType.value = userType;
          await StorageClient.saveToken(token.accessToken!, token.refreshToken!);

          final meResponse = await _adminService.getAdminById(jwtPayload?['id'] as String? ?? '');
          if ((meResponse.code == 200 || meResponse.code == 201) && meResponse.data != null) {
            _authController.admin.value = meResponse.data;
            _authController.admin.refresh();
          }
        }
      }
      return response;
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<AdminModel>> registerAdmin(Map<String, dynamic> body) async {
    try {
      return await _adminService.register(body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<AdminModel>> updateProfileAdmin(String id, Map<String, dynamic> body) async {
    try {
      final response = await _adminService.updateAdmin(id, body);
      if ((response.code == 200 || response.code == 201) && response.data != null) {
        _authController.admin.value = response.data;
        _authController.admin.refresh();
      }
      return response;
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }
}
