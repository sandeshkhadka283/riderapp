import 'package:flutter/material.dart';
import 'package:riderapp/screens/profile_page.dart';
import 'orders/orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Mock summary data
  final int totalOrders = 120;
  final int completedOrders = 85;
  final int pendingOrders = 15;
  final int acceptedOrders = 10;
  final int cancelledOrders = 10;

  // Day-wise sample data
  final List<Map<String, dynamic>> dayWiseSummary = [
    {
      "date": "Oct 07, 2025",
      "total": 12,
      "completed": 8,
      "pending": 2,
      "accepted": 1,
      "cancelled": 1,
    },
    {
      "date": "Oct 06, 2025",
      "total": 14,
      "completed": 10,
      "pending": 3,
      "accepted": 1,
      "cancelled": 0,
    },
    {
      "date": "Oct 05, 2025",
      "total": 9,
      "completed": 7,
      "pending": 1,
      "accepted": 1,
      "cancelled": 0,
    },
  ];

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _buildHomeOverview(),
      const OrdersScreen(),
      const ProfilePage(),
    ]);
  }

  Widget _buildHomeOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "👋 Hello, Rider",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              CircleAvatar(
                backgroundColor: Colors.redAccent,
                radius: 26,
                child: const Icon(Icons.person, color: Colors.white, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Here’s your delivery summary",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 25),

          // Ride Overview
          const Text(
            "📊 Ride Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 15),
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
                totalOrders,
                Colors.deepPurpleAccent,
                Colors.purple,
              ),
              _buildStatCard(
                Icons.check_circle,
                "Completed",
                completedOrders,
                Colors.green,
                Colors.teal,
              ),
              _buildStatCard(
                Icons.access_time,
                "Pending",
                pendingOrders,
                Colors.orangeAccent,
                Colors.deepOrange,
              ),
              _buildStatCard(
                Icons.done_all,
                "Accepted",
                acceptedOrders,
                Colors.blueAccent,
                Colors.indigo,
              ),
              _buildStatCard(
                Icons.cancel,
                "Cancelled",
                cancelledOrders,
                Colors.redAccent,
                Colors.deepOrange,
              ),
              _buildStatCard(
                Icons.monetization_on,
                "Earnings",
                5500,
                Colors.teal,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Day-wise Summary
          const Text(
            "📅 Day-wise Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
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
                ...dayWiseSummary.map((day) => _buildTableRow(day)),
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
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
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
      decoration: const BoxDecoration(),
      children: [
        _TableCell(data["date"]),
        _TableCell(data["total"].toString()),
        _TableCell(
          data["completed"].toString(),
          color: Colors.green.withOpacity(0.9),
        ),
        _TableCell(
          data["pending"].toString(),
          color: Colors.orangeAccent.withOpacity(0.9),
        ),
        _TableCell(
          data["accepted"].toString(),
          color: Colors.blueAccent.withOpacity(0.9),
        ),
        _TableCell(
          data["cancelled"].toString(),
          color: Colors.redAccent.withOpacity(0.9),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String title, int count, Color startColor, Color endColor) {
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
                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(String message, String time) {
    return Container(
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
          const Icon(Icons.circle_notifications, color: Colors.redAccent, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.local_taxi), label: "Orders"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
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
