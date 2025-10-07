import 'package:flutter/material.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          "OTP Verification",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔒 Icon with green theme
            Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(20),
              child: const Icon(
                Icons.lock_outline,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            // Instruction Text
            const Text(
              "Enter the 6-digit verification code",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "We’ve sent an OTP to your registered phone number.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            // OTP Input
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: "",
                hintText: "••••••",
                hintStyle: TextStyle(
                  letterSpacing: 8,
                  color: Colors.grey[400],
                  fontSize: 24,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.green, width: 2),
                ),
              ),
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 36),

            // Verify Button with green theme
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: Colors.green.withOpacity(0.4),
                ),
                child: const Text(
                  "Verify & Continue",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Resend OTP
            TextButton(
              onPressed: () {
                // Resend OTP logic
              },
              child: const Text(
                "Didn’t receive the code? Resend",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
