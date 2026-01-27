import 'package:flutter/material.dart';

class FinanceSection extends StatefulWidget {
  const FinanceSection({super.key});

  @override
  State<FinanceSection> createState() => _FinanceState();
}

class _FinanceState extends State<FinanceSection> {
  final Color chocolate = const Color(0xFF915F41);
  final Color darkBrown = const Color(0xFF5F372B);
  final Color backgroundColor = const Color(0xFFFDF8F5);

  bool _isLoading = true;
  String _selectedFilter = "Today";

  // Dummy values (replace with API response later)
  String totalRevenue = "₹1,25,000";
  String commission = "₹12,500";
  String tax = "₹8,200";
  String sellerPayout = "₹1,04,300";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Finance Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: darkBrown,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: chocolate))
          : RefreshIndicator(
        color: chocolate,
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterRow(),
              const SizedBox(height: 20),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                      "Total Revenue", totalRevenue, Icons.payments),
                  _buildStatCard(
                      "Commission Earned", commission, Icons.percent),
                  _buildStatCard(
                      "Tax Collected", tax, Icons.receipt_long),
                  _buildStatCard(
                      "Seller Payouts", sellerPayout, Icons.account_balance_wallet),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 FILTER BUTTON ROW
  Widget _buildFilterRow() {
    return Row(
      children: [
        _filterButton("Today"),
        _filterButton("This Week"),
        _filterButton("This Month"),
      ],
    );
  }

  Widget _filterButton(String text) {
    final bool isSelected = _selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = text;
          _fetchDashboardData();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chocolate : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : darkBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 🔹 STAT CARD
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: chocolate, size: 28),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// 🔹 API PLACEHOLDER
  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Replace with backend API response
    setState(() {
      _isLoading = false;
    });
  }
}
