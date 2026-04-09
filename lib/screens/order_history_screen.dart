import '../services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/app_theme.dart';
import '../services/locale_service.dart';
import '../widgets/animated_background.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final Set<String> _expandedOrders = {};

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleService(), ThemeService()]),
      builder: (context, child) {
        return Scaffold(
          body: AnimatedBackground(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                _buildOrdersFromFirestore(),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        LocaleService().translate('ORDER HISTORY'),
        style: LocaleService().getTextStyle(
          baseStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w200, letterSpacing: 8, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildOrdersFromFirestore() {
    if (_uid.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(48),
                child: Text('PLEASE LOG IN TO VIEW YOUR ORDERS'))),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(64),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          color: AppTheme.textColor.withValues(alpha: 0.2), size: 48),
                      const SizedBox(height: 16),
                      Text('NO ORDERS YET',
                          style: GoogleFonts.outfit(
                              color: AppTheme.textColor.withValues(alpha: 0.3),
                              letterSpacing: 4,
                              fontSize: 12)),
                    ],
                  ),
                ),
              ),
            );
          }

          final orders = snapshot.data!.docs;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildOrderCard(context, orders[index], index),
              childCount: orders.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, QueryDocumentSnapshot doc, int index) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? 'PROCESSING';
    final total = (data['totalPrice'] ?? 0.0).toStringAsFixed(2);
    final items = (data['items'] as List?) ?? [];
    final ts = data['createdAt'] as Timestamp?;
    final date = ts != null
        ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
        : 'PENDING';
    final orderId = doc.id.substring(0, 8).toUpperCase();
    final isExpanded = _expandedOrders.contains(doc.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.01),
        border: Border.all(
            color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: Column(
        children: [
          // ─── ORDER HEADER ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ORDER #FZ-$orderId',
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: status == 'PROCESSING'
                                ? AppTheme.primaryColor
                                : AppTheme.textColor.withValues(alpha: 0.24),
                            width: 0.5),
                      ),
                      child: Text(status,
                          style: GoogleFonts.outfit(
                            color: status == 'PROCESSING'
                                ? AppTheme.primaryColor
                                : AppTheme.textColor.withValues(alpha: 0.24),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildOrderDetail('DATE', date),
                    _buildOrderDetail('TOTAL', '\$$total'),
                    _buildOrderDetail('ITEMS', items.length.toString()),
                  ],
                ),
                const SizedBox(height: 20),
                // ─── EXPAND / COLLAPSE BUTTON ──────────────────────────
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedOrders.remove(doc.id);
                      } else {
                        _expandedOrders.add(doc.id);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTheme.textColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isExpanded ? 'HIDE ITEMS' : 'VIEW ORDER ITEMS',
                          style: GoogleFonts.outfit(
                              color: AppTheme.primaryColor,
                              fontSize: 10,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppTheme.primaryColor,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── ORDER ITEMS (expanded) ────────────────────────────────────
          if (isExpanded) ...[
            Container(
              height: 0.5,
              color: AppTheme.textColor.withValues(alpha: 0.05),
            ),
            ...items.map((item) {
              final itemData = item as Map<String, dynamic>;
              return _buildOrderItem(itemData);
            }),
            // TRACK button at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showTrackingDialog(context, status),
                  style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: AppTheme.textColor.withValues(alpha: 0.1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('TRACK SHIPMENT',
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor,
                          fontSize: 10,
                          letterSpacing: 2)),
                ),
              ),
            ),
          ] else ...[
            // Collapsed — just show track button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showTrackingDialog(context, status),
                  style: OutlinedButton.styleFrom(
                    side:
                        BorderSide(color: AppTheme.textColor.withValues(alpha: 0.1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('TRACK SHIPMENT',
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor,
                          fontSize: 10,
                          letterSpacing: 2)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              color: AppTheme.textColor.withValues(alpha: 0.04), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.textColor.withValues(alpha: 0.05),
              image: item['imageUrl'] != null && item['imageUrl'].isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item['imageUrl']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item['imageUrl'] == null || item['imageUrl'].isEmpty
                ? Icon(Icons.image_not_supported_outlined,
                    color: AppTheme.textColor.withValues(alpha: 0.2), size: 20)
                : null,
          ),
          const SizedBox(width: 16),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (item['name'] ?? 'PRODUCT').toString().toUpperCase(),
                  style: GoogleFonts.outfit(
                      color: AppTheme.textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (item['size'] != null && item['size'].isNotEmpty)
                      Text('SIZE ${item['size']}   ',
                          style: GoogleFonts.outfit(
                              color: AppTheme.textColor.withValues(alpha: 0.4),
                              fontSize: 9,
                              letterSpacing: 1)),
                    if (item['color'] != null && item['color'].isNotEmpty)
                      Text('${item['color']}',
                          style: GoogleFonts.outfit(
                              color: AppTheme.textColor.withValues(alpha: 0.4),
                              fontSize: 9,
                              letterSpacing: 1)),
                  ],
                ),
              ],
            ),
          ),
          // Qty & price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'x${item['quantity'] ?? 1}',
                style: GoogleFonts.outfit(
                    color: AppTheme.textColor.withValues(alpha: 0.5),
                    fontSize: 10,
                    letterSpacing: 1),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${((item['price'] ?? 0.0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                style: GoogleFonts.outfit(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                color: AppTheme.textColor.withValues(alpha: 0.24),
                fontSize: 8,
                letterSpacing: 2)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.outfit(
                color: AppTheme.textColor,
                fontSize: 12,
                fontWeight: FontWeight.w300)),
      ],
    );
  }

  void _showTrackingDialog(BuildContext context, String status) {
    final isProcessing = status == 'PROCESSING';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('TRACKING STATUS',
            style: GoogleFonts.outfit(
                color: AppTheme.textColor,
                fontSize: 14,
                letterSpacing: 4,
                fontWeight: FontWeight.w200)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTrackingStep('ORDER PROCESSED', true),
            _buildTrackingLine(),
            _buildTrackingStep('QUALITY INSPECTION', true),
            _buildTrackingLine(),
            _buildTrackingStep('OUT FOR DELIVERY', !isProcessing),
            _buildTrackingLine(),
            _buildTrackingStep(
                'ARRIVED AT DESTINATION', status == 'DELIVERED'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CLOSE',
                style: GoogleFonts.outfit(
                    color: AppTheme.primaryColor,
                    fontSize: 10,
                    letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(String title, bool completed) {
    return Row(
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: completed
              ? AppTheme.primaryColor
              : AppTheme.textColor.withValues(alpha: 0.24),
          size: 16,
        ),
        const SizedBox(width: 16),
        Text(title,
            style: GoogleFonts.outfit(
              color: completed
                  ? Colors.white
                  : AppTheme.textColor.withValues(alpha: 0.24),
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: completed ? FontWeight.w500 : FontWeight.w200,
            )),
      ],
    );
  }

  Widget _buildTrackingLine() {
    return Container(
        margin: const EdgeInsets.only(left: 7.5),
        height: 20,
        width: 0.5,
        color: AppTheme.textColor.withValues(alpha: 0.12));
  }
}
