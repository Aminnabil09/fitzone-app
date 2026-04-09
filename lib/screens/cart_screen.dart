import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_theme.dart';
import '../services/cart_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../widgets/animated_background.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

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
                _buildAppBar(),
                _cartService.items.isEmpty
                    ? _buildEmptyState()
                    : _buildCartList(),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
          extendBody: true,
          bottomNavigationBar: _cartService.items.isEmpty ? null : _buildCheckoutSheet(),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        LocaleService().translate('BAG'),
        style: LocaleService().getTextStyle(
          baseStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w200,
            letterSpacing: 12,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 48, color: AppTheme.textColor.withValues(alpha: 0.10)),
            const SizedBox(height: 32),
            Text(
              LocaleService().translate('EMPTY COLLECTION'),
              style: LocaleService().getTextStyle(
                baseStyle: GoogleFonts.outfit(
                  color: AppTheme.textColor.withValues(alpha: 0.24),
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList() {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = _cartService.items[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
                      ),
                      child: Image.network(
                        item.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.fitness_center, color: AppTheme.textColor.withValues(alpha: 0.10)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textColor,
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildVariantBadge('SIZE', item.selectedSize),
                              const SizedBox(width: 12),
                              _buildVariantBadge('FINISH', item.selectedColor, isColor: true),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '\$${item.product.price.toStringAsFixed(0)}',
                            style: GoogleFonts.outfit(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildQuantityControl(item),
                  ],
                ),
              ),
            );
          },
          childCount: _cartService.items.length,
        ),
      ),
    );
  }

  Widget _buildVariantBadge(String label, String value, {bool isColor = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.05),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.24), fontSize: 8, letterSpacing: 1),
          ),
          if (isColor)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: _getColorFromString(value),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.24), width: 0.5),
              ),
            )
          else
            Text(
              value,
              style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Color _getColorFromString(String color) {
    switch (color.toLowerCase()) {
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'teal': return Colors.teal;
      case 'cream': return const Color(0xFFF5F5DC);
      case 'silver': return Colors.grey;
      case 'gold': return const Color(0xFFFFD700);
      default: return Colors.grey;
    }
  }

  Widget _buildQuantityControl(CartItem item) {
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() => _cartService.updateQuantity(item, item.quantity - 1)),
          icon: Icon(Icons.remove, color: AppTheme.textColor.withValues(alpha: 0.38), size: 14),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        Text(
          '${item.quantity}',
          style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 14, fontWeight: FontWeight.w400),
        ),
        IconButton(
          onPressed: () => setState(() => _cartService.updateQuantity(item, item.quantity + 1)),
          icon: const Icon(Icons.add, color: AppTheme.primaryColor, size: 14),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }

  Widget _buildCheckoutSheet() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleService().translate('TOTAL'),
                style: GoogleFonts.outfit(
                  color: AppTheme.textColor.withValues(alpha: 0.24),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${_cartService.totalPrice.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  color: AppTheme.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _showCheckoutSheet(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: Text(LocaleService().translate('PURCHASE')),
          ),
        ],
      ),
    );
  }

  // ─── CHECKOUT SHEET WITH ADDRESS + CARD ──────────────────────────────────
  Future<void> _showCheckoutSheet(BuildContext context) async {
    final authService = AuthService();
    final docId = authService.currentNumericId ?? authService.userId;
    Map<String, dynamic>? address;
    Map<String, dynamic>? card;

    if (docId.isNotEmpty) {
      final db = FirebaseFirestore.instance;
      // Load default address from the unified Numeric ID document
      final addrSnap = await db
          .collection('users').doc(docId).collection('addresses')
          .where('isDefault', isEqualTo: true).limit(1).get();
      if (addrSnap.docs.isNotEmpty) {
        address = addrSnap.docs.first.data();
      }
      // Load primary card from the unified Numeric ID document
      final cardSnap = await db
          .collection('users').doc(docId).collection('payment_methods')
          .where('isDefault', isEqualTo: true).limit(1).get();
      if (cardSnap.docs.isNotEmpty) {
        card = cardSnap.docs.first.data();
      }
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ORDER SUMMARY',
                style: GoogleFonts.outfit(
                    color: AppTheme.textColor,
                    fontSize: 14,
                    letterSpacing: 6,
                    fontWeight: FontWeight.w200)),
            const SizedBox(height: 24),

            // Items count + total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${_cartService.items.length} ITEM(S)',
                    style: GoogleFonts.outfit(
                        color: AppTheme.textColor.withValues(alpha: 0.5),
                        fontSize: 10,
                        letterSpacing: 2)),
                Text(
                  '\$${_cartService.totalPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                      color: AppTheme.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Container(height: 0.5, color: AppTheme.textColor.withValues(alpha: 0.08)),
            const SizedBox(height: 20),

            // Delivery address
            _checkoutSection(
              icon: Icons.location_on_outlined,
              label: 'DELIVERY ADDRESS',
              value: address != null
                  ? '${address['fullName']}\n${address['street']}, ${address['city']}'
                  : 'NO DEFAULT ADDRESS SET',
              isEmpty: address == null,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/address');
              },
            ),

            const SizedBox(height: 16),

            // Payment method
            _checkoutSection(
              icon: Icons.credit_card_outlined,
              label: 'PAYMENT METHOD',
              value: card != null
                  ? '${card['cardType']} •••• ${card['last4']}'
                  : 'NO DEFAULT CARD SET',
              isEmpty: card == null,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/payment');
              },
            ),

            const SizedBox(height: 32),

            // Place order button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (address == null || card == null)
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        _showSuccessDialog(context);
                      },
                child: Text(
                  address == null || card == null
                      ? 'ADD ADDRESS & CARD FIRST'
                      : 'CONFIRM ORDER',
                  style: GoogleFonts.outfit(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkoutSection({
    required IconData icon,
    required String label,
    required String value,
    required bool isEmpty,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEmpty
                ? Colors.redAccent.withValues(alpha: 0.3)
                : AppTheme.textColor.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: isEmpty
                    ? Colors.redAccent.withValues(alpha: 0.5)
                    : AppTheme.primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.outfit(
                          color: AppTheme.textColor.withValues(alpha: 0.4),
                          fontSize: 8,
                          letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                        color: isEmpty
                            ? Colors.redAccent.withValues(alpha: 0.6)
                            : AppTheme.textColor,
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Icon(
              isEmpty ? Icons.add_circle_outline : Icons.chevron_right,
              color: AppTheme.textColor.withValues(alpha: 0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final authService = AuthService();
    final docId = authService.currentNumericId ?? authService.userId;
    if (docId.isEmpty) return;
    
    final navigator = Navigator.of(context); // capture before await gap

    final orderItems = _cartService.items.map((item) => {
      'productId': item.product.id,
      'name': item.product.name,
      'imageUrl': item.product.imageUrl,
      'price': item.product.price,
      'quantity': item.quantity,
      'size': item.selectedSize,
      'color': item.selectedColor,
    }).toList();

    // Standardize: Save under the user's professional Numeric ID document consistently
    await FirebaseFirestore.instance
        .collection('users')
        .doc(docId)
        .collection('orders')
        .add({
      'userId': authService.userId, // Keep Auth UID inside for indexing consistency if needed
      'userNumericId': authService.currentNumericId ?? 'N/A',
      'items': orderItems,
      'totalPrice': _cartService.totalPrice,
      'status': 'PROCESSING',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() => _cartService.clearCart());
    if (mounted) navigator.pop();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          LocaleService().translate('SUCCESS').toUpperCase(),
          style: GoogleFonts.outfit(color: AppTheme.primaryColor, letterSpacing: 4, fontSize: 18),
        ),
        content: Text(
          'YOUR ACQUISITION IS BEING PREPARED FOR DISPATCH.',
          style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => _placeOrder(ctx),
            child: Text(
              'CONFIRM',
              style: GoogleFonts.outfit(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
