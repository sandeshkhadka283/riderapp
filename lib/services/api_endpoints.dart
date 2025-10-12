class ApiEndpoints {
  static const String baseUrl =
      "https://prod-api.nepdrop.com/api/v1"; // Replace with actual

  static const String login = "$baseUrl/user/login/phone";
  static const String verifyOtp = "$baseUrl/user/code"; // Example
  static const String logout = "$baseUrl/logout"; // Example
  // Add more as needed...
}
