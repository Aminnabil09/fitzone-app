import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../services/locale_service.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../services/product_service.dart';
import '../widgets/animated_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Check and seed product database if necessary and load products
    await ProductService().seedDatabaseIfEmpty();
    await ProductService().loadProducts();

    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Load user profile first, then products (so CartService can resolve product IDs),
      // then cart & wishlist which depend on the loaded product catalog.
      await AuthService().loadUserProfile();
      await ProductService().loadProducts(); // ensure catalog is ready before cart lookup
      await CartService().loadCart();
      await WishlistService().loadWishlist();
      if (mounted) {
        if (AuthService().isAdmin) {
          Navigator.of(context).pushReplacementNamed('/admin_dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } else {
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _logoScaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 60),
                  _buildBrandName(),
                  const SizedBox(height: 12),
                  _buildTagline(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 0.5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'F',
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.w100,
                  color: AppTheme.primaryColor,
                  height: 1.0,
                ),
              ),
              Container(
                width: 20,
                height: 0.3,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
              Text(
                LocaleService().translate('Z'),
                style: LocaleService().getTextStyle(
                  baseStyle: GoogleFonts.outfit(
                    fontSize: 48,
                    fontWeight: FontWeight.w100,
                    color: AppTheme.primaryColor,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandName() {
    return Text(
      LocaleService().translate('FITZONE'),
      style: LocaleService().getTextStyle(
        baseStyle: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w200,
          letterSpacing: 12,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      LocaleService().translate('THE ART OF PERFORMANCE'),
      style: LocaleService().getTextStyle(
        baseStyle: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 4,
          color: AppTheme.primaryColor.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
