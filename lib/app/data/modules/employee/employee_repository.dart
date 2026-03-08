import 'package:bpr_ams/app/common/constant/app_constants.dart';
import 'package:bpr_ams/app/common/utils/helper.dart';
import 'package:bpr_ams/app/data/main/api/api_params_model.dart';
import 'package:bpr_ams/app/data/main/api/api_response_model.dart';
import 'package:bpr_ams/app/data/modules/auth/models/login_response_model.dart';
import 'package:bpr_ams/app/data/modules/employee/models/employee_model.dart';
import 'package:bpr_ams/app/network/api_client.dart';

class EmployeeRepository {
  final Helper helper = Helper();

  Future<ApiResponseModel<LoginResponseModel>> loginEmployee(Map<String, dynamic> body) async {
    return await apiClient.post(
      ApiParams<LoginResponseModel>(
        path: "${AppConstants.authEmployeePathApi}/login",
        body: body,
        fromJson: (json) => LoginResponseModel.fromJson(json),
      ),
    );
  }

  Future<ApiResponseModel<EmployeeModel>> register(Map<String, dynamic> body) async {
    return await apiClient.post(
      ApiParams(
        path: "${AppConstants.authEmployeePathApi}/register",
        body: body,
        fromJson: (json) => EmployeeModel.fromJson(json),
      ),
    );
  }

  Future<ApiResponseModel<EmployeeModel>> getEmployeeById(String id) async {
    return await apiClient.get(
      ApiParams<EmployeeModel>(
        path: "${AppConstants.employeePathApi}/$id",
        fromJson: (json) => EmployeeModel.fromJson(json),
      ),
    );
  }

  Future<ApiResponseModel<EmployeeModel>> updateEmployee(String id, Map<String, dynamic> body) async {
    return await apiClient.put(
      ApiParams<EmployeeModel>(
        path: "${AppConstants.employeePathApi}/$id",
        body: body,
        fromJson: (json) => EmployeeModel.fromJson(json),
      ),
    );
  }
}
