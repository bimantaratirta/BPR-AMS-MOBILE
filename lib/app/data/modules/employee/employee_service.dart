import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/auth/models/login_response_model.dart';
import 'package:bpr_ams/app/data/modules/employee/employee_repository.dart';
import 'package:bpr_ams/app/data/modules/employee/models/employee_model.dart';

class EmployeeService {
  final EmployeeRepository _employeeRepository = EmployeeRepository();
  final Helper helper = Helper();

  Future<ApiResponseModel<EmployeeModel>> getEmployeeById(String id) async {
    try {
      return await _employeeRepository.getEmployeeById(id);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<EmployeeModel>> updateEmployee(String id, Map<String, dynamic> body) async {
    try {
      return await _employeeRepository.updateEmployee(id, body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<EmployeeModel>> register(Map<String, dynamic> body) async {
    try {
      return await _employeeRepository.register(body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }

  Future<ApiResponseModel<LoginResponseModel>> loginEmployee(Map<String, dynamic> body) async {
    try {
      return await _employeeRepository.loginEmployee(body);
    } catch (e) {
      return ApiResponseModel(error: e.toString());
    }
  }
}
