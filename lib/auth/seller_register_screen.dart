import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

class SellerRegisterScreen extends StatefulWidget {
  const SellerRegisterScreen({super.key});

  @override
  State<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends State<SellerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _documentImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isPhoneVerified = false;
  final supabase = Supabase.instance.client;
  String? _sendOtp;
  DateTime? _otpExpiryTime;
  static const int _otpValiditySeconds = 300; // 5 min

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _gstController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _accNoController = TextEditingController();
  final _ifscController = TextEditingController();

  // Document Type selection
  String _selectedDocType = 'GST Certificate';
  final List<String> _docTypes = ['GST Certificate', 'PAN Card', 'Trade License'];

  // Color Palette
  final Color backgroundColor = const Color(0xFFFDF8F5);
  final Color brown = const Color(0xFFB08968);
  final Color darkBrown = const Color(0xFF5F372B);
  final Color chocolate = const Color(0xFF915F41);
  final Color lightBeige = const Color(0xFFF3E9E1);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _documentImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: chocolate),
              title: Text('Gallery', style: TextStyle(color: darkBrown)),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded, color: chocolate),
              title: Text('Camera', style: TextStyle(color: darkBrown)),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

 /*Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter mobile number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final random = Random();
    final otp = random.nextInt(900000) + 100000;

    setState((){
      _sendOtp = otp.toString();
      _isPhoneVerified = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to $phone'),
        backgroundColor: chocolate,
        duration: const Duration(seconds: 5),
      )
    );

    _showOtpDialog(phone);
  }

 void _showOtpDialog(String phone) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text("Verify OTP", style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter the OTP sent to $phone", style: TextStyle(color: brown)),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter 6-digit OTP",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (otpController.text.trim()==_sendOtp){
                setState(() {
                  _isPhoneVerified = true;;
                  _sendOtp= null;
                }
              );
              }else{
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid OTP'),
              backgroundColor: Colors.red),
              );
              }
            },
            child: Text("Cancel", style: TextStyle(color: chocolate)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await supabase.auth.verifyOTP(
                  phone: phone,
                  token: otpController.text.trim(),
                  type: OtpType.sms,
                );
                
                if (response.session != null) {
                  // Verified. We sign out because we want to sign up with email/pass later.
                  await supabase.auth.signOut();
                  setState(() => _isPhoneVerified = true);
                  if (mounted) Navigator.pop(context);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid OTP"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  */

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_documentImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload document')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Signup
      final res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = res.user;
      if (user == null) throw Exception('Signup failed');

      // 2️⃣ Upload document
      final documentPath = await _uploadSellerDocument(user.id);

      // 3️⃣ Insert seller row
      await supabase.from('sellers').insert({
        'id': user.id, // ✅ FIXED
        'seller_name': _nameController.text.trim(),
        'seller_email': _emailController.text.trim(),
        'mobile_no': _phoneController.text.trim(),
        'company_name': _companyController.text.trim(),
        'document_type': _selectedDocType,
        'document_url': documentPath,
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'account_no': _accNoController.text.trim(),
        'gst_no': _gstController.text.trim(),
        'ifsc_code': _ifscController.text.trim(),
        'commission_rate': 0,
        'status': 'pending',
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful. Await admin approval'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Seller Registration", style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkBrown),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Personal Information"),
                const SizedBox(height: 16),
                _buildTextField(_nameController, "Full Name", Icons.person_outline,
                    validator: (value){
                      if (value == null || value.trim().isEmpty) {
                        return "Name is required";
                      }else{
                        return null;
                      }
                    }),
                const SizedBox(height: 16),
                _buildTextField(_emailController, "Email Address", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, "Password", Icons.lock_outline, isPassword: true),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTextField(_phoneController,
                        "Phone Number", Icons.phone_android_outlined,
                        validator:(value){
                        if (value == null || value.trim().isEmpty) {
                          return "Phone number is required";
                        }else if (value.trim().length != 10) {
                          return "Phone number must be 10 digits";
                        }else{
                          return null;
                        }},
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: TextInputType.phone,
                )
                    )
                    /*Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPhoneVerified ? Colors.green : chocolate,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isPhoneVerified 
                            ? const Icon(Icons.check_circle, color: Colors.white, size: 24)
                            : const Text("Verify", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    */
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionTitle("Business Details"),
                const SizedBox(height: 16),
                _buildTextField(_companyController, "Company/Store Name", Icons.store_outlined),
                const SizedBox(height: 16),
                _buildTextField(_gstController, "GST/Tax ID Number", Icons.badge_outlined,
                validator: (value){
                  if (value == null || value.trim().isEmpty) {
                    return "GST/Tax ID Number is required";
                  }else if (value.trim().length != 15) {
                    return "GST/Tax ID Number must be 15 digits";
                  }else{
                    return null;
                  }
                }, ),
                const SizedBox(height: 16),
                _buildTextField(_addressController, "Business Address", Icons.location_on_outlined, maxLines: 2),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_cityController, "City (e.g. Jalandhar)", Icons.location_city_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(_pincodeController, "Pincode", Icons.pin_drop_outlined, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionTitle("Bank Details"),
                const SizedBox(height: 16),
                _buildTextField(_accNoController, "Account Number", Icons.account_balance_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(_ifscController, "IFSC Code", Icons.code_outlined),
                const SizedBox(height: 32),
                _buildSectionTitle("Document Verification"),
                const SizedBox(height: 8),
                Column(
                  children: _docTypes.map((type) => RadioListTile<String>(
                    title: Text(type, style: TextStyle(color: darkBrown, fontSize: 14)),
                    value: type,
                    groupValue: _selectedDocType,
                    activeColor: chocolate,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      setState(() {
                        _selectedDocType = value!;
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 16),
                _buildImageUploadArea(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
        bool isPassword = false,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      obscureText: isPassword,
      inputFormatters: inputFormatters,
      style: TextStyle(color: darkBrown, fontWeight: FontWeight.w500),
      validator: validator ??
              (value) {
            if (value == null || value.trim().isEmpty) {
              return "$label is required";
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        labelStyle: TextStyle(color: brown, fontSize: 14),
        prefixIcon: Icon(icon, color: chocolate, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: chocolate.withOpacity(0.5), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }


  Widget _buildImageUploadArea() {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: chocolate.withOpacity(0.2), style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: _documentImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_documentImage!, fit: BoxFit.cover),
                    Container(color: Colors.black26),
                    const Center(child: Icon(Icons.edit, color: Colors.white, size: 40)),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: chocolate.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    "Upload $_selectedDocType",
                    style: TextStyle(color: brown, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tap to select image (PNG, JPG)",
                    style: TextStyle(color: brown.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Future<String> _uploadSellerDocument(String userId) async {
    if (_documentImage == null) {
      throw Exception('Document image not selected');
    }

    final fileExt = _documentImage!.path.split('.').last;

    final docName = _selectedDocType
        .toLowerCase()
        .replaceAll(' ', '_');

    // 🔑 CRITICAL: userId MUST be first folder
    final filePath = '$userId/$docName.$fileExt';

    final bytes = await _documentImage!.readAsBytes();

    await supabase.storage
        .from('seller-documents')
        .uploadBinary(
      filePath,
      bytes,
      fileOptions: FileOptions(
        contentType: 'image/$fileExt',
        upsert: false, // 🔒 IMPORTANT
      ),
    );

    return filePath;
  }



  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: chocolate,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Text(
                'CREATE ACCOUNT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
      ),
    );
  }
}
