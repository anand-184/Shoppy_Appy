import 'package:flutter/material.dart';

class VendorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  final Color chocolate = const Color(0xFF915F41);
  final Color darkBrown = const Color(0xFF5F372B);
  final Color backgroundColor = const Color(0xFFFDF8F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(vendor['company_name'] ?? "Vendor Details",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: darkBrown,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 24),
            
            // Management Grid
            const Text(
              "Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5F372B)),
            ),
            const SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildActionCard(
                  context,
                  "Orders",
                  Icons.shopping_bag_outlined,
                  Colors.blue,
                  "Manage vendor orders",
                  () {
                    // Navigate to Vendor Orders
                  },
                ),
                _buildActionCard(
                  context,
                  "Products",
                  Icons.inventory_2_outlined,
                  Colors.orange,
                  "View listings",
                  () {
                    // Navigate to Vendor Products
                  },
                ),
                _buildActionCard(
                  context,
                  "Payouts",
                  Icons.account_balance_wallet_outlined,
                  Colors.green,
                  "Financial history",
                  () {
                    // Navigate to Payouts
                  },
                ),
                _buildActionCard(
                  context,
                  "Business Info",
                  Icons.business_outlined,
                  chocolate,
                  "View full profile",
                  () {
                    // Navigate to Business Details
                  },
                ),
                _buildActionCard(
                  context,
                  "Analytics",
                  Icons.analytics_outlined,
                  Colors.purple,
                  "Performance data",
                  () {
                    // Navigate to Analytics
                  },
                ),
                _buildActionCard(
                  context,
                  "Settlements",
                  Icons.handshake_outlined,
                  Colors.teal,
                  "Commission logs",
                  () {
                    // Navigate to Settlements
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: chocolate.withOpacity(0.1),
            child: Icon(Icons.storefront_rounded, size: 40, color: chocolate),
          ),
          const SizedBox(height: 16),
          Text(
            vendor['company_name'] ?? "N/A",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkBrown),
          ),
          const SizedBox(height: 4),
          Text(
            vendor['seller_email'] ?? "N/A",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStat("Status", vendor['status'] ?? "N/A", Colors.green),
              _buildQuickStat("Commission", "${vendor['commission_rate'] ?? 0}%", chocolate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkBrown),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
