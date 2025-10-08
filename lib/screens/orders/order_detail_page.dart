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

  // Multi-select package indices
  final Set<int> selectedPackages = {};

  // Sample package list with delivery charges and COD
  final List<Map<String, dynamic>> packages = [
    {
      "id": "PKG-001",
      "name": "T-Shirt Bundle",
      "quantity": "2 pcs",
      "weight": "1.2 kg",
      "deliveryCharge": 150,
      "cod": 500,
    },
    {
      "id": "PKG-002",
      "name": "Shoes Box",
      "quantity": "1 pc",
      "weight": "2.5 kg",
      "deliveryCharge": 200,
      "cod": 1200,
    },
    {
      "id": "PKG-003",
      "name": "Accessories",
      "quantity": "3 pcs",
      "weight": "0.8 kg",
      "deliveryCharge": 100,
      "cod": 300,
    },
  ];

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

  int getTotalDeliveryCharge() {
    int total = 0;
    for (var index in selectedPackages) {
      final charge = packages[index]['deliveryCharge'];
      if (charge is int) {
        total += charge;
      } else if (charge is double)
        total += charge.toInt();
    }
    return total;
  }

  int getTotalCOD() {
    int total = 0;
    for (var index in selectedPackages) {
      final cod = packages[index]['cod'];
      if (cod is int) {
        total += cod;
      } else if (cod is double)
        total += cod.toInt();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = Colors.green;
    Color statusColor = getStatusColor();
    IconData statusIcon = getStatusIcon();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Map Placeholder
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

          // Draggable Info Sheet
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
                child: Column(
                  children: [
                    // Top draggable handle
                    Container(
                      width: 50,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Total COD & Delivery Charge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _summaryCard(
                          icon: Icons.money,
                          title: "Total COD",
                          value: "Rs ${getTotalCOD()}",
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.blue.shade600,
                            ],
                          ),
                        ),
                        _summaryCard(
                          icon: Icons.local_shipping,
                          title: "Delivery Charge",
                          value: "Rs ${getTotalDeliveryCharge()}",
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade400,
                              Colors.orange.shade600,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Receiver Info
                            _infoCard(
                              title: "Receiver Information",
                              color: themeColor,
                              children: [
                                _buildInfoRow(
                                  Icons.person,
                                  "Receiver Name",
                                  "Yogesh Mandal",
                                ),
                                _buildInfoRow(
                                  Icons.location_on,
                                  "Drop Location",
                                  widget.drop,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _actionButton(
                                      Icons.phone_outlined,
                                      "Call",
                                      Colors.green,
                                      14,
                                      () {},
                                    ),
                                    _statusChip(
                                      icon: statusIcon,
                                      label: currentStatus,
                                      color: statusColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Package Information
                            _infoCard(
                              title: "Package Information",
                              color: themeColor,
                              children: [
                                _buildInfoRow(
                                  Icons.access_time_outlined,
                                  "Date & Time",
                                  widget.dateTime,
                                ),
                                const SizedBox(height: 10),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (selectedPackages.length ==
                                            packages.length) {
                                          selectedPackages.clear();
                                        } else {
                                          selectedPackages.addAll(
                                            List.generate(
                                              packages.length,
                                              (index) => index,
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors:
                                              selectedPackages.length ==
                                                  packages.length
                                              ? [
                                                  Colors.grey.shade400,
                                                  Colors.grey.shade600,
                                                ]
                                              : [
                                                  Colors.green.shade400,
                                                  Colors.green.shade700,
                                                ],
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            selectedPackages.length ==
                                                    packages.length
                                                ? Icons.clear_all
                                                : Icons.select_all,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            selectedPackages.length ==
                                                    packages.length
                                                ? "Deselect All"
                                                : "Select All",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                const Text(
                                  "Packages:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: packages.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final pkg = packages[index];
                                    final bool isSelected = selectedPackages
                                        .contains(index);

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedPackages.remove(index);
                                          } else {
                                            selectedPackages.add(index);
                                          }
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.green.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: isSelected
                                              ? Border.all(
                                                  color: Colors.green.shade700,
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Checkbox(
                                              value: isSelected,
                                              activeColor:
                                                  Colors.green.shade700,
                                              onChanged: (val) {
                                                setState(() {
                                                  if (val == true) {
                                                    selectedPackages.add(index);
                                                  } else {
                                                    selectedPackages.remove(
                                                      index,
                                                    );
                                                  }
                                                });
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    pkg["name"]!,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "ID: ${pkg["id"]} | Qty: ${pkg["quantity"]} | ${pkg["weight"]} | Delivery: Rs ${pkg["deliveryCharge"]} | COD: Rs ${pkg["cod"]}",
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Sender Info
                            _infoCard(
                              title: "Sender Information",
                              color: themeColor,
                              children: [
                                _buildInfoRow(
                                  Icons.person_outline,
                                  "Sender Name",
                                  "Spring Is Green",
                                ),
                                _buildInfoRow(
                                  Icons.phone_outlined,
                                  "Phone",
                                  "+977 9706243317",
                                ),
                                _buildInfoRow(
                                  Icons.location_on_outlined,
                                  "Address",
                                  widget.pickup,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Single improved View Map button
                            _roundedButton(
                              icon: Icons.done_all,
                              label: "Complete",
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(255, 0, 143, 36),
                                  const Color.fromARGB(255, 45, 88, 36),
                                ],
                              ),
                              onTap: () {},
                            ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _roundedButton(
                                  icon: Icons.keyboard_return,
                                  label: "Return",
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color.fromARGB(255, 155, 72, 34),
                                      const Color.fromARGB(255, 229, 30, 30),
                                    ],
                                  ),
                                  onTap: () {},
                                ),

                                _roundedButton(
                                  icon: Icons.transfer_within_a_station,
                                  label: "Transfer",
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color.fromARGB(255, 119, 121, 0),
                                      const Color.fromARGB(255, 177, 159, 0),
                                    ],
                                  ),
                                  onTap: () {},
                                ),
                                _roundedButton(
                                  icon: Icons.map_sharp,
                                  label: "View Map",
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade400,
                                      const Color.fromARGB(255, 0, 41, 77),
                                    ],
                                  ),
                                  onTap: () {},
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------- NEW HELPER WIDGETS ----------

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Gradient gradient,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.7), color]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundedButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- KEEP YOUR EXISTING _infoCard, _buildInfoRow, _actionButton ----------
  Widget _infoCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.green, size: 20),
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
                const SizedBox(height: 2),
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
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    Color color,
    double padding,
    VoidCallback onPressed,
  ) {
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
