import 'package:bpr_ams/app/data/modules/user/models/user_model.dart';
import 'package:bpr_ams/app/data/storage/storage_client.dart';
import 'package:get/get.dart';

enum UserRole {
  lo(value: "LO"),
  slo(value: "SLO"),
  am(value: "AM"),
  direksi(value: "Direksi");

  final String value;

  const UserRole({required this.value});

  static UserRole? fromString(String? roleString) {
    if (roleString == null) return null;
    try {
      return UserRole.values.firstWhere((e) => e.value.toUpperCase() == roleString.toUpperCase());
    } catch (e) {
      return null;
    }
  }
}

class AuthController extends GetxController {
  Rx<UserModel?> user = Rx<UserModel?>(null);
  Rx<List<UserRole>> roles = Rx<List<UserRole>>([UserRole.lo, UserRole.slo, UserRole.am, UserRole.direksi]);
  Rx<UserRole?> pickRole = Rx<UserRole?>(null);

  void changePickRole(UserRole? value) {
    pickRole.value = value;
  }

  Future<void> logout() async {
    user.value = null;
    pickRole.value = null;
    await StorageClient.clearSession();
  }
}
