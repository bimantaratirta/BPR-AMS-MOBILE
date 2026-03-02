class AppConstants {
  // API Constants
  // static const String baseApiUrl = "http://10.0.2.2:3001/api/v2";
  static const String baseApiUrl = "https://api-pms.bprss.com/api/v2";
  static const String baseImageUrl = "https://minio.s3.nevmock.id/bpr-pms";

  // Endpoints
  static const String loginEndpoint = "/auth/login";
  static const String registerEndpoint = "/auth/register";
  static const String meEndpoint = "/auth/me";
  static const String refreshTokenEndpoint = "/auth/refresh-token";
  static const String branchEndpoint = "/branch";
  static const String regionEndpoint = "/region";
  static const String customerEndpoint = "/customer";
  static const String customerByLoEndpoint = "/customer/customer-by-lo";
  static const String reportEndpoint = "/report";
  static const String generateReportEndpoint = "/generate-report";
  static const String reportReviewCustomerEndpoint = "/review-customer";
  static const String reportEvaluationSloEndpoint = "/evaluation";
  static const String reportEvaluationReviewEndpoint = "/review-evaluation";
  static const String userEndpoint = "/user";
  static const String userLoBySloEndpoint = "/user/lo-by-slo";
  static const String userSloByAmEndpoint = "/user/slo-by-am";
  static const String dashboardLoEndpoint = "/dashboard/lo";
  static const String dashboardSloEndpoint = "/dashboard/slo";
  static const String dashboardAmEndpoint = "/dashboard/am";
  static const String dashboardDireksiEndpoint = "/dashboard/direksi";

  // Storage Keys
  static const String userKey = "user_data";

  // Other Constants
  static const int timeoutDuration = 30000; // milliseconds
}
