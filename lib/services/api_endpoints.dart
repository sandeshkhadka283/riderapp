class ApiEndpoints {
  static const String baseUrl = "https://dev-api.nepdrop.com/api/v1";

  static const String login = "$baseUrl/user/login/phone";
  static const String verifyOtp = "$baseUrl/user/code";
  static const String fetchAvailableVehicles =
      "$baseUrl/delivery/vehicle/available";
}
