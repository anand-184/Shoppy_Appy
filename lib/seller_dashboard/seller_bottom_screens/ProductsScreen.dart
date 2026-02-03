import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../admins/super_admin/screens/OtherScreens/AddProductDialog.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final Color chocolate = const Color(0xFF915F41);
  final Color darkBrown = const Color(0xFF5F372B);
  final Color backgroundColor = const Color(0xFFFDF8F5);

  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetching products and joining with product_images to get the primary image
      final response = await _supabase
          .from('products')
          .select('*, product_images(image_url, is_primary)')
          .eq('seller_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("My Products", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: darkBrown,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchProducts,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return _buildProductCard(product);
                  },
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 110.0),
        child: FloatingActionButton(
          onPressed: () async {
            // Correct way to show a Dialog
            Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddProductDialog()),
            );
            final result = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddProductDialog()),
            );
            if (result == true) {
              _fetchProducts();
            }
          },
          backgroundColor: chocolate,
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: chocolate.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text("No products found", style: TextStyle(color: darkBrown, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Start adding items to your shop", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    // Extract primary image if available
    final images = product['product_images'] as List?;
    String? imageUrl;
    if (images != null && images.isNotEmpty) {
      final primary = images.firstWhere((img) => img['is_primary'] == true, orElse: () => images.first);
      imageUrl = primary['image_url'];
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover)
                    : Container(color: Colors.grey.shade100, child: const Icon(Icons.image_not_supported)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: chocolate,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "₹${product['base_price']}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['product_name'] ?? 'No Name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Stock: ${product['stock'] ?? 0}",
                  style: TextStyle(
                    fontSize: 12,
                    color: (product['stock'] ?? 0) < 5 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product['is_active'] == true ? "Active" : "Inactive",
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const Icon(Icons.edit_note_outlined, size: 20, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
