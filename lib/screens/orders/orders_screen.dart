import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riderapp/config/supabase_config.dart';
import 'package:riderapp/screens/orders/order_map_page.dart';
import 'order_detail_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';

// ------------------ Orders Screen ------------------

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;

  // Store all orders in one list
  List<dynamic> allOrders = [];

  @override
  void initState() {
    super.initState();
    fetchAllOrders();
  }

  Future<void> fetchAllOrders() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase.from('orders').select();

      setState(() {
        allOrders = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: AppBar(
            automaticallyImplyLeading: false,
            elevation: 8,
            shadowColor: Colors.black26,
            backgroundColor: Colors.green.shade600,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text(
                  "📦 My Orders",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTapDown: (_) => HapticFeedback.lightImpact(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrdersMapPage(orders: allOrders),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.map_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 6),
                        Text(
                          "OPEN MAPS",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                            fontSize: 13.8,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: TabBar(
                indicator: BoxDecoration(color: Colors.white),

                labelColor: Colors.green.shade700,
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.local_shipping), text: "Ongoing"),
                  Tab(icon: Icon(Icons.pending_actions), text: "Requested"),
                  Tab(
                    icon: Icon(Icons.check_circle_outline),
                    text: "Completed",
                  ),
                  Tab(icon: Icon(Icons.cancel_outlined), text: "Cancelled"),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          physics: BouncingScrollPhysics(),
          children: [
            OrdersTab(tabName: "Ongoing"),
            OrdersTab(tabName: "Requested"),
            OrdersTab(tabName: "Completed"),
            OrdersTab(tabName: "Cancelled"),
          ],
        ),
      ),
    );
  }
}

// ------------------ Orders Tab ------------------

class OrdersTab extends StatefulWidget {
  final String tabName;
  const OrdersTab({required this.tabName, super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await supabase
          .from('orders')
          .select()
          .eq('status', widget.tabName);

      debugPrint('Orders response: $response'); // <-- add this
      setState(() {
        orders = response;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      setState(() => isLoading = false);
    }
  }
  // --- Add this helper function to your _OrdersTabState class ---

  List<Map<String, dynamic>> _getSafePackages(dynamic rawPackages) {
    if (rawPackages == null) {
      return [];
    }

    if (rawPackages is List) {
      // If it's already a list, safely cast and return it
      return rawPackages.cast<Map<String, dynamic>>();
    }

    if (rawPackages is Map<String, dynamic>) {
      // If it's a single map, wrap it in a list
      return [rawPackages];
    }

    // Fallback for any unexpected data type
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: 6, // show 6 shimmer placeholders
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
              ),
              height: 180, // approximate height of your order card
            ),
          );
        },
      );
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text(
          "No orders found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        // Status color & icon
        Color statusColor;
        IconData statusIcon;

        switch (widget.tabName) {
          case "Completed":
            statusColor = Colors.green;
            statusIcon = Icons.check_circle;
            break;
          case "Ongoing":
            statusColor = Colors.blue;
            statusIcon = Icons.directions_car;
            break;
          case "Cancelled":
            statusColor = Colors.redAccent;
            statusIcon = Icons.cancel;
            break;
          default:
            statusColor = Colors.orange;
            statusIcon = Icons.schedule;
        }

        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(
                  orderNumber: order['id'].toString(),
                  status: order['status'] ?? widget.tabName,
                  pickup: order['pickup'] ?? 'Unknown pickup',
                  drop: order['drop'] ?? 'Unknown drop',
                  codAmount: "Rs ${order['cod_amount'] ?? 0}",
                  deliveryCharge: "Rs ${order['delivery_charge'] ?? 0}",
                  dateTime: order['created_at'] ?? 'N/A',
                  senderName: order['sender_name'] ?? 'N/A',
                  senderPhone: order['sender_phone'] ?? 'N/A',
                  senderAddress: order['pickup'] ?? 'Unknown pickup',
                  receiverName: order['receiver_name'] ?? 'N/A',
                  receiverPhone: order['receiver_phone'] ?? 'N/A',
                  receiverAddress: order['drop'] ?? 'Unknown drop',

                  // 🎯 FIX IS HERE: Safely extract/format the packages data
                  packages: _getSafePackages(order['packages']),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Header =====
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.25),
                        statusColor.withOpacity(0.55),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "${widget.tabName} Order #${order['id']}",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.35),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(statusIcon, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              widget.tabName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== Pickup & Drop =====
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Pickup: ${order['pickup'] ?? 'Unknown pickup'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Drop: ${order['drop'] ?? 'Unknown drop'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ===== Time / Date Section =====
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order['created_at'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== Divider =====
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  height: 1,
                  color: Colors.grey.shade200,
                ),

                // ===== Footer: COD & Button =====
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // COD Info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 20,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Rs ${order['cod_amount'] ?? 0} COD",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Details Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.redAccent, Colors.red],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.3),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailPage(
                                    orderNumber: order['id'].toString(),
                                    status: order['status'] ?? widget.tabName,
                                    pickup: order['pickup'] ?? 'Unknown pickup',
                                    drop: order['drop'] ?? 'Unknown drop',
                                    codAmount: "Rs ${order['cod_amount'] ?? 0}",
                                    deliveryCharge:
                                        "Rs ${order['delivery_charge'] ?? 0}",
                                    dateTime: order['created_at'] ?? 'N/A',
                                    senderName: order['sender_name'] ?? 'N/A',
                                    senderPhone: order['sender_phone'] ?? 'N/A',
                                    senderAddress:
                                        order['pickup'] ?? 'Unknown pickup',
                                    receiverName:
                                        order['receiver_name'] ?? 'N/A',
                                    receiverPhone:
                                        order['receiver_phone'] ?? 'N/A',
                                    receiverAddress:
                                        order['drop'] ?? 'Unknown drop',

                                    // 🎯 FIX IS HERE: Safely extract/format the packages data
                                    packages: _getSafePackages(
                                      order['packages'],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 12,
                              ),
                              child: Text(
                                "Details",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}
