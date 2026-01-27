import 'package:flutter/material.dart';
import 'package:shoppy_appy/auth/seller_register_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _gstController = TextEditingController();

  String _selectedRole = 'user'; // 'user' or 'seller'
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Color Palette
  final Color backgroundColor = const Color(0xFFFDF8F5);
  final Color lightBeige = const Color(0xFFF3E9E1);
  final Color mediumBeige = const Color(0xFFEADBC8);
  final Color brown = const Color(0xFFB08968);
  final Color darkBrown = const Color(0xFF5F372B);
  final Color chocolate = const Color(0xFF915F41);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _gstController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() => _isLoading = true);

      // Simulated Backend Logic
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful! (Simulated)'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(20),
          ),
        );
        Navigator.pop(context); // Go back to login
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          _buildBackgroundDecorations(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new_rounded,
                              color: darkBrown),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 30),
                        _buildHeader(),
                        const SizedBox(height: 40),
                        _buildRegisterForm(),
                        const SizedBox(height: 40),
                        _buildFooter(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [lightBeige.withOpacity(0.4), backgroundColor],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: darkBrown,
            letterSpacing: -1,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: chocolate,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Join us and start your premium shopping experience.',
          style: TextStyle(
            fontSize: 16,
            color: brown.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: brown.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _nameController,
              hint: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              hint: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email is required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
              isVisible: _isPasswordVisible,
              onVisibilityToggle: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Password is required';
                if (value.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),

            const SizedBox(height: 40),
            _buildRegisterButton(),
            const SizedBox(height: 20),
            _buildSocialLogin()
          ],
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      style: TextStyle(color: darkBrown, fontWeight: FontWeight.w600),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: brown.withOpacity(0.4), fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, color: chocolate, size: 22),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(isVisible ? Icons.visibility_rounded : Icons
              .visibility_off_rounded, color: brown.withOpacity(0.6), size: 20),
          onPressed: onVisibilityToggle,
        )
            : null,
        filled: true,
        fillColor: backgroundColor.withOpacity(0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: mediumBeige, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 18, horizontal: 20),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: chocolate,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(height: 24,
            width: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.white))
            : const Text('CREATE ACCOUNT', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: brown.withOpacity(0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('or continue with', style: TextStyle(
                  color: brown.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
            ),
            Expanded(child: Divider(color: brown.withOpacity(0.2))),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(Icons.g_mobiledata),
            const SizedBox(width: 20),
            _buildSocialButton(Icons.apple),
          ],
        ),
        const SizedBox(height: 25),
        _sellerblock()
      ],
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lightBeige),
        ),
        child: Icon(icon, size: 32, color: chocolate),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? ",
            style: TextStyle(color: brown, fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            "Login",
            style: TextStyle(color: chocolate,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }

  Widget _sellerblock() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SellerRegisterScreen()),
              ),
              child: Text(
                  "Register as a Seller",
                  style: TextStyle(color: chocolate,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  )
              )
          )
        ]
    );
  }
}
