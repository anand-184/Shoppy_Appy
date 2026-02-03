import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController();

  // Selection state
  String? _selectedCategory;
  String? _selectedWarehouse;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Colors from theme
  final Color chocolate = const Color(0xFF915F41);
  final Color darkBrown = const Color(0xFF5F372B);

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _basePriceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }

  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // 1. Insert Product
      final productResponse = await _supabase.from('products').insert({
        'seller_id': user.id,
        'product_name': _nameController.text.trim(),
        'product_desc': _descController.text.trim(),
        'base_price': double.parse(_basePriceController.text),
        'discount_price': _discountPriceController.text.isEmpty 
            ? null 
            : double.parse(_discountPriceController.text),
        'stock': int.parse(_stockController.text),
        'category_id': _selectedCategory, // Placeholder for UUID
      }).select().single();

      final String productId = productResponse['id'];

      // 2. Upload Images and insert into product_images table
      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        final filePath = 'products/$productId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';


        await _supabase.storage.from('product-images').upload(
          filePath,
          file,
          fileOptions: const FileOptions(
            upsert: false,
            contentType: 'image/jpeg',
          ),
        );

        final imageUrl = _supabase.storage.from('product-images').getPublicUrl(filePath);

        await _supabase.from('product_images').insert({
          'product_id': productId,
          'image_url': imageUrl,
          'is_primary': i == 0, // First image is primary
        });
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500, maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Add New Product", 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkBrown)),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Image Picker Area
                  _buildImageSelector(),
                  const SizedBox(height: 20),

                  _buildTextField(_nameController, "Product Name", Icons.shopping_bag_outlined),
                  const SizedBox(height: 16),
                  _buildTextField(_descController, "Description", Icons.description_outlined, maxLines: 3),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(child: _buildTextField(_basePriceController, "Base Price", Icons.payments_outlined, 
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))])),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField(_discountPriceController, "Discount Price", Icons.money_off_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        isOptional: true)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(_stockController, "Initial Stock", Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: chocolate,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Product", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Product Images", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(Icons.add_a_photo_outlined, color: chocolate),
                ),
              ),
              ..._selectedImages.map((file) => Container(
                width: 100,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImages.remove(file)),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return "$label is required";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: chocolate),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
