import 'package:flutter/material.dart';

class VendorManagementScreen extends StatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  State<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<VendorManagementScreen> {
  // Data list - will be populated by API call
  List<Map<String, String>> _vendors = [];
  bool _isLoading = true;

  final Color chocolate = const Color(0xFF915F41);
  final Color darkBrown = const Color(0xFF5F372B);
  final Color backgroundColor = const Color(0xFFFDF8F5);

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  // BLANK FUNCTION FOR BACKEND API FETCH
  Future<void> _fetchVendors() async {
    setState(() => _isLoading = true);
    
    // TODO: Add your Supabase or Backend API call here
    // Example: final response = await Supabase.instance.client.from('vendors').select();
    
    await Future.delayed(const Duration(seconds: 1)); // Simulating network delay

    setState(() {
      _vendors = [
        {"storeName": "Fashion Hub", "owner": "John Doe", "status": "Active", "category": "Clothing"},
        {"storeName": "Tech World", "owner": "Alice Smith", "status": "Pending", "category": "Electronics"},
        {"storeName": "Home Decor", "owner": "Bob Wilson", "status": "Active", "category": "Furniture"},
        {"storeName": "Fresh Mart", "owner": "Charlie Brown", "status": "Suspended", "category": "Grocery"},
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: chocolate))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _vendors.length,
              itemBuilder: (context, index) {
                final vendor = _vendors[index];
                return _buildVendorCard(vendor);
              },
            ),
          ),
    );
  }

  Widget _buildVendorCard(Map<String, String> vendor) {
    Color statusColor;
    switch (vendor['status']) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Suspended':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: chocolate.withOpacity(0.1),
          child: Icon(Icons.storefront_rounded, color: chocolate, size: 28),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                vendor['storeName']!,
                style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown, fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vendor['status']!,
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text("Owner: ${vendor['owner']!}", style: TextStyle(color: chocolate, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text("Category: ${vendor['category']!}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'view', child: Text('View Details')),
            const PopupMenuItem(value: 'edit', child: Text('Edit Vendor')),
            const PopupMenuItem(value: 'status', child: Text('Change Status')),
          ],
          onSelected: (val) {},
        ),
      ),
    );
  }
}
