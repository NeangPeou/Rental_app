import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sw_rental/screens/bottomNavigationBar/dashboard.dart';
import 'package:sw_rental/screens/bottomNavigationBar/notification_page.dart';
import 'package:sw_rental/screens/bottomNavigationBar/setting.dart';
import 'package:sw_rental/screens/bottomNavigationBar/userForm/user_form.dart';
import 'package:sw_rental/utils/helper.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  double _bottomBarOpacity = 1.0;
  Offset _bottomBarOffset = Offset.zero;

  void _handleScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse) {
        if (_bottomBarOpacity != 0.0) {
          setState(() {
            _bottomBarOpacity = 0.0;
            _bottomBarOffset = const Offset(0, 1); 
          });
        }
      } else if (notification.direction == ScrollDirection.forward) {
        if (_bottomBarOpacity != 1.0) {
          setState(() {
            _bottomBarOpacity = 1.0;
            _bottomBarOffset = Offset.zero;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color kActiveIconColor = Colors.white;
    const Color kInActiveIconColor = Colors.white70;
    
    Icon buildIcon(IconData iconData, bool isActive) {
      return Icon(
        iconData,
        color: isActive ? kActiveIconColor : kInActiveIconColor,
      );
    }

    final List<Widget> pages = [
      Dashboard(),
      NotificationPage(),
      Setting(),
    ];

    final List<String> titles = [
      'Home',
      'Notifications',
      'Setting',
    ];

    return Scaffold(
      appBar: Helper.sampleAppBar(titles[_controller.index], context, null),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          _handleScroll(scroll);
          return false;
        },
        child: pages[_controller.index],
      ),
      extendBody: true,
      floatingActionButton: _controller.index == 0 
      ? FloatingActionButton(
          onPressed: () {
              Get.to(
                UserForm(),
                arguments: 'Create Users'
              );
          },
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          child: Icon(Icons.person_add_outlined),
        )
      : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
      bottomNavigationBar: AnimatedSlide(
        offset: _bottomBarOffset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _bottomBarOpacity,
          duration: const Duration(milliseconds: 250),
          child: SafeArea(
            bottom: true,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius:BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: AnimatedNotchBottomBar(
                    notchBottomBarController: _controller,
                    color: Theme.of(context).secondaryHeaderColor,
                    showLabel: true,
                    notchColor: Theme.of(context).secondaryHeaderColor,
                    removeMargins: false,
                    bottomBarWidth: MediaQuery.of(context).size.width,
                    durationInMilliSeconds: 300,
                    kIconSize: 24.0,
                    kBottomRadius: 10.0,
                    itemLabelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    bottomBarItems: [
                      BottomBarItem(
                        inActiveItem: buildIcon(Icons.home, false),
                        activeItem: buildIcon(Icons.home, true),
                        itemLabel: 'Home',
                      ),
                      BottomBarItem(
                        inActiveItem: buildIcon(Icons.notifications_active, false),
                        activeItem: buildIcon(Icons.notifications_active, true),
                        itemLabel: 'Messages',
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
    );
  }
}
