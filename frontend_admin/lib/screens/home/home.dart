import 'package:flutter/material.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  final List<double> data = const [100, 200, 150, 80, 230, 180, 120];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar('Home', null),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Sales',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: data.map((value) => Bar(height: value / 2)).toList(),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SummaryCard(label: 'Total', value: '\$1060'),
                SummaryCard(label: 'Average', value: '\$151'),
              ],
            ),
            Center(
              child: TextButton(
                onPressed: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('x-auth-token', '');
                  // ignore: use_build_context_synchronously
                  Navigator.popAndPushNamed(context, '/login');
                },
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Bar extends StatelessWidget {
  final double height;

  const Bar({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: height,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;

  const SummaryCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
