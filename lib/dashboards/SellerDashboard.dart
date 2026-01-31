import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shoppy_appy/seller_dashboard/seller_bottom_screens/OrdersScreen.dart';
import 'package:shoppy_appy/seller_dashboard/seller_bottom_screens/ProductsScreen.dart';
import 'package:shoppy_appy/seller_dashboard/seller_bottom_screens/SellerMainScreen.dart';
import 'package:shoppy_appy/seller_dashboard/seller_nav_screens/CustomerQueries.dart';
import 'package:shoppy_appy/seller_dashboard/seller_nav_screens/PaymentsScreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_screen.dart';
import '../seller_dashboard/seller_bottom_screens/ReportsScreen.dart';
import '../seller_dashboard/seller_nav_screens/PoliciesScreen.dart';
import '../seller_dashboard/seller_nav_screens/SellerProfileScreen.dart';

class SellerDashboardScreen extends StatefulWidget{
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {

  final Color darkBrown = const Color(0xFF5F372B);
  final Color chocolate = const Color(0xFF915F41);
  final Color backgroundColor = const Color(0xFFFDF8F5);
  final Color lightBeige = const Color(0xFFF3E9E1);
  final supabase = Supabase.instance.client;
  int _currentIndex = 0; // For Side Nav
  bool _isSideNavActive = false;
  int currentBottomIndex = 1; // For Bottom Nav
  final List<Widget> _sidenavScreens = [
    const Paymentsscreen(),
    const CustomerQueryScreen(),
    const SellerPoliciesScreen(),
    const SellerProfileScreen(),
  ];
  final List<Widget> _bottomNavScreens = [
    const SellerMainScreen(),
    const OrdersScreen(),
    const ProductsScreen(),
    const ReportsScreen(),
  ];
  late final user = supabase.auth.currentUser;
  late final name = user?.userMetadata?['name'] ?? 'Seller';
  late final email = user?.email ?? '';







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seller Dashboard"),
        centerTitle: true,
        backgroundColor: chocolate,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: _buildSideDrawer(),
      body: _isSideNavActive
          ? _sidenavScreens[_currentIndex]
          : _bottomNavScreens[currentBottomIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        height: 80,
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 45),
        decoration: BoxDecoration(
          color: chocolate,
          borderRadius: BorderRadius.circular(35),
        ),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0,Icons.dashboard, Icons.dashboard_rounded, 'Dashboard'),
            _buildNavItem(1, Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Orders'),
            _buildNavItem(2, Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Products'),
            _buildNavItem(3, Icons.analytics_outlined, Icons.analytics_rounded, 'Reports'),
          ]
        ),

      )


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
            accountName: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(email),
          ),
          Expanded(child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerItem(0, "Payments",Icons.payment_outlined),
              _buildDrawerItem(1, "Customer Queries", Icons.question_answer_outlined),
              _buildDrawerItem(2, "Policies", Icons.policy_outlined),
              _buildDrawerItem(3, "Profile", Icons.person_outline),
              const Divider(height: 30, thickness: 1, indent: 20, endIndent: 20),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () {
                  logout(context);
                },
              )




            ]
          ))
        ]
      )
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


  Future<void> logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

}