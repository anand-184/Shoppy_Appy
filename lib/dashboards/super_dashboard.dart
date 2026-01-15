import 'package:flutter/material.dart';
import 'package:shoppy_appy/admins/super_admin/screens/bottom_nav/finance.dart';
import 'package:shoppy_appy/admins/super_admin/screens/side_nav/customer_mgmt.dart';
import 'package:shoppy_appy/admins/super_admin/screens/side_nav/request_mgmt.dart';
import 'package:shoppy_appy/admins/super_admin/screens/side_nav/vendor_mgmt.dart';

import '../admins/super_admin/screens/bottom_nav/centre_dashboard.dart';
import '../admins/super_admin/screens/bottom_nav/query_section.dart';
import '../admins/super_admin/screens/side_nav/admin_mgmt.dart';
import '../admins/super_admin/screens/side_nav/profile_mgmt.dart';

class SuperAdminBottomScreen extends StatefulWidget {
  const SuperAdminBottomScreen({super.key});

  @override
  State<SuperAdminBottomScreen> createState() => _SuperAdminBottomScreenState();
}

class _SuperAdminBottomScreenState extends State<SuperAdminBottomScreen> {
  int _currentIndex = 0; // For Side Nav
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentBottomIndex = 1; // For Bottom Nav
  bool _isSideNavActive = false; // Logic to switch between screen lists


  final List<Widget> _sidenavScreens = [
    const AdminManagementScreen(),
    const VendorManagementScreen(),
    const RequestMgmt(),
    const CustomerMgmt(),
    const ProfileMgmt(),
  ];

  final List<Widget> _bottomNavScreens = [
    const FinanceSection(),
    const CenterDashboard(),
    const QuerySection(),
  ];

  // Refined Color Palette
  final Color darkBrown = const Color(0xFF5F372B);
  final Color chocolate = const Color(0xFF915F41);
  final Color backgroundColor = const Color(0xFFFDF8F5);
  final Color lightBeige = const Color(0xFFF3E9E1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: darkBrown, size: 30),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          'Super Admin',
          style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: darkBrown),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildSideDrawer(),
      body: _isSideNavActive 
            ? _sidenavScreens[_currentIndex] 
            : _bottomNavScreens[currentBottomIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 40),
        decoration: BoxDecoration(
          color: chocolate,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: darkBrown.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(0, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Finance'),
            _buildCentralNavItem(1, Icons.dashboard_outlined, 'Dashboard'),
            _buildNavItem(2, Icons.question_answer_outlined, Icons.question_answer_rounded, 'Query'),
          ],
        ),
      ),
    );
  }

  Widget _buildSideDrawer() {
    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: chocolate),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFF915F41), size: 40),
            ),
            accountName: const Text(
              'Super Admin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text('admin@eshop.com'),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(0, 'Admin Management', Icons.people_rounded),
                _buildDrawerItem(1, 'Vendor Management', Icons.storefront_rounded),
                _buildDrawerItem(2, 'Requests Management', Icons.assignment_rounded),
                _buildDrawerItem(3, 'Customers', Icons.group_rounded),
                _buildDrawerItem(4, 'Profile', Icons.person_rounded),
                const Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () {
                    // Handle Logout
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'v 1.0.0',
              style: TextStyle(color: darkBrown.withOpacity(0.5), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, String title, IconData icon) {
    bool isSelected = _isSideNavActive && _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? chocolate.withOpacity(0.1) : Colors.transparent,
        leading: Icon(icon, color: isSelected ? chocolate : darkBrown),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? chocolate : darkBrown,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          setState(() {
            _currentIndex = index;
            _isSideNavActive = true;
          });
          Navigator.pop(context); // Close drawer
        },
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData selectedIcon, String label) {
    bool isSelected = !_isSideNavActive && currentBottomIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        currentBottomIndex = index;
        _isSideNavActive = false;
      }),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralNavItem(int index, IconData icon, String label) {
    bool isSelected = !_isSideNavActive && currentBottomIndex == index;
    return GestureDetector(
      onTap: () => setState(() {
        currentBottomIndex = index;
        _isSideNavActive = false;
      }),
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: darkBrown.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: chocolate, width: 3),
              ),
              child: Icon(
                icon,
                color: chocolate,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
