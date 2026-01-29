import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../OtherScreens/RequestDetailScreen.dart';

class RequestMgmt extends StatefulWidget {
  const RequestMgmt({super.key});

  @override
  State<RequestMgmt> createState() => _RequestMgmtState();
}

class _RequestMgmtState extends State<RequestMgmt> {
  final supabase = Supabase.instance.client;

  final int pageSize = 20;
  int currentPage = 0;

  bool hasMore = true;
  bool isLoading = false;
  bool isFetchingMore = false;

  final List<Map<String, dynamic>> requesters = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests({bool loadMore = false}) async {
    if (!mounted) return;
    if (isLoading || isFetchingMore) return;
    if (!hasMore && loadMore) return;

    if (loadMore) {
      isFetchingMore = true;
    } else {
      isLoading = true;
      currentPage = 0;
      hasMore = true;
      requesters.clear();
    }

    setState(() {});

    try {
      final from = currentPage * pageSize;
      final to = from + pageSize - 1;

      final response = await supabase
          .from('sellers')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);

      if (!mounted) return;

      final List<Map<String, dynamic>> fetched =
      List<Map<String, dynamic>>.from(response);

      requesters.addAll(fetched);
      hasMore = fetched.length == pageSize;
      if (hasMore) currentPage++;

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      isLoading = false;
      isFetchingMore = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      appBar: AppBar(
        title: const Text(
          "Seller's Requests",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => fetchRequests(),
          ),
        ],
      ),
      body: isLoading && requesters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : requesters.isEmpty
          ? const Center(child: Text("No Requests Found"))
          : RefreshIndicator(
        onRefresh: () => fetchRequests(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scroll) {
            if (scroll.metrics.pixels >=
                scroll.metrics.maxScrollExtent - 200 &&
                hasMore &&
                !isFetchingMore) {
              fetchRequests(loadMore: true);
            }
            return false;
          },
          child: ListView.builder(
            itemExtent: 100,
            cacheExtent: 500,
            itemCount:
            requesters.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == requesters.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return RequestItem(
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
                  if (result == true) fetchRequests();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ✅ SEPARATE WIDGET (VERY IMPORTANT)
class RequestItem extends StatelessWidget {
  final Map<String, dynamic> requester;
  final VoidCallback onTap;

  const RequestItem({
    super.key,
    required this.requester,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = requester['status'] ?? 'Pending';

    final Color statusColor =
    status == 'Active' || status == 'Approved'
        ? Colors.green
        : status == 'Rejected' || status == 'Suspended'
        ? Colors.red
        : Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          requester['seller_name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(requester['seller_email'] ?? ''),
        trailing: Text(
          status,
          style: TextStyle(color: statusColor),
        ),
      ),
    );
  }
}
