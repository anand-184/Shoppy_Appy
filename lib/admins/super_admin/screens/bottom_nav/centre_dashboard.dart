import 'package:flutter/material.dart';

class CenterDashboard extends StatefulWidget {
  const CenterDashboard({super.key});

  @override
  State<CenterDashboard> createState() => _CenterDashboardState();
}

class _CenterDashboardState extends State<CenterDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recentActivity = [];
  List<Map<String, dynamic>> _suspiciousActivity = [];

  final Color chocolate = const Color(0xFF915F41);
  final Color darkBrown = const Color(0xFF5F372B);
  final Color backgroundColor = const Color(0xFFFDF8F5);

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  // --- API FUNCTION STRUCTURES ---

  /// Main orchestrator for fetching dashboard data
  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // Execute all API calls in parallel for better performance
      final results = await Future.wait([
        _getAdminStatsFromApi(),
        _getRecentActivityFromApi(),
        _getSuspiciousActivityFromApi(),
      ]);

      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _recentActivity = results[1] as List<Map<String, dynamic>>;
        _suspiciousActivity = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
      setState(() => _isLoading = false);
    }
  }

  /// Placeholder for fetching numeric counts/stats
  Future<Map<String, dynamic>> _getAdminStatsFromApi() async {
    // TODO: Replace with your backend call (e.g., Supabase rpc or select)
    await Future.delayed(const Duration(milliseconds: 500)); 
    return {
      "totalAdmins": 12,
      "activeAdmins": 10,
      "blockedAdmins": 2,
      "rolesCount": 5,
    };
  }

  /// Placeholder for fetching login logs
  Future<List<Map<String, dynamic>>> _getRecentActivityFromApi() async {
    // TODO: Replace with your backend call
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {"user": "Alice", "action": "Logged in", "time": "2 mins ago"},
      {"user": "Bob", "action": "Updated Catalog", "time": "15 mins ago"},
      {"user": "Charlie", "action": "Logged in", "time": "1 hour ago"},
    ];
  }

  /// Placeholder for fetching security alerts
  Future<List<Map<String, dynamic>>> _getSuspiciousActivityFromApi() async {
    // TODO: Replace with your backend call
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {"user": "Unknown", "event": "Failed Login Attempt", "time": "10:45 AM", "severity": "High"},
      {"user": "John", "event": "Multiple Password Resets", "time": "Yesterday", "severity": "Medium"},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Admin Overview"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: darkBrown,
        actions: [
          IconButton(onPressed: _fetchDashboardData, icon: const Icon(Icons.refresh))
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: chocolate))
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              color: chocolate,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatGrid(),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Last Login Activity", Icons.history),
                    const SizedBox(height: 12),
                    _buildActivityList(_recentActivity),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Suspicious Activity Alerts", Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(height: 12),
                    _buildSuspiciousList(_suspiciousActivity),
                    const SizedBox(height: 100), // Bottom padding
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("Total Admins", (_stats['totalAdmins'] ?? 0).toString(), Icons.people, Colors.blue),
        _buildStatCard("Active Admins", (_stats['activeAdmins'] ?? 0).toString(), Icons.check_circle, Colors.green),
        _buildStatCard("Blocked Admins", (_stats['blockedAdmins'] ?? 0).toString(), Icons.block, Colors.red),
        _buildStatCard("Roles Count", (_stats['rolesCount'] ?? 0).toString(), Icons.assignment_ind, chocolate),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBrown)),
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? darkBrown, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color ?? darkBrown)),
      ],
    );
  }

  Widget _buildActivityList(List<Map<String, dynamic>> activities) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = activities[index];
          return ListTile(
            leading: CircleAvatar(backgroundColor: chocolate.withOpacity(0.1), child: Text(item['user'][0], style: TextStyle(color: chocolate))),
            title: Text(item['user'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['action']),
            trailing: Text(item['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
          );
        },
      ),
    );
  }

  Widget _buildSuspiciousList(List<Map<String, dynamic>> alerts) {
    return Column(
      children: alerts.map((alert) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.red[50],
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.red.shade100)),
          child: ListTile(
            leading: const Icon(Icons.report_problem, color: Colors.red),
            title: Text(alert['event'], style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: Text("User: ${alert['user']} • ${alert['time']}"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
              child: Text(alert['severity'], style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }).toList(),
    );
  }
}
