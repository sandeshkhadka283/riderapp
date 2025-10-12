import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:riderapp/screens/otp_screen.dart';
import 'package:riderapp/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _numberController = TextEditingController();
  bool _isLoading = false;

  Future<void> sendLoginRequest(String method) async {
    final phone = _numberController.text.trim();

    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 10-digit phone number"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.loginUser(phone: phone, method: method);

      print(
        "[LoginScreen] Login API response received. Status code: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          print("[LoginScreen] Response body parsed: $data");

          // ✅ Check if the response contains accessToken (indicates success)
          if (data.containsKey("accessToken") && data["accessToken"] != null) {
            final accessToken =
                data["accessToken"]; // <--- Define accessToken here
            print("[LoginScreen] Login successful, accessToken: $accessToken");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OTPScreen(phone: phone, accessToken: accessToken),
              ),
            );
          } else {
            print(
              "[LoginScreen] Login response JSON invalid or not successful.",
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login failed. Please try again.")),
            );
          }
        } catch (e) {
          print("[LoginScreen] Response was not JSON: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unexpected response format.")),
          );
        }
      } else {
        print(
          "[LoginScreen] Login failed: ${response.statusCode} - ${response.body}",
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed. Please try again.")),
        );
      }
    } catch (e) {
      print("[LoginScreen] Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong. Check your connection."),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      print("[LoginScreen] Login request completed, isLoading set to false.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height * 0.95,
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    "Ride Request Viewer",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Login with your phone number",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 70),

                  // Phone input
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "+977",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 24,
                          width: 1.5,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _numberController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: const InputDecoration(
                              hintText: "Enter phone number",
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => sendLoginRequest("whatsapp"),
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "WhatsApp",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 5,
                            shadowColor: Colors.greenAccent.withOpacity(0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => sendLoginRequest("sms"),
                          icon: const Icon(Icons.sms, color: Colors.white),
                          label: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "SMS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 5,
                            shadowColor: Colors.green.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Made with ❤️ in Nepal",
                          style: TextStyle(color: Colors.black45, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
