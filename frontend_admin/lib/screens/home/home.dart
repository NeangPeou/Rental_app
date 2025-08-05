import 'package:flutter/material.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/dashboard.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting.dart';
import 'package:frontend_admin/utils/helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      Dashboard(),
      Center(child: Text('Orders Page')),      // placeholder
      Center(child: Text('Cars Page')),        // placeholder
      Setting(),
    ];

    final List<String> titles = [
      'Home', 'Orders', 'Cars', 'Setting',
    ];

    return Scaffold(
      appBar: Helper.sampleAppBar(titles[_selectedIndex], context, null),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Cars"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
        ],
      ),
    );
  }
}
