import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class EarningsDashboardPage extends StatelessWidget {
  const EarningsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final earningsData = [
      {"shop": "Spring Is Green", "orders": 45, "amount": 18190},
      {"shop": "Tech World", "orders": 20, "amount": 8000},
      {"shop": "Nepal Mart", "orders": 15, "amount": 6200},
      {"shop": "Quick Deliveries", "orders": 10, "amount": 4000},
    ];

    final totalEarnings = earningsData.fold<int>(
        0, (sum, item) => sum + (item["amount"] as int));
    final totalOrders = earningsData.fold<int>(
        0, (sum, item) => sum + (item["orders"] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          "💰 Earnings Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "This Month's Earnings",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rs $totalEarnings",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _summaryChip(
                          Icons.store, "Stores", earningsData.length.toString()),
                      _summaryChip(Icons.local_shipping, "Orders", totalOrders.toString()),
                      _summaryChip(Icons.trending_up, "Avg/Store",
                          "Rs ${(totalEarnings ~/ earningsData.length)}"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Earnings Bar Chart
            const Text(
              "Earnings Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final shop = earningsData[value.toInt()]["shop"] as String;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              shop.split(" ").first,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: earningsData
                      .asMap()
                      .entries
                      .map(
                        (e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: (e.value["amount"] as int).toDouble(),
                              gradient: const LinearGradient(
                                  colors: [Colors.green, Colors.teal],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Rich Store Cards
            const Text(
              "Earnings by Store",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...earningsData.map((item) {
              double percent = (item["amount"] as int) / totalEarnings * 100;
              return _buildRichStoreCard(item, percent);
            }).toList(),

            const SizedBox(height: 16),

            // Total Earnings Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                "Total Earnings: Rs $totalEarnings",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRichStoreCard(Map<String, dynamic> item, double percent) {
    final amount = item["amount"] as int;
    final shop = item["shop"] as String;
    final orders = item["orders"] as int;
    final avgOrder = (amount / orders).toStringAsFixed(0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.storefront, color: Colors.green, size: 28),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text("Orders: $orders",
                      style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6)),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 10,
                width: percent * 2,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                        colors: [Colors.green, Colors.teal])),
              )
            ],
          ),
          const SizedBox(height: 6),
          Text("${percent.toStringAsFixed(1)}% of total earnings",
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 14),

          // Attribute Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _attributeChip(Icons.monetization_on, "Rs $amount"),
              _attributeChip(Icons.shopping_bag, "$orders Orders"),
              _attributeChip(Icons.trending_up, "Rs $avgOrder Avg/Order"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attributeChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 16),
          const SizedBox(width: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
