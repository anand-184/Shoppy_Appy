import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../OtherScreens/VendorDetailScreen.dart';

class VendorManagementScreen extends StatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  State<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<VendorManagementScreen> {
  List<Map<String, dynamic>> _vendors = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;

  final Color chocolate = const Color(0xFF915F41);
  final Color darkBrown = const Color(0xFF5F372B);
  final Color backgroundColor = const Color(0xFFFDF8F5);

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors({bool loadMore = false}) async {
    if (!mounted) return;
    if (loadMore && (!_hasMore || _isFetchingMore)) return;
    if (!loadMore && _isFetchingMore) return;

    setState(() {
      if (loadMore) {
        _isFetchingMore = true;
      } else {
        _isLoading = true;
        _currentPage = 0;
        _vendors = [];
      }
    });

    try {
      final from = _currentPage * _pageSize;
      final to = from + _pageSize - 1;

      final response = await Supabase.instance.client
          .from('sellers')
          .select()
          .eq('status', 'approved')
          .order('company_name', ascending: true)
          .range(from, to);

      if (!mounted) return;

      final List<Map<String, dynamic>> fetched = List<Map<String, dynamic>>.from(response);

      setState(() {
        _vendors.addAll(fetched);
        _hasMore = fetched.length == _pageSize;
        if (_hasMore) _currentPage++;
        _isLoading = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching vendors: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Vendor Management", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: darkBrown,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _fetchVendors(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: chocolate))
          : _vendors.isEmpty
              ? const Center(child: Text("No Approved Vendors Found"))
              : RefreshIndicator(
                  onRefresh: () => _fetchVendors(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scroll) {
                      if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
                        _fetchVendors(loadMore: true);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _vendors.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _vendors.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final vendor = _vendors[index];
                        return _buildVendorCard(vendor);
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildVendorCard(Map<String, dynamic> vendor) {
    final String status = vendor['status'] ?? 'Unknown';
    Color statusColor = status == 'Active' || status == 'Approved' ? Colors.green : Colors.orange;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VendorDetailScreen(vendor: vendor),
            ),
          );
          _fetchVendors(); // Refresh on return
        },
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: chocolate.withOpacity(0.1),
          radius: 25,
          child: Icon(Icons.storefront_rounded, color: chocolate, size: 28),
        ),
        title: Text(
          vendor['company_name'] ?? 'No Store Name',
          style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "Owner: ${vendor['seller_name'] ?? 'N/A'}",
              style: TextStyle(color: chocolate, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Comm: ${vendor['commission_rate'] ?? 0}%",
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      ),
    );
  }
}
