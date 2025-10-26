import 'package:flutter/material.dart';
import 'package:riderapp/screens/earnings_dashboard_page.dart';
import 'package:riderapp/screens/profile_page.dart';
import 'package:riderapp/screens/qr.dart';
import 'package:riderapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'orders/orders_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  List<dynamic> allOrders = [];
  bool isVerified = false;
  bool _hasShownDialog = false; // to prevent multiple dialogs per launch

  @override
  void initState() {
    super.initState();
    _checkVerification();
    fetchAllOrders();
  }

  Future<void> _checkVerification() async {
    final prefs = await SharedPreferences.getInstance();
    isVerified = prefs.getBool('isVerified') ?? false;

    if (!isVerified && !_hasShownDialog && mounted) {
      _hasShownDialog = true;
      _showNotVerifiedDialog();
    }

    setState(() {}); // update UI for FloatingActionButton
  }

  Future<void> _loadVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isVerified = prefs.getBool('isVerified') ?? false;

    if (!isVerified) {
      _showNotVerifiedDialog();
    }

    setState(() {});
  }

  void _showNotVerifiedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // cannot dismiss
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false, // disable back button
          child: AlertDialog(
            title: const Text("🚫 Not Verified"),
            content: const Text(
              "Your account/license is not verified. Please verify to continue using the app.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
                child: const Text("Go to Profile"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> fetchAllOrders() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase.from('orders').select();

      setState(() {
        allOrders = response;
        isLoading = false;
      });

      // ✅ Print summary and classify data
      debugPrint("==== DATA FETCHED ====");
      debugPrint("Total Orders: ${allOrders.length}");

      classifyOrders(allOrders.cast<Map<String, dynamic>>());
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      setState(() => isLoading = false);
    }
  }

  // --- Summary calculations ---
  int get totalOrders => allOrders.length;
  int get completedOrders => allOrders
      .where(
        (o) =>
            o['status']?.toString().toLowerCase().contains('completed') ??
            false,
      )
      .length;

  int get pendingOrders => allOrders
      .where(
        (o) =>
            o['status']?.toString().toLowerCase().contains('requested') ??
            false,
      )
      .length;

  int get acceptedOrders => allOrders
      .where(
        (o) =>
            o['status']?.toString().toLowerCase().contains('ongoing') ?? false,
      )
      .length;

  int get cancelledOrders => allOrders
      .where(
        (o) =>
            o['status']?.toString().toLowerCase().contains('cancelled') ??
            false,
      )
      .length;

  List<Map<String, dynamic>> getDayWiseSummary() {
    final Map<String, Map<String, dynamic>> summary = {};

    for (var order in allOrders) {
      final createdAt = order['created_at']?.toString() ?? '';
      final date = createdAt.isNotEmpty
          ? createdAt.split('T').first
          : 'Unknown';

      if (!summary.containsKey(date)) {
        summary[date] = {
          "date": date,
          "total": 0,
          "completed": 0,
          "pending": 0,
          "accepted": 0,
          "cancelled": 0,
        };
      }

      summary[date]!['total'] = summary[date]!['total'] + 1;

      final status = order['status']?.toString().toLowerCase() ?? 'unknown';

      if (status.contains('completed')) {
        summary[date]!['completed']++;
      } else if (status.contains('requested')) {
        summary[date]!['pending']++;
      } else if (status.contains('ongoing')) {
        summary[date]!['accepted']++;
      } else if (status.contains('cancelled')) {
        summary[date]!['cancelled']++;
      }
    }

    final sorted = summary.values.toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));
    return sorted;
  }

  // ✅ Classification logic (COD, Delivery, etc.)
  void classifyOrders(List<Map<String, dynamic>> orders) {
    print("==== RAW ORDERS ====");
    for (var order in orders) {
      print(order);
    }

    int totalOrders = orders.length;

    int completed = 0;
    int pending = 0;
    int accepted = 0;
    int cancelled = 0;

    double totalCOD = 0;
    double completedCOD = 0;
    double pendingCOD = 0;
    double acceptedCOD = 0;
    double cancelledCOD = 0;
    double totalDeliveryCharge = 0;

    for (var order in orders) {
      final status = (order['status'] ?? '').toString().toLowerCase();
      final cod =
          double.tryParse(order['cod_amount']?.toString() ?? '0') ?? 0.0;
      final deliveryCharge =
          double.tryParse(order['delivery_charge']?.toString() ?? '0') ?? 0.0;

      totalCOD += cod;
      totalDeliveryCharge += deliveryCharge;

      if (status.contains('completed')) {
        completed++;
        completedCOD += cod;
      } else if (status.contains('pending') || status.contains('requested')) {
        pending++;
        pendingCOD += cod;
      } else if (status.contains('accepted') || status.contains('ongoing')) {
        accepted++;
        acceptedCOD += cod;
      } else if (status.contains('cancelled')) {
        cancelled++;
        cancelledCOD += cod;
      }
    }

    print("==== SUMMARY ====");
    print("Total Orders: $totalOrders");
    print("Completed Orders: $completed (COD: Rs $completedCOD)");
    print("Pending Orders: $pending (COD: Rs $pendingCOD)");
    print("Accepted Orders: $accepted (COD: Rs $acceptedCOD)");
    print("Cancelled Orders: $cancelled (COD: Rs $cancelledCOD)");
    print("Total COD: Rs $totalCOD");
    print("Total Delivery Charge: Rs $totalDeliveryCharge");
  }

  // --- UI ---
  Widget _buildHomeOverview() {
    if (isLoading) return _buildShimmerOverview();

    final dayWiseSummary = getDayWiseSummary();

    // Calculate earnings (you can change logic here)
    double totalCOD = 0;
    double totalDeliveryCharge = 0;

    for (var order in allOrders) {
      totalCOD += (order['cod_amount'] ?? 0).toDouble();
      totalDeliveryCharge += (order['delivery_charge'] ?? 0).toDouble();
    }

    double totalEarnings = totalCOD + totalDeliveryCharge;

    debugPrint(
      "💰 Total COD: $totalCOD, Delivery Charge: $totalDeliveryCharge, Earnings: $totalEarnings",
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                Icons.list_alt,
                "Total Orders",
                "${completedOrders}",

                totalOrders,

                Colors.deepPurpleAccent,
                Colors.purple,
              ),
              _buildStatCard(
                Icons.check_circle,
                "Completed",
                "${completedOrders}",

                completedOrders,
                Colors.green,
                Colors.teal,
              ),
              _buildStatCard(
                Icons.access_time,
                "Pending",
                "${completedOrders}",

                pendingOrders,

                Colors.orangeAccent,
                Colors.deepOrange,
              ),
              _buildStatCard(
                Icons.done_all,
                "Accepted",
                "${completedOrders}",

                acceptedOrders,
                Colors.blueAccent,
                Colors.indigo,
              ),
              _buildStatCard(
                Icons.cancel,
                "Cancelled",
                "${completedOrders}",

                cancelledOrders,
                Colors.redAccent,
                Colors.deepOrange,
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EarningsDashboardPage(),
                  ),
                ),
                child: _buildStatCard(
                  Icons.monetization_on,
                  "Earnings",
                  "${completedOrders}",
                  totalEarnings.toInt(), // 👈 dynamic value now
                  Colors.teal,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Day-wise Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Table(
              border: TableBorder.symmetric(
                inside: BorderSide(color: Colors.grey.shade200),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
                4: FlexColumnWidth(1.5),
                5: FlexColumnWidth(1.5),
              },
              children: [
                _buildTableHeader(),
                ...dayWiseSummary.map(_buildTableRow),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Recent Activities
          const Text(
            "🕒 Recent Activities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildActivityTile("New request from Yogesh", "2 min ago"),
              _buildActivityTile("Order #302 completed", "10 min ago"),
              _buildActivityTile("Payment received: Rs 1619", "1 hour ago"),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1)),
      children: const [
        _TableCell("Date", bold: true),
        _TableCell("Total", bold: true),
        _TableCell("Completed", bold: true),
        _TableCell("Pending", bold: true),
        _TableCell("Accepted", bold: true),
        _TableCell("Cancelled", bold: true),
      ],
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> data) {
    return TableRow(
      children: [
        _TableCell(data["date"] ?? "Unknown"),
        _TableCell((data["total"] ?? 0).toString()),
        _TableCell(
          (data["completed"] ?? 0).toString(),
          color: Colors.green.withOpacity(0.9),
        ),
        _TableCell(
          (data["pending"] ?? 0).toString(),
          color: Colors.orangeAccent.withOpacity(0.9),
        ),
        _TableCell(
          (data["accepted"] ?? 0).toString(),
          color: Colors.blueAccent.withOpacity(0.9),
        ),
        _TableCell(
          (data["cancelled"] ?? 0).toString(),
          color: Colors.redAccent.withOpacity(0.9),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String COD,
    int count,
    Color startColor,
    Color endColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor.withOpacity(0.9), endColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  COD,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(String message, String time) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.circle_notifications,
              color: Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeOverview(),
      const OrdersScreen(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      floatingActionButton: (_selectedIndex == 0 && isVerified)
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScannerScreen()),
              ),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              child: const Icon(Icons.qr_code_scanner, size: 28),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: "Orders",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// TableCell Widget
class _TableCell extends StatelessWidget {
  final String text;
  final bool bold;
  final Color? color;
  const _TableCell(this.text, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
          color: color ?? Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ✅ Shimmer Loading View
Widget _buildShimmerOverview() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: List.generate(
            6,
            (index) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Column(
          children: List.generate(
            5,
            (index) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Column(
          children: List.generate(
            3,
            (index) => Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
