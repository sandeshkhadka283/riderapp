import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _numberController = TextEditingController();

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

                  // App Title
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

                  // Phone Input Field with green shadow
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade300, width: 1.5),
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

                  // WhatsApp & SMS Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/otp');
                          },
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: const Text(
                            "WhatsApp",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 5,
                            shadowColor: Colors.greenAccent.withOpacity(0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/otp');
                          },
                          icon: const Icon(Icons.sms, color: Colors.white),
                          label: const Text(
                            "SMS",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 5,
                            shadowColor: Colors.green.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Footer
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
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 13,
                          ),
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
