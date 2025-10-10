import 'package:flutter/material.dart';
import 'package:riderapp/screens/orders/order_detail_page.dart';

class OrdersMapPage extends StatefulWidget {
  final List<dynamic> orders; // receive orders from parent
  const OrdersMapPage({super.key, required this.orders});

  @override
  State<OrdersMapPage> createState() => _OrdersMapPageState();
}

class _OrdersMapPageState extends State<OrdersMapPage> {
  final PageController _pageController = PageController(viewportFraction: 0.82);
  int _currentPage = 0;

  int get _totalOrders => widget.orders.length; // dynamic based on parent list

  void _nextPage() {
    if (_currentPage < _totalOrders - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map placeholder
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.map, size: 120, color: Colors.grey),
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
              title: const Text(
                "Ongoing Orders Map",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black87),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.38,
            minChildSize: 0.28,
            maxChildSize: 0.65,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.97),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        width: 60,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const Text(
                      "Ongoing Orders",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Horizontal PageView
                    SizedBox(
                      height: 230,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PageView.builder(
                            controller: _pageController,
                            itemCount: _totalOrders,
                            onPageChanged: (index) =>
                                setState(() => _currentPage = index),
                            itemBuilder: (context, index) {
                              final order =
                                  widget.orders[index]; // dynamic order
                              double scale = _currentPage == index ? 1 : 0.95;
                              return TweenAnimationBuilder(
                                duration: const Duration(milliseconds: 350),
                                tween: Tween<double>(begin: scale, end: scale),
                                builder: (context, double value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 6,
                                    shadowColor: Colors.black26,
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Name + Order + Call Section
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        order['receiver_name'] ??
                                                            'Unknown',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Colors.grey[900],
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        "Order #${order['id'] ?? 'N/A'}",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Call button
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                      Icons.call,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      // TODO: implement call functionality
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Pickup & Drop Section
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade200,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.my_location,
                                                      size: 18,
                                                      color: Colors.blueAccent,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        order['pickup'] ??
                                                            'Unknown pickup',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on,
                                                      size: 18,
                                                      color: Colors.redAccent,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        order['drop'] ??
                                                            'Unknown drop',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.grey[700],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          const Spacer(),

                                          // COD badge + Show Details
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => OrderDetailPage(
                                                        orderNumber: order['id']
                                                            .toString(),
                                                        status:
                                                            order['status'] ??
                                                            "TABNAME",
                                                        pickup:
                                                            order['pickup'] ??
                                                            'Unknown pickup',
                                                        drop:
                                                            order['drop'] ??
                                                            'Unknown drop',
                                                        codAmount:
                                                            "Rs ${order['cod_amount'] ?? 0}",
                                                        deliveryCharge:
                                                            "Rs ${order['delivery_charge'] ?? 0}",
                                                        dateTime:
                                                            order['created_at'] ??
                                                            'N/A',
                                                        senderName:
                                                            order['sender_name'] ??
                                                            'N/A',
                                                        senderPhone:
                                                            order['sender_phone'] ??
                                                            'N/A',
                                                        senderAddress:
                                                            order['pickup'] ??
                                                            'Unknown pickup',
                                                        receiverName:
                                                            order['receiver_name'] ??
                                                            'N/A',
                                                        receiverPhone:
                                                            order['receiver_phone'] ??
                                                            'N/A',
                                                        receiverAddress:
                                                            order['drop'] ??
                                                            'Unknown drop',
                                                        packages:
                                                            List<
                                                              Map<
                                                                String,
                                                                dynamic
                                                              >
                                                            >.from(
                                                              order['packages'] ??
                                                                  [],
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 6,
                                                      ),
                                                ),
                                                child: const Text(
                                                  "Show Details",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 12,
                                                    ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.redAccent.shade100,
                                                      Colors.redAccent.shade400,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  "Rs ${order['cod_amount'] ?? 0} COD",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Left navigation
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.85),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  size: 18,
                                ),
                                color: Colors.black54,
                                onPressed: _previousPage,
                              ),
                            ),
                          ),

                          // Right navigation
                          Positioned(
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.85),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                ),
                                color: Colors.black54,
                                onPressed: _nextPage,
                              ),
                            ),
                          ),

                          // Dots indicator
                          Positioned(
                            bottom: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_totalOrders, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: _currentPage == index ? 14 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _currentPage == index
                                        ? Colors.redAccent
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
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
}
