import 'dart:ui';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend_rental/screens/bottomNavigationBar/setting.dart';
import 'package:frontend_rental/screens/page/owner/ownerPage.dart';
import 'package:frontend_rental/screens/page/rental/rentalPage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/error.dart';
import '../../services/auth.dart';
import '../../utils/helper.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);
  double _bottomBarOpacity = 1.0;
  Offset _bottomBarOffset = Offset.zero;
  int _selectedIndex = 0;
  String? token;
  bool isOwner = false;
  final AuthService _auth = AuthService();

  Icon buildIcon(IconData iconData, bool isActive) {
    return Icon(
      iconData,
      color: isActive ? Colors.white : Colors.white70,
    );
  }

  List<BottomBarItem> getBottomBarItems(bool isOwner) {
    if (isOwner) {
      return [
        BottomBarItem(
          inActiveItem: buildIcon(Icons.list_alt, false),
          activeItem: buildIcon(Icons.list_alt, true),
          itemLabel: 'listings'.tr,
        ),
        BottomBarItem(
          inActiveItem: buildIcon(Icons.calendar_month, false),
          activeItem: buildIcon(Icons.calendar_month, true),
          itemLabel: 'calendar'.tr,
        ),
        BottomBarItem(
          inActiveItem: buildIcon(Icons.inbox, false),
          activeItem: buildIcon(Icons.inbox, true),
          itemLabel: 'inbox'.tr,
        ),
        BottomBarItem(
          inActiveItem: buildIcon(Icons.settings, false),
          activeItem: buildIcon(Icons.settings, true),
          itemLabel: 'settings'.tr,
        ),
      ];
    } else {
      return [
        BottomBarItem(
          inActiveItem: buildIcon(Icons.content_paste_search, false),
          activeItem: buildIcon(Icons.content_paste_search, true),
          itemLabel: 'explore'.tr,
        ),
        BottomBarItem(
          inActiveItem: buildIcon(Icons.favorite, false),
          activeItem: buildIcon(Icons.favorite, true),
          itemLabel: 'save'.tr,
        ),
        BottomBarItem(
          inActiveItem: buildIcon(Icons.inbox, false),
          activeItem: buildIcon(Icons.inbox, true),
          itemLabel: 'inbox'.tr,
        ),
        BottomBarItem(
          inActiveItem: buildIcon(Icons.settings, false),
          activeItem: buildIcon(Icons.settings, true),
          itemLabel: 'settings'.tr,
        ),
      ];
    }
  }

  List<String> getAppBarTitles(bool isOwner) {
    return isOwner ? ['listings'.tr, 'calendar'.tr, 'inbox'.tr, 'settings'.tr] : ['explore'.tr, 'save'.tr, 'inbox'.tr, 'settings'.tr];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUserData();
    });
  }

  Future<void> getUserData() async {
    Helper.showLoadingDialog(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('x-auth-token');
    bool ownerStatus = prefs.getBool('isOwner') ?? false;

    if (isOwner == true && token != null && token!.isNotEmpty) {
      ErrorModel errorModel = await _auth.getUserData(context);
      if (errorModel.isError) {
        Helper.closeLoadingDialog(context);
        Get.offAll(() => const RentalPage());
        return;
      }
    } else {
      prefs.setString('x-auth-token', '');
      token = '';
    }

    Helper.closeLoadingDialog(context);
    setState(() {
      isOwner = ownerStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = isOwner ? const [OwnerPage(), Scaffold(body: Center(child: Text('Calendar'))), Scaffold(body: Center(child: Text('Inbox'))), Setting()] : const [RentalPage(), Scaffold(body: Center(child: Text('Saved'))), Scaffold(body: Center(child: Text('Inbox'))), Setting()];
    final bottomBarItems = getBottomBarItems(isOwner);
    final appBarTitles = getAppBarTitles(isOwner);
    final title = appBarTitles[_selectedIndex];

    return Scaffold(
      appBar: Helper.sampleAppBar(title, context, null),
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: pages[_selectedIndex],
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
            bottom: true,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100)),
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
                    bottomBarItems: bottomBarItems,
                    onTap: (index) {
                      setState(() {
                        _selectedIndex = index;
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

  bool _handleScroll(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.reverse && _bottomBarOpacity != 0.0) {
        setState(() {
          _bottomBarOpacity = 0.0;
          _bottomBarOffset = const Offset(0, 1);
        });
      } else if (notification.direction == ScrollDirection.forward && _bottomBarOpacity != 1.0) {
        setState(() {
          _bottomBarOpacity = 1.0;
          _bottomBarOffset = Offset.zero;
        });
      }
    }
    return false;
  }
}
