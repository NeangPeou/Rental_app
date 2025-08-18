import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<Map<String, dynamic>> orders = [
    {
      "car": "Luxury Villa",
      "user": "John Doe",
      "date": "Aug 01 – Aug 05",
      "status": "Completed",
      "statusColor": Colors.green,
      "image": "assets/images/house.png"
    },
    {
      "car": "Beach Condo",
      "user": "Jane Smith",
      "date": "Aug 02 – Aug 06",
      "status": "Ongoing",
      "statusColor": Colors.blue,
      "image": "assets/images/condo.png"
    },
    {
      "car": "City Apartment",
      "user": "Michael Brown",
      "date": "Aug 03 – Aug 07",
      "status": "Completed",
      "statusColor": Colors.green,
      "image": "assets/images/apartment.png"
    },
  ];

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Dashboard",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Stats Row
            Row(
              children: [
                _buildStatCard("Properties", "15", Icons.home),
                const SizedBox(width: 12),
                _buildStatCard("Bookings", "03", Icons.calendar_month),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard("Requests", "02", Icons.message),
                const SizedBox(width: 12),
                _buildStatCard("Users", "10", Icons.person),
              ],
            ),

            const SizedBox(height: 24),
            Text("Recent Orders",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ...orders.map((order) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                          Text(order['user'],
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(order['date'],
                            style: Theme.of(context).textTheme.bodySmall),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
          ],
        ),
      ),
    );
  }
}
