import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
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

  Widget _buildSummaryCard(String title, String value, [String? subtitle, Color? valueColor]) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
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
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';
    
    // Call backend logout endpoint
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/api/logout'), // Replace with your API URL
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed. Please try again.')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout. Please try again.')),
      );
      return;
    }

    // Clear token and navigate to login
    await prefs.setString('x-auth-token', '');
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text("Admin Rental", style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.amber)),
          ),
          const SizedBox(height: 20),

          // Summary cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSummaryCard("Total Revenue", "\$8,250", "+15.2% this month", Colors.green),
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
                    color: Theme.of(context).cardColor,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Revenue Chart", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green)),
                      const Expanded(
                        child: Center(
                          child: Text("\$ Chart"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text("Recent Orders", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        Text(order['car'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(order['user'], style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(order['date'], style: const TextStyle(fontSize: 13)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: order['statusColor'].withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order['status'],
                          style: TextStyle(
                            fontSize: 12,
                            color: order['statusColor'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),

          const SizedBox(height: 24),
          Center(
            child: TextButton(
              // onPressed: () async {
              //   SharedPreferences prefs = await SharedPreferences.getInstance();
              //   await prefs.setString('x-auth-token', '');
              //   if (context.mounted) {
              //     Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              //   }
              // },
              onPressed: _logout,
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
