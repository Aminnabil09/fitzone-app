import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import '../../services/admin_order_service.dart';
import '../../widgets/animated_background.dart';

class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'MANAGE ORDERS',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w200,
          letterSpacing: 4,
          fontSize: 14,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return StreamBuilder<List<AdminOrder>>(
      stream: AdminOrderService().streamGlobalOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                'NO ORDERS YET',
                style: GoogleFonts.outfit(
                  color: AppTheme.textColor.withValues(alpha: 0.5),
                  letterSpacing: 2,
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final order = orders[index];
                return _buildOrderTile(context, order);
              },
              childCount: orders.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderTile(BuildContext context, AdminOrder order) {
    final int totalItemsCount = order.items.fold(0, (total, item) {
      final q = item is Map ? (item['quantity'] ?? 1) : 1;
      return total + (q as int);
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.02),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER #${order.id.substring(0, 8).toUpperCase()}',
                    style: GoogleFonts.outfit(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      '$totalItemsCount ITEMS',
                      style: GoogleFonts.outfit(
                        color: AppTheme.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: AppTheme.textColor.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Expanded(
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(order.userId).get(),
                  builder: (context, snapshot) {
                    final data = (snapshot.hasData && snapshot.data!.exists)
                        ? snapshot.data!.data() as Map<String, dynamic>
                        : null;
                    
                    String displayName = 'GUEST';
                    String? nId;

                    if (data != null) {
                      displayName = data['name'] ?? data['displayName'] ?? data['email'] ?? 'GUEST';
                      nId = data['numericId']?.toString();
                    } else if (snapshot.connectionState == ConnectionState.waiting) {
                      displayName = 'LOADING...';
                    }

                    // Professional formatting: NAME (ID: 100XX)
                    final String displayString = nId != null 
                      ? '${displayName.toUpperCase()} (ID: $nId)' 
                      : displayName.toUpperCase();

                    return Text(
                      'CUSTOMER: $displayString',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'ORDER SUMMARY:',
            style: GoogleFonts.outfit(
              color: AppTheme.textColor.withValues(alpha: 0.5),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) {
            final name = item is Map ? (item['name'] ?? 'Unknown Item') : 'Item';
            final quantity = item is Map ? (item['quantity'] ?? 1) : 1;
            final price = item is Map ? (item['price'] ?? 0.0) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '• $quantity x $name',
                      style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 13),
                    ),
                  ),
                  Text(
                    '\$${(price * quantity).toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 24, thickness: 0.5, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL PRICE',
                style: GoogleFonts.outfit(
                  color: AppTheme.textColor.withValues(alpha: 0.5),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusDropdown(context, order),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, AdminOrder order) {
    const statuses = ['pending', 'shipped', 'delivered', 'cancelled'];
    return DropdownButtonFormField<String>(
      initialValue: statuses.contains(order.status) ? order.status : 'pending',
      dropdownColor: AppTheme.surfaceColor,
      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
      decoration: InputDecoration(
        labelText: 'UPDATE STATUS',
        labelStyle: GoogleFonts.outfit(
          color: AppTheme.textColor.withValues(alpha: 0.5),
          fontSize: 10,
          letterSpacing: 2,
        ),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textColor.withValues(alpha: 0.2))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryColor)),
      ),
      style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 14),
      items: statuses.map((s) {
        return DropdownMenuItem<String>(
          value: s,
          child: Text(s.toUpperCase(), style: GoogleFonts.outfit(color: AppTheme.textColor)),
        );
      }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null && newStatus != order.status) {
          AdminOrderService().updateOrderStatus(order.id, newStatus);
        }
      },
    );
  }
}
