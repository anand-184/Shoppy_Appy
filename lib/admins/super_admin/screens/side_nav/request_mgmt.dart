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
  final ScrollController _scrollController = ScrollController();

  static const int pageSize = 20;
  int currentPage = 0;

  bool hasMore = true;
  bool isInitialLoading = true;
  bool isFetchingMore = false;

  final List<Map<String, dynamic>> requesters = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold &&
        hasMore &&
        !isFetchingMore &&
        !isInitialLoading) {
      _fetchRequests(loadMore: true);
    }
  }

  Future<void> _fetchRequests({bool loadMore = false}) async {
    if (!mounted) return;
    if (loadMore && (!hasMore || isFetchingMore)) return;

    setState(() {
      if (loadMore) {
        isFetchingMore = true;
      } else {
        isInitialLoading = true;
        currentPage = 0;
        hasMore = true;
        requesters.clear();
      }
    });

    try {
      final from = currentPage * pageSize;
      final to = from + pageSize - 1;

      final response = await supabase
          .from('sellers')
          .select()
          .order('created_at', ascending: false)
          .range(from, to);

      final fetched = List<Map<String, dynamic>>.from(response);

      setState(() {
        requesters.addAll(fetched);
        hasMore = fetched.length == pageSize;
        if (hasMore) currentPage++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isInitialLoading = false;
          isFetchingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      appBar: AppBar(
        title: const Text("Seller Requests",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchRequests(),
          )
        ],
      ),
      body: isInitialLoading
          ? const RequestSkeletonList()
          : requesters.isEmpty
          ? const Center(child: Text("No Requests Found"))
          : RefreshIndicator(
        onRefresh: () => _fetchRequests(),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: requesters.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == requesters.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                    child:
                    CircularProgressIndicator(strokeWidth: 2)),
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
                if (result == true) _fetchRequests();
              },
            );
          },
        ),
      ),
    );
  }
}


class RequestSkeletonList extends StatelessWidget {
  const RequestSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => const RequestSkeletonItem(),
    );
  }
}

class RequestSkeletonItem extends StatelessWidget {
  const RequestSkeletonItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(width: 120),
                  const SizedBox(height: 8),
                  _line(width: 180),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line({required double width}) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class RequestItem extends StatelessWidget {
  final Map<String, dynamic> requester;
  final VoidCallback onTap;
  const RequestItem({ super.key, required this.requester,
    required this.onTap, });
  @override Widget build(BuildContext context)
  { final status = requester['status'] ??
      'Pending';
    final Color statusColor = status == 'active' || status == 'approved' ?
    Colors.green :
    status == 'rejected' || status == 'suspended' ? Colors.red : Colors.orange;
    return Card( margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar( child: Icon(Icons.person),
        ), title: Text( requester['seller_name'] ?? 'Unknown',
        style: const TextStyle(fontWeight: FontWeight.bold), ),
        subtitle: Text(requester['seller_email'] ?? ''),
        trailing: Text( status, style: TextStyle(color: statusColor), ), ), ); } }


