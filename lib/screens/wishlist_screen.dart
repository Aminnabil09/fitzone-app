import '../utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/locale_service.dart';
import '../services/wishlist_service.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/animated_background.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistService = WishlistService();
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleService(), wishlistService, ProductService()]),
      builder: (context, child) {
        final allProducts = ProductService().products;
        final wishlistProducts =
            allProducts.where((p) => wishlistService.isFavorite(p.id)).toList();

        return Scaffold(
          body: AnimatedBackground(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                wishlistProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductGrid(context, wishlistProducts),
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
        icon:
            Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        LocaleService().translate('MY ARCHIVE'),
        style: LocaleService().getTextStyle(
          baseStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w200,
            letterSpacing: 8,
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
            Icon(Icons.favorite_border_rounded,
                size: 48, color: AppTheme.textColor.withValues(alpha: 0.1)),
            const SizedBox(height: 32),
            Text(
              LocaleService().translate('ARCHIVE IS EMPTY'),
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

  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
            );
          },
          childCount: products.length,
        ),
      ),
    );
  }
}
