import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'api_endpoints.dart';

class ApiService {
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return {
          "operating_system": {
            "name": "Android",
            "version": androidInfo.version.release,
          },
          "browser": {"name": "N/A", "version": "N/A"},
          "manufacturer": androidInfo.manufacturer ?? "Unknown",
          "model": androidInfo.model ?? "Unknown",
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return {
          "operating_system": {
            "name": "iOS",
            "version": iosInfo.systemVersion ?? "unknown",
          },
          "browser": {"name": "N/A", "version": "N/A"},
          "manufacturer": "Apple",
          "model": iosInfo.utsname.machine ?? "Unknown",
        };
      } else {
        // Fallback for web or unknown platforms
        return {
          "operating_system": {"name": "unknown", "version": "unknown"},
          "browser": {"name": "unknown", "version": "unknown"},
          "manufacturer": "Unknown",
          "model": "Unknown",
        };
      }
    } catch (e) {
      print("[ApiService] Error fetching device info: $e");
      return {
        "operating_system": {"name": "unknown", "version": "unknown"},
        "browser": {"name": "unknown", "version": "unknown"},
        "manufacturer": "Unknown",
        "model": "Unknown",
      };
    }
  }

  static Future<List<double>> getLocationCoordinates() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print(
          "[ApiService] Location services not enabled, requesting permission.",
        );
        await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition();
      print(
        "[ApiService] Location coordinates obtained: [${position.longitude}, ${position.latitude}]",
      );
      return [position.longitude, position.latitude];
    } catch (e) {
      print("[ApiService] Error getting location coordinates: $e");
      return [0.0, 0.0];
    }
  }

  static Future<http.Response> loginUser({
    required String phone,
    required String method,
  }) async {
    final deviceInfo = await getDeviceInfo();
    final coordinates = await getLocationCoordinates();

    final payload = {
      "phone": phone,
      "country_code": "977",
      "code": "2745", // Replace with real OTP later
      "device": {
        "login_origin": "root",
        "app": "vehicle",
        "device_uuid": "bf0789cb-d9bb-4ebe-979d-3450e58f7dc467",
        "type": "mobile",
        "operating_system": deviceInfo["operating_system"],
        "browser": deviceInfo["browser"],
        "manufacturer": deviceInfo["manufacturer"],
        "model": deviceInfo["model"],
        "platform": "app",
        "status": "ACTIVE",
        "n_token": "fcm notification token",
        "location": {"coordinates": coordinates},
      },
    };

    final url = Uri.parse(ApiEndpoints.login);
    print("[ApiService] Login URL: $url");
    print("[ApiService] Payload to send: ${jsonEncode(payload)}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("[ApiService] Response status code: ${response.statusCode}");
      print("[ApiService] Response body: ${response.body}");

      return response;
    } catch (e) {
      print("[ApiService] Network error: $e");
      rethrow;
    }
  }

  /// Verify OTP API call
  static Future<http.Response> verifyOtp({
    required String phone,
    required String code,
    required String token,
  }) async {
    final payload = {"address": phone, "type": "phone", "code": code};

    final url = Uri.parse(ApiEndpoints.verifyOtp);
    print("[ApiService] Verify OTP URL: $url");
    print("[ApiService] Payload to send: ${jsonEncode(payload)}");
    print("[ApiService] Using token: $token");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "token": token, // ✅ matches Postman setup
        },
        body: jsonEncode(payload),
      );

      print("[ApiService] Response status code: ${response.statusCode}");
      print("[ApiService] Response headers: ${response.headers}");
      print("[ApiService] Response body: ${response.body}");

      return response;
    } catch (e) {
      print("[ApiService] Network error: $e");
      rethrow;
    }
  }

  /// Fetch available delivery vehicles
  static Future<http.Response> fetchAvailableVehicles({
    required String token,
    double lat = 0.0,
    double lng = 0.0,
    int limit = 10,
    int start = 0,
  }) async {
    final url = Uri.parse(
      "${ApiEndpoints.fetchAvailableVehicles}?limit=$limit&start=$start&lat=$lat&lng=$lng",
    );

    print("[ApiService] Fetching available vehicles from: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "token": token, // same header style as verifyOtp()
        },
      );

      print("[ApiService] Response status code: ${response.statusCode}");
      print("[ApiService] Response body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ Vehicles fetched successfully");
      } else if (response.statusCode == 401) {
        print("⚠️ Unauthorized: Token expired or invalid");
      } else if (response.statusCode == 404) {
        print("❌ Endpoint not found: Check API path or backend routes");
      }

      return response;
    } catch (e) {
      print("[ApiService] Network error: $e");
      rethrow;
    }
  }
}
