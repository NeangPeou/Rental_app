import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/dashboard.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/notification_page.dart';
import 'package:frontend_admin/screens/bottomNavigationBar/setting.dart';
import 'package:frontend_admin/utils/helper.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

const Color kActiveIconColor = Colors.white;
const Color kInActiveIconColor = Colors.white70;

Icon buildIcon(IconData iconData, bool isActive) {
  return Icon(
    iconData,
    color: isActive ? kActiveIconColor : kInActiveIconColor,
  );
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final NotchBottomBarController _controller =
      NotchBottomBarController(index: 0);

  double _bottomBarOpacity = 1.0;
  Offset _bottomBarOffset = Offset.zero; // slide position

  final List<Widget> _pages = [
    Dashboard(),
    Scaffold(
        body: ListView.builder(
      itemCount: 30,
      itemBuilder: (_, index) =>
          ListTile(title: Text('Order item $index')),
    )),
    NotificationPage(),
    Setting(),
  ];

  final List<String> _titles = [
    'Home',
    'Orders',
    'Notifications',
    'Setting',
  ];

  void _handleScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        // Hide: fade out + slide down
        if (_bottomBarOpacity != 0.0) {
          setState(() {
            _bottomBarOpacity = 0.0;
            _bottomBarOffset = const Offset(0, 1); // move down
          });
        }
      } else if (notification.direction == ScrollDirection.forward) {
        // Show: fade in + slide up
        if (_bottomBarOpacity != 1.0) {
          setState(() {
            _bottomBarOpacity = 1.0;
            _bottomBarOffset = Offset.zero; // back to normal
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Helper.sampleAppBar(_titles[_controller.index], context, null),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          _handleScroll(scroll);
          return false;
        },
        child: _pages[_controller.index],
      ),
      extendBody: true,
      bottomNavigationBar: AnimatedSlide(
        offset: _bottomBarOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _bottomBarOpacity,
          duration: const Duration(milliseconds: 250),
          child: SafeArea(
            bottom: false,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: AnimatedNotchBottomBar(
                      notchBottomBarController: _controller,
                      color: Colors.teal,
                      showLabel: true,
                      notchColor: Colors.amber.withOpacity(0.7),
                      removeMargins: false,
                      bottomBarWidth: MediaQuery.of(context).size.width,
                      durationInMilliSeconds: 300,
                      kIconSize: 24.0,
                      kBottomRadius: 16.0,
                      itemLabelStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      bottomBarItems: [
                        BottomBarItem(
                          inActiveItem: buildIcon(Icons.home, false),
                          activeItem: buildIcon(Icons.home, true),
                          itemLabel: 'Home',
                        ),
                        BottomBarItem(
                          inActiveItem: buildIcon(Icons.list_alt, false),
                          activeItem: buildIcon(Icons.list_alt, true),
                          itemLabel: 'Orders',
                        ),
                        BottomBarItem(
                          inActiveItem:
                              buildIcon(Icons.notifications_active, false),
                          activeItem:
                              buildIcon(Icons.notifications_active, true),
                          itemLabel: 'Notifications',
                        ),
                        BottomBarItem(
                          inActiveItem: buildIcon(Icons.settings, false),
                          activeItem: buildIcon(Icons.settings, true),
                          itemLabel: 'Setting',
                        ),
                      ],
                      onTap: (index) {
                        setState(() {
                          _controller.index = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
