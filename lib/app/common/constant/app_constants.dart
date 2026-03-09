class AppConstants {
  // API Constants
  // static const String baseApiUrl = "http://10.0.2.2:3001/api/v2";
  static const String baseApiUrl = "https://api.bpr.ashakita.net/api/v1";
  static const String baseImageUrl = "https://is3.cloudhost.id/bpr-ams";

  // Endpoints
  static const String authEmployeePathApi = "/auth/employee";
  static const String employeePathApi = "/employees";
  static const String adminPathApi = "/admins";
  static const String authAdminPathApi = "/auth/admin";
  static const String attendancePathApi = "/attendances";
  static const String checkInPathApi = "/attendances/checkin";
  static const String checkOutPathApi = "/attendances/checkout";
  static const String leaveRequestPathApi = "/leave-requests";
  static const String pointRecordPathApi = "/point-records";

  // Storage Keys
  static const String userKey = "user_data";

  // Other Constants
  static const int timeoutDuration = 30000; // milliseconds
}
