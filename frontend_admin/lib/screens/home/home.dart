import 'package:flutter/material.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> orders = [
    {
      "car": "Toyota Camry",
      "user": "Jonn Doe",
      "date": "Apr 12 – Apr 15",
      "status": "Completed",
      "statusColor": Colors.green,
      "image": "assets/images/facebook.png"
    },
    {
      "car": "Honda Civic",
      "user": "Jane Smith",
      "date": "Apr 10 – Apr 12",
      "status": "Completed",
      "statusColor": Colors.green,
      "image": "assets/images/city.png"
    },
    {
      "car": "Ford Explorer",
      "user": "Michael Brown",
      "date": "Apr 05 – Apr 10",
      "status": "Ongoing",
      "statusColor": Colors.blue,
      "image": "assets/images/google.png"
    },
    {
      "car": "BMW 3 Series",
      "user": "Emily Wilson",
      "date": "Apr 01 – Apr 04",
      "status": "Completed",
      "statusColor": Colors.green,
      "image": "assets/images/apple.png"
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildSummaryCard(String title, String value, [String? subtitle, Color? valueColor]) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black)),
          if (subtitle != null)
            Text(subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.green)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      // Home Tab
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text("Admin Rental",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // Top Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildSummaryCard("Total Revenue", "\$8,250", "+15,2% this month", Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard("Cars", "120", "85 rented"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard("Customers", "1,340", "120 new this month"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black87,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Revenue Chart",
                            style: TextStyle(color: Colors.white)),
                        Expanded(
                          child: Center(
                            child: Text("\$ Chart",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 16)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text("Recent Orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...orders.map((order) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(order['image']),
                      radius: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order['car'],
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(order['user'],
                              style: const TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(order['date'],
                            style: const TextStyle(fontSize: 13)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: order['statusColor'].withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(order['status'],
                              style: TextStyle(
                                  fontSize: 12,
                                  color: order['statusColor'],
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
            // Logout button
                Center(
                  child: TextButton(
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('x-auth-token', '');
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
          ],
        ),
      ),

      // Orders Tab
      const Center(child: Text("Orders Page")),
      const Center(child: Text("Cars Page")),
      const Center(child: Text("Customers Page")),
    ];

    return Scaffold(
      appBar: Helper.sampleAppBar('Home', null),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Cars"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Customers"),
        ],
      ),
    );
  }
}
