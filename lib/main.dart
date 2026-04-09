import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/wishlist_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/delivery_address_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/auth_settings_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/manage_products_screen.dart';
import 'screens/admin/product_form_screen.dart';
import 'screens/admin/manage_orders_screen.dart';
import 'screens/admin/manage_customers_screen.dart';
import 'screens/admin/manage_reports_screen.dart';
import 'screens/support_screen.dart';
import 'utils/app_theme.dart';
import 'services/locale_service.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const FitZoneApp());
}

class FitZoneApp extends StatelessWidget {
  const FitZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeService = LocaleService();
    final themeService = ThemeService();
    
    return ListenableBuilder(
      listenable: Listenable.merge([localeService, themeService]),
      builder: (context, child) {
        return MaterialApp(
          title: 'FitZone',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          locale: localeService.currentLocale,
          builder: (context, child) {
            return Directionality(
              textDirection:
                  localeService.isRTL ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/admin_dashboard': (context) => const AdminDashboardScreen(),
            '/manage_products': (context) => const ManageProductsScreen(),
            '/product_form': (context) => const ProductFormScreen(),
            '/manage_orders': (context) => const ManageOrdersScreen(),
            '/manage_customers': (context) => const ManageCustomersScreen(),
            '/categories': (context) => const CategoriesScreen(),
            '/cart': (context) => const CartScreen(),
            '/chat': (context) => const ChatScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/wishlist': (context) => const WishlistScreen(),
            '/order_history': (context) => const OrderHistoryScreen(),
            '/address': (context) => const AddressScreen(),
            '/payment': (context) => const PaymentMethodsScreen(),
            '/auth_settings': (context) => const AuthSettingsScreen(),
            '/support': (context) => const SupportScreen(),
            '/manage_reports': (context) => const AdminManageReportsScreen(),
          },
        );
      },
    );
  }
}
