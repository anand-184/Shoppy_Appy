import 'package:flutter/material.dart';
import '../admins/super_admin/screens/side_nav/admin_mgmt.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _role = ''; // "super admin", "operations admin", "finance admin"

  @override
  void initState() {
    super.initState();
    getUser();
  }

  void getUser() {
    // Mocking the user role fetching logic
    setState(() {
      _role = 'super admin'; // Change this to test: 'operations admin', 'finance admin'
    });
  }

  List<Widget> _getScreens() {
    switch (_role) {
      case 'super admin':
        return [
          const Center(child: Text("Super Admin Home")),
          const AdminManagementScreen(),
          const Center(child: Text("Reports")),
        ];
      case 'operations admin':
        return [
          const Center(child: Text("Operations Dashboard")),
          const Center(child: Text("Inventory")),
          const Center(child: Text("Logistics")),
        ];
      case 'finance admin':
        return [
          const Center(child: Text("Finance Overview")),
          const Center(child: Text("Transactions")),
          const Center(child: Text("Audit Logs")),
        ];
      default:
        return [const Center(child: Text("Loading..."))];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    switch (_role) {
      case 'super admin':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Admins"),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: "Reports"),
        ];
      case 'operations admin':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ops Home"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Inventory"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "Logistics"),
        ];
      case 'finance admin':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "Finance"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Transfers"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Audit"),
        ];
      default:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.hourglass_empty), label: "Wait"),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = _getScreens();
    final navItems = _getBottomNavItems();
    final currentScreen = screens.length > _selectedIndex ? screens[_selectedIndex] : const Center(child: CircularProgressIndicator());

    return Scaffold(
      // Move FAB here to ensure it's always visible above the BottomNav
      floatingActionButton: _role == 'super admin' && _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                // We need a way to trigger the dialog in AdminManagementScreen
                // or move the logic here.
              },
              backgroundColor: const Color(0xFF915F41),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: currentScreen,
      bottomNavigationBar: navItems.length > 1
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0xFF915F41), // chocolate
              unselectedItemColor: Colors.grey,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: navItems,
            )
          : null,
    );
  }
}
