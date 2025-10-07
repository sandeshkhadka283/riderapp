import 'package:flutter/material.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderNumber;
  final String status;
  final String pickup;
  final String drop;
  final String codAmount;
  final String dateTime;

  const OrderDetailPage({
    required this.orderNumber,
    required this.status,
    required this.pickup,
    required this.drop,
    required this.codAmount,
    required this.dateTime,
    super.key,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
  }

  Color getStatusColor() {
    switch (currentStatus) {
      case "Completed":
        return Colors.green;
      case "Ongoing":
        return Colors.blue;
      case "Cancelled":
        return Colors.redAccent;
      case "Returns":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon() {
    switch (currentStatus) {
      case "Completed":
        return Icons.check_circle_outline;
      case "Ongoing":
        return Icons.directions_car_outlined;
      case "Cancelled":
        return Icons.cancel_outlined;
      case "Returns":
        return Icons.undo_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = getStatusColor();
    IconData statusIcon = getStatusIcon();

    return Scaffold(
      body: Stack(
        children: [
          // Map background
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.map, size: 100, color: Colors.grey),
            ),
          ),

          // Transparent AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "Order #${widget.orderNumber}",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black87),
            ),
          ),

          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Status: ",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: currentStatus,
                            items: <String>[
                              "Ongoing",
                              "Completed",
                              "Cancelled",
                              "Returns"
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  currentStatus = newValue;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                statusColor.withOpacity(0.7),
                                statusColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                currentStatus,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Info Card
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black26,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildInfoRow(Icons.calendar_today_outlined,
                                  "Date & Time", widget.dateTime),
                              const Divider(height: 24),
                              _buildInfoRow(
                                  Icons.my_location, "Pickup", widget.pickup),
                              const Divider(height: 24),
                              _buildInfoRow(
                                  Icons.location_on, "Drop", widget.drop),
                              const Divider(height: 24),
                              _buildInfoRow(Icons.attach_money, "COD Amount",
                                  widget.codAmount),
                              const Divider(height: 24),
                              _buildInfoRow(
                                  Icons.person_outline, "Rider Name",
                                  "Yogesh Mandal"),
                              const Divider(height: 24),
                              _buildInfoRow(
                                  Icons.phone_outlined, "Contact",
                                  "+977 980xxxxxxx"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _actionButton(Icons.chat_bubble_outline, "Chat",
                              Colors.blueAccent, 14, () {}),
                          _actionButton(Icons.phone_outlined, "Call",
                              Colors.green, 14, () {}),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // View Map Button
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.map_outlined, color: Colors.white),
                        label: const Text("View Map",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.redAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color color, double padding, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: padding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }
}
