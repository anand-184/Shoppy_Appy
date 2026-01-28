import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../OtherScreens/RequestDetailScreen.dart';

class RequestMgmt extends StatefulWidget {
  const RequestMgmt({super.key});

  @override
  State<RequestMgmt> createState() => _RequestMgmtState();
}

class _RequestMgmtState extends State<RequestMgmt> {
  final int pageSize = 20;
  int currentPage = 0;
  bool hasMore = true;
  bool isFetchingMore = false;
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> requesters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests({bool loadMore = false}) async {
    if (isFetchingMore || (!hasMore && loadMore)) return;

    if (!loadMore) {
      setState(() {
        isLoading = true;
        currentPage = 0;
        requesters = [];
      });
    } else {
      setState(() {
        isFetchingMore = true;
      });
    }

    try {
      final from = currentPage * pageSize;
      final to = from + pageSize - 1;

      final response = await supabase
          .from('sellers')
          .select()
          .range(from, to)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        final List<Map<String, dynamic>> fetchedData = List<Map<String, dynamic>>.from(response);
        requesters.addAll(fetchedData);
        hasMore = fetchedData.length == pageSize;
        if (hasMore) currentPage++;
        isLoading = false;
        isFetchingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isFetchingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Seller's Requests",
          style: TextStyle(fontFamily: "poppins", fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => fetchRequests(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requesters.isEmpty
              ? const Center(child: Text("No Requests Found"))
              : RefreshIndicator(
                  onRefresh: () => fetchRequests(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                          hasMore &&
                          !isFetchingMore) {
                        fetchRequests(loadMore: true);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: requesters.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == requesters.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return _requestItem(
                          requester: requesters[index],
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Requestdetailscreen(
                                  requester: requesters[index],
                                ),
                              ),
                            );

                            if (result == true) {
                              fetchRequests();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _requestItem({
    required Map<String, dynamic> requester,
    required VoidCallback onTap,
  }) {
    final String status = requester['status'] ?? 'Pending';
    Color statusColor = Colors.orange;
    if (status == 'Active' || status == 'Approved') statusColor = Colors.green;
    if (status == 'Suspended' || status == 'Rejected') statusColor = Colors.red;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF915F41).withOpacity(0.1),
          child: const Icon(Icons.person, color: Color(0xFF915F41)),
        ),
        title: Text(
          requester['seller_name'] ?? 'Unknown',
          style: const TextStyle(
            fontFamily: "poppins",
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(requester['seller_email'] ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatDateTime(requester['created_at']),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }

  String formatDateTime(dynamic value) {
    if (value == null) return '';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return '';
    return "${parsed.day}/${parsed.month}/${parsed.year}";
  }
}
