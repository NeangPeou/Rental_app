import 'dart:ui';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend_rental/screens/bottomNavigationBar/setting.dart';
import 'package:frontend_rental/screens/page/owner/dashboard.dart';
import 'package:frontend_rental/screens/page/owner/leasePage.dart';
import 'package:frontend_rental/screens/page/owner/paymentPage.dart';
import 'package:frontend_rental/screens/page/owner/propertyPage.dart';
import 'package:frontend_rental/screens/page/owner/propertyUnit.dart';
import 'package:frontend_rental/screens/page/rental/rentalPage.dart';
import 'package:frontend_rental/shared/loading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../models/error.dart';
import '../../services/auth.dart';
import '../../utils/helper.dart';
import '../controller/property_controller.dart';
import '../controller/setting_controller.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);
  final SettingController _settingController = Get.find();
  final _sidebarController = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();
  double _bottomBarOpacity = 1.0;
  Offset _bottomBarOffset = Offset.zero;
  int _selectedIndex = 0;
  String? token;
  bool isOwner = false;
  bool isLoading = true;
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
          itemLabel: 'Setting'.tr,
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
          itemLabel: 'Setting'.tr,
        ),
      ];
    }
  }

  List<String> getAppBarTitles(bool isOwner) {
    return isOwner ? ['listings'.tr, 'calendar'.tr, 'inbox'.tr, 'Setting'.tr] : ['explore'.tr, 'save'.tr, 'inbox'.tr, 'Setting'.tr];
  }

  @override
  void initState() {
    super.initState();
    Get.put(PropertyController());
    getUserData();
    ever<int>(_settingController.selectedIndex, (index) {
      _sidebarController.selectIndex(index);
    });
  }

  Future<void> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('x-auth-token');
    bool ownerStatus = prefs.getBool('isOwner') ?? false;

    if (ownerStatus == true && token != null && token!.isNotEmpty) {
      ErrorModel errorModel = await _auth.getUserData(context);
      if (errorModel.isError) {
        await prefs.setBool('isOwner', false);
        await prefs.setString('x-auth-token', '');
        token = prefs.getString('x-auth-token');
        ownerStatus = prefs.getBool('isOwner') ?? false;
      }
    }
    setState(() {
      if(ownerStatus && token != null && token!.isNotEmpty){
        isOwner = ownerStatus;
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = isOwner ? const [Dashboard(), Scaffold(body: Center(child: Text('Calendar'))), Scaffold(body: Center(child: Text('Inbox'))), Setting()] : const [RentalPage(), Scaffold(body: Center(child: Text('Saved'))), Scaffold(body: Center(child: Text('Inbox'))), Setting()];
    final bottomBarItems = getBottomBarItems(isOwner);
    final appBarTitles = getAppBarTitles(isOwner);
    final title = appBarTitles[_selectedIndex];

    if (isLoading) {
      return Loading();
    }
    return Scaffold(
      key: _key,
      appBar: Helper.sampleAppBar(title, context, isOwner ? 'assets/app_icon/sw_logo.png' : null),
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
      drawer: isOwner ?
        AnimatedBuilder(
          animation: _sidebarController,
          builder: (context, _) {
            return Drawer(
              width: _sidebarController.extended ? 280 : 70,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Get.theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(3, 0),
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor.withAlpha(120)),
                      top: BorderSide(color: Theme.of(context).dividerColor.withAlpha(120)),
                      right: BorderSide(color: Theme.of(context).dividerColor.withAlpha(120))
                    ),
                  ),
                  child: SidebarX(
                    controller: _sidebarController,
                    animationDuration: Duration(milliseconds: 400),
                    showToggleButton: true,
                    theme: SidebarXTheme(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(3, 0),
                          ),
                        ],
                      ),
                      hoverColor: Get.theme.primaryColor.withOpacity(0.1),
                      itemTextPadding: const EdgeInsets.only(left: 20),
                      selectedItemTextPadding: const EdgeInsets.only(left: 20),
                      selectedTextStyle: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedItemDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.teal,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.3),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      iconTheme: IconThemeData(
                        size: 24,
                        color: Colors.grey.shade600,
                      ),
                      selectedIconTheme: IconThemeData(
                        size: 24,
                      ),
                    ),
                    headerBuilder: (context, extended) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: extended ? 120 : 40,
                              height: extended ? 120 : 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.teal.withOpacity(0.2),
                              ),
                              child: Container(
                                 decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).dividerColor),
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.asset('assets/app_icon/sw_logo.png', fit: BoxFit.contain),
                                ),
                              ),
                            ),
                          ),
                          if (extended) ...[
                            SizedBox(height: 5),
                            Text(
                              "SW Rental",
                              style: Get.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Owner Panel",
                              style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                          ],
                          const Divider() 
                        ],
                      );
                    },
                    items: [
                      SidebarXItem(
                          icon: Icons.dashboard,
                          label: 'Dashboard'.tr,
                          onTap: () => Get.to(() => Wrapper())),
                      SidebarXItem(
                          icon: Icons.home,
                          label: 'property'.tr,
                          onTap: () => Get.to(() => PropertyPage())),
                      SidebarXItem(
                          icon: Icons.home_work,
                          label: 'property_unit'.tr,
                          onTap: () => Get.to(() => PropertyUnit())),
                      SidebarXItem(icon: Icons.people, label: 'tenants'.tr),
                      SidebarXItem(
                          icon: Icons.assignment,
                          label: 'leases'.tr,
                          onTap: () => Get.to(() => LeasePage())),
                      SidebarXItem(
                          icon: Icons.payment,
                          label: 'payments'.tr,
                          onTap: () => Get.to(() => Payment())),
                      SidebarXItem(icon: Icons.build, label: 'maintenance_requests'.tr),
                      SidebarXItem(icon: Icons.logout, label: 'logout'.tr),
                    ],
                  ),
                ),
              ),
            );
          },
        )
      : null,

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