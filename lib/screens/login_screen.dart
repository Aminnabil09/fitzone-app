import '../services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';
import '../services/locale_service.dart';
import '../widgets/animated_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    final error = await AuthService().login(
      _emailController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      _emailController.clear();
      _passwordController.clear();
      if (AuthService().isAdmin) {
        Navigator.of(context).pushReplacementNamed('/admin_dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    final error = await AuthService().signUp(
      _emailController.text,
      _passwordController.text,
      _nameController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      if (AuthService().isAdmin) {
        Navigator.of(context).pushReplacementNamed('/admin_dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'ENTER YOUR EMAIL ABOVE FIRST.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'RESET LINK SENT TO $email',
            style: GoogleFonts.outfit(
                fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message ?? 'ERROR');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleService(), ThemeService()]),
      builder: (context, child) {
        return Scaffold(
          body: AnimatedBackground(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 64),
                        _buildLoginCard(),
                        const SizedBox(height: 48),
                        _buildSocialLogin(),
                        const SizedBox(height: 32),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'F',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w100,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Container(
                  width: 16,
                  height: 0.5,
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
                Text(
                  'Z',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w100,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          LocaleService().translate('FITZONE'),
          style: LocaleService().getTextStyle(
            baseStyle: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w200,
              letterSpacing: 12,
              color: AppTheme.textColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          LocaleService().translate('THE ARCHIVE'),
          style: LocaleService().getTextStyle(
            baseStyle: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 4,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error banner
            if (_errorMessage != null) ...
              [
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 10, letterSpacing: 1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            // Name field (sign up only)
            if (_isSignUp) ...
              [
                _buildTextField(
                  controller: _nameController,
                  label: 'FULL NAME',
                  hint: 'Your name',
                  icon: Icons.person_outline,
                  validator: (v) => v == null || v.isEmpty ? 'REQUIRED' : null,
                ),
                const SizedBox(height: 32),
              ],
            _buildTextField(
              controller: _emailController,
              label: LocaleService().translate('IDENTIFICATION'),
              hint: 'Email address',
              icon: Icons.alternate_email,
              validator: (value) {
                if (value == null || value.isEmpty) return 'REQUIRED';
                if (!value.contains('@')) return 'INVALID EMAIL';
                return null;
              },
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _passwordController,
              label: LocaleService().translate('SECURITY KEY'),
              hint: 'Passphrase',
              icon: Icons.lock_outline,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) return 'REQUIRED';
                if (_isSignUp && value.length < 6) return 'MIN 6 CHARACTERS';
                return null;
              },
            ),
            // Forgot password (sign in mode only)
            if (!_isSignUp) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _isLoading ? null : _handleForgotPassword,
                  child: Text(
                    'FORGOT PASSWORD?',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primaryColor.withValues(alpha: 0.6),
                      fontSize: 9,
                      letterSpacing: 2,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _isLoading ? null : (_isSignUp ? _handleSignUp : _handleLogin),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: _isLoading
                      ? AppTheme.primaryColor.withValues(alpha: 0.5)
                      : AppTheme.primaryColor,
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                        )
                      : Text(
                          _isSignUp ? 'CREATE ACCOUNT' : LocaleService().translate('AUTHENTICATE'),
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isSignUp = !_isSignUp;
                    _errorMessage = null;
                  });
                },
                child: Text(
                  _isSignUp ? 'ALREADY HAVE AN ACCOUNT? SIGN IN' : 'NEW HERE? CREATE AN ACCOUNT',
                  style: GoogleFonts.outfit(
                    color: AppTheme.primaryColor.withValues(alpha: 0.6),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primaryColor.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 4,
            color: AppTheme.textColor.withValues(alpha: 0.24),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: GoogleFonts.inter(
              color: AppTheme.textColor, fontSize: 14, letterSpacing: 1),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                color: AppTheme.textColor.withValues(alpha: 0.12), fontSize: 14),
            prefixIcon: Icon(icon,
                size: 18, color: AppTheme.textColor.withValues(alpha: 0.24)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.02),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                  color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                  color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 0.5),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(context, Icons.apple, 'APPLE ID'),
        const SizedBox(width: 32),
        _buildSocialIcon(context, Icons.g_mobiledata_rounded, 'GOOGLE ACCOUNT'),
      ],
    );
  }

  Widget _buildSocialIcon(
      BuildContext context, IconData icon, String platform) {
    return GestureDetector(
      onTap: () => _showFeedback(context, '$platform AUTHENTICATION INITIATED'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(
              color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
        ),
        child:
            Icon(icon, color: AppTheme.textColor.withValues(alpha: 0.24), size: 24),
      ),
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.outfit(
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: Colors.black),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(24),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'SECURED BY FITZONE CRYPTOGRAPHY',
          style: GoogleFonts.outfit(
            fontSize: 8,
            letterSpacing: 2,
            color: AppTheme.textColor.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }
}
