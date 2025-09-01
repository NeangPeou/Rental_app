import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopCard("15", "Total Buildings", Colors.orange),
                  _buildTopCard("15", "Total Apartments", Colors.purple),
                  _buildTopCard("15", "Total Tenants", Colors.blue),
                ],
              ),
              const SizedBox(height: 16),
          
              _buildSectionCard(
                "Total Rent Collection",
                "This Month",
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          spots: [
                            const FlSpot(0, 1),
                            const FlSpot(1, 1.5),
                            const FlSpot(2, 1.4),
                            const FlSpot(3, 3.4),
                            const FlSpot(4, 2),
                            const FlSpot(5, 2.2),
                          ],
                        ),
                        LineChartBarData(
                          isCurved: true,
                          color: theme.colorScheme.error,
                          spots: [
                            const FlSpot(0, 1),
                            const FlSpot(1, 2.8),
                            const FlSpot(2, 1.2),
                            const FlSpot(3, 2.8),
                            const FlSpot(4, 2.6),
                            const FlSpot(5, 3.9),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
          
              _buildSectionCard(
                "Total Rent Due",
                "This Month",
                SizedBox(
                  height: 180,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),
                      gridData: FlGridData(show: false),
                      barGroups: List.generate(6, (i) {
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: (i + 1) * 2.0,
                            color: theme.colorScheme.error,
                            width: 16,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ]);
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
          
              _buildSectionCard(
                "Maintenance Report",
                "",
                SizedBox(
                  height: 180,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 35,
                          color: theme.colorScheme.primary,
                          title: "Total",
                          radius: 50,
                          titleStyle: const TextStyle(color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: 10,
                          color: Colors.orange,
                          title: "Pending",
                          radius: 50,
                          titleStyle: const TextStyle(color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: 32,
                          color: Colors.green,
                          title: "Approved",
                          radius: 50,
                          titleStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
          
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(Icons.apartment, color: theme.colorScheme.primary),
                  title: const Text("Add New Applicants"),
                  trailing: Icon(Icons.arrow_forward_ios,
                      color: theme.colorScheme.secondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard(String value, String title, Color color) {
    return Expanded(
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, String subtitle, Widget child) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.bold)),
                if (subtitle.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subtitle,
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
