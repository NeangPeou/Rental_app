import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend_rental/screens/page/owner/propertyUnit.dart';
import 'package:frontend_rental/screens/page/rental/renterPage.dart';
import 'package:frontend_rental/services/property_service.dart';
import 'package:frontend_rental/services/user_service.dart';
import 'package:get/get.dart';

import '../../../controller/property_controller.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final PropertyController propertyController = Get.find<PropertyController>();

  @override
  void initState(){
    super.initState();
    UserService().fetchRenters(context);
    PropertyService().getAllUnits();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
      body: ListView(
        children: [
          const SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120)),
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor
            ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildTopCard(
                        "", 
                        "units".tr, 
                        Colors.teal.withAlpha(50),
                        onTap: (){
                          Get.to(() => const PropertyUnit());
                        },
                        valueWidget: _blurCircle(propertyController.units.length.toString()),
                      ),
                    ), 
                  ),
                  const SizedBox(width: 1),
                  Expanded(
                    child: Obx(() => _buildTopCard(
                      "",
                      "tenants".tr,
                      Colors.teal.withAlpha(50),
                      onTap: () {
                        Get.to(() => const RenterPage());
                      },
                      valueWidget: _blurCircle(propertyController.renters.length.toString()),
                    )),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // --- Rent Collection Chart ---
          _buildSectionCard(
            "Total Rent Collection",
            "This Month",
            SizedBox(
              height: 220,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120))
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true, drawVerticalLine: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 4,
                        belowBarData: BarAreaData(
                          show: true,
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                        spots: const [
                          FlSpot(0, 1),
                          FlSpot(1, 1.5),
                          FlSpot(2, 1.4),
                          FlSpot(3, 3.4),
                          FlSpot(4, 2),
                          FlSpot(5, 2.2),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      
          const SizedBox(height: 10),
      
          // --- Rent Due Bar Chart ---
          _buildSectionCard(
            "Total Rent Due",
            "This Month",
            SizedBox(
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),
                      gridData: FlGridData(show: false),
                      barGroups: List.generate(6, (i) {
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: (i + 1) * 2.5,
                            color: theme.colorScheme.error,
                            width: 18,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ]);
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
      
          const SizedBox(height: 10),
      
          // --- Maintenance Report Pie Chart ---
          _buildSectionCard(
            "Maintenance Report",
            "",
            SizedBox(
              height: 220,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120))
                ),
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 40,
                    sectionsSpace: 4,
                    sections: [
                      PieChartSectionData(
                        value: 35,
                        color: theme.colorScheme.primary,
                        title: "35",
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 10,
                        color: Colors.orange,
                        title: "10",
                        radius: 55,
                        titleStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      PieChartSectionData(
                        value: 32,
                        color: Colors.green,
                        title: "32",
                        radius: 55,
                        titleStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      
          const SizedBox(height: 10),
      
          // --- Add Applicants Card ---
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
            },
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withAlpha(120),
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(Icons.person_add_alt, color: theme.colorScheme.primary),
                ),
                title: const Text("Add New Applicants"),
                trailing: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.secondary),
              ),
            ),
          ),
        ],
      ),

    );
  }

  // --- Top Small Cards ---
  Widget _buildTopCard(String value, String title, Color color,{VoidCallback? onTap, Widget? valueWidget}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Card(
        elevation: 4,
        shadowColor: color.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: color,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Column(
              children: [
                valueWidget ?? Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _blurCircle(String text, {double size = 25, Color color = Colors.yellow}) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Text(
            text,
            style: Get.theme.textTheme.bodyLarge
          ),
        ),
      ),
    );
  }


  // --- Section Cards with Charts ---
  Widget _buildSectionCard(String title, String subtitle, Widget child) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor.withAlpha(120)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
