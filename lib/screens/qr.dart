import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riderapp/screens/orders/order_detail_page.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: false);

    // Simulate scanning delay of 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => OrderDetailPage(
        //       orderNumber: order['id'].toString(),
        //       status: order['status'] ?? widget.tabName,
        //       pickup: order['pickup'] ?? 'Unknown pickup',
        //       drop: order['drop'] ?? 'Unknown drop',
        //       codAmount: "Rs ${order['cod_amount'] ?? 0}",
        //       deliveryCharge: "Rs ${order['delivery_charge'] ?? 0}",
        //       dateTime: order['created_at'] ?? 'N/A',
        //       senderName: order['sender_name'] ?? 'N/A',
        //       senderPhone: order['sender_phone'] ?? 'N/A',
        //       senderAddress: order['pickup'] ?? 'Unknown pickup',
        //       receiverName: order['receiver_name'] ?? 'N/A',
        //       receiverPhone: order['receiver_phone'] ?? 'N/A',
        //       receiverAddress: order['drop'] ?? 'Unknown drop',
        //       packages: List<Map<String, dynamic>>.from(
        //         order['packages'] ?? [],
        //       ),
        //     ),
        //   ),
        // );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(Barcode barcode) {
    if (_isProcessing) return;
    final code = barcode.rawValue;
    if (code != null) {
      _isProcessing = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailScreen(orderId: code),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanSize = 280.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: cameraController,
            fit: BoxFit.cover,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                _handleBarcode(barcode);
              }
            },
          ),

          // Subtle glassmorphism overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              backgroundBlendMode: BlendMode.darken,
            ),
          ),

          // Centered scan box
          Center(
            child: Container(
              width: scanSize,
              height: scanSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
                color: Colors.black.withOpacity(0.2),
              ),
              child: Stack(
                children: [
                  // Smooth moving scan line
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Positioned(
                        top: scanSize * _animationController.value,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.redAccent.withOpacity(0.8),
                                Colors.redAccent.withOpacity(0.4),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    },
                  ),

                  // Elegant corners
                  _corner(0, 0, true, true),
                  _corner(0, scanSize, true, false),
                  _corner(scanSize, 0, false, true),
                  _corner(scanSize, scanSize, false, false),
                ],
              ),
            ),
          ),

          // Floating instruction text
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Text(
              "Align the QR code inside the frame",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    blurRadius: 6,
                    color: Colors.redAccent.withOpacity(0.7),
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),

          // Flash toggle
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 28),
              onPressed: () => cameraController.toggleTorch(),
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // Minimal corners for clean aesthetics
  Widget _corner(double x, double y, bool top, bool left) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: Colors.redAccent, width: 3)
                : BorderSide.none,
            left: left
                ? const BorderSide(color: Colors.redAccent, width: 3)
                : BorderSide.none,
            bottom: !top
                ? const BorderSide(color: Colors.redAccent, width: 3)
                : BorderSide.none,
            right: !left
                ? const BorderSide(color: Colors.redAccent, width: 3)
                : BorderSide.none,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Text(
          "Details for Order: $orderId",
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
