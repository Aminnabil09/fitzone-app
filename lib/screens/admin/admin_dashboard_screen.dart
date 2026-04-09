import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../services/admin_order_service.dart';
import '../../services/support_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/animated_background.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ProductService(), AdminOrderService(), SupportService()]),
      builder: (context, child) {
        return Scaffold(
          body: AnimatedBackground(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                _buildWelcomeHeader(),
                _buildStatCards(),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                _buildActionButtons(context),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'ADMIN PANEL',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w200,
          letterSpacing: 8,
          fontSize: 18,
          color: AppTheme.textColor,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: AppTheme.textColor, size: 20),
          onPressed: () async {
            await AuthService().logout();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WELCOME BACK,',
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AuthService().userName.isNotEmpty ? AuthService().userName.toUpperCase() : 'ADMINISTRATOR',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w200,
                color: AppTheme.textColor,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatCard(
              'TOTAL PRODUCTS',
              ProductService().products.length.toString(),
              Icons.inventory_2_outlined,
              width: 160,
            ),
            StreamBuilder<List<AdminOrder>>(
              stream: AdminOrderService().streamGlobalOrders(),
              builder: (context, snapshot) {
                final count = snapshot.hasData ? snapshot.data!.length.toString() : '...';
                return _buildStatCard(
                  'TOTAL ORDERS',
                  count,
                  Icons.shopping_bag_outlined,
                  width: 160,
                );
              },
            ),
            _buildStatCard(
              'TOTAL REVENUE',
              '\$${AdminOrderService().totalRevenue.toStringAsFixed(0)}',
              Icons.attach_money_outlined,
              width: 160,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'user').snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.hasData ? snapshot.data!.docs.length.toString() : '...';
                return _buildStatCard(
                  'TOTAL CUSTOMERS',
                  count,
                  Icons.people_alt_outlined,
                  width: 160,
                );
              },
            ),
            StreamBuilder<int>(
              stream: SupportService().streamPendingCount(),
              builder: (context, snapshot) {
                final count = snapshot.hasData ? snapshot.data.toString() : '...';
                return _buildStatCard(
                  'PENDING REPORTS',
                  count,
                  Icons.mark_chat_unread_outlined,
                  width: 160,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {double? width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.02),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w200,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textColor.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            _buildActionRow(
              context,
              'MANAGE PRODUCTS',
              'Add, edit, or remove inventory',
              Icons.sell_outlined,
              '/manage_products',
            ),
            const SizedBox(height: 16),
            _buildActionRow(
              context,
              'MANAGE ORDERS',
              'Update order shipping status',
              Icons.local_shipping_outlined,
              '/manage_orders',
            ),
            const SizedBox(height: 16),
            _buildActionRow(
              context,
              'MANAGE CUSTOMERS',
              'View and manage registered users',
              Icons.people_outline,
              '/manage_customers',
            ),
            const SizedBox(height: 16),
            _buildActionRow(
              context,
              'MANAGE REPORTS',
              'Answer customer feedback',
              Icons.question_answer_outlined,
              '/manage_reports',
            ),
            const SizedBox(height: 32),
            _buildVerifyStorageButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyStorageButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('INITIATING CLOUD STORAGE CONNECTION TEST...'),
            duration: Duration(seconds: 2),
          ),
        );
        
        final url = await StorageService().uploadTestFile();
        
        if (context.mounted) {
          if (url != null) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.surfaceColor,
                title: Text('CONNECTION SUCCESSFUL', style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.bold)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TEST FILE UPLOADED SUCCESSFULLY TO:', style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 12)),
                    const SizedBox(height: 8),
                    SelectableText(url, style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontSize: 10)),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('DONE')),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('CONNECTION FAILED. CHECK FIREBASE CONSOLE RULES.'), backgroundColor: Colors.redAccent),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_done_outlined, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 12),
            Text(
              'VERIFY CLOUD STORAGE',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, String title, String subtitle, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.textColor.withValues(alpha: 0.02),
          border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: AppTheme.textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppTheme.textColor.withValues(alpha: 0.3), size: 16),
          ],
        ),
      ),
    );
  }
}
