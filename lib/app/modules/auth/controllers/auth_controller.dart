import 'package:bpr_ams/app/data/modules/admin/models/admin_model.dart';
import 'package:bpr_ams/app/data/modules/employee/models/employee_model.dart';
import 'package:bpr_ams/app/data/storage/storage_client.dart';
import 'package:get/get.dart';

enum UserType {
  employee(value: "EMPLOYEE"),
  superAdmin(value: "SUPER_ADMIN"),
  admin(value: "ADMIN"),
  viewer(value: "VIEWER");

  final String value;

  const UserType({required this.value});

  static UserType? fromString(String? roleString) {
    if (roleString == null) return null;
    try {
      return UserType.values.firstWhere((e) => e.value.toUpperCase() == roleString.toUpperCase());
    } catch (e) {
      return null;
    }
  }
}

class AuthController extends GetxController {
  Rx<EmployeeModel?> employee = Rx<EmployeeModel?>(null);
  Rx<AdminModel?> admin = Rx<AdminModel?>(null);
  Rx<String?> id = Rx<String?>(null);
  Rx<List<UserType>> userTypes = Rx<List<UserType>>([
    UserType.employee,
    UserType.superAdmin,
    UserType.admin,
    UserType.viewer,
  ]);
  Rx<UserType?> pickUserType = Rx<UserType?>(null);

  void changePickUserType(UserType? value) {
    pickUserType.value = value;
  }

  Future<void> logout() async {
    employee.value = null;
    admin.value = null;
    pickUserType.value = null;
    id.value = null;
    await StorageClient.clearSession();
  }
}
