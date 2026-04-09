import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../services/wishlist_service.dart';
import '../services/review_service.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WishlistService(),
      builder: (context, child) {
        final isFav = WishlistService().isFavorite(product.id);
        return Hero(
          tag: 'product_${product.id}',
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: AppTheme.surfaceColor,
                            child: Icon(Icons.fitness_center,
                                color: AppTheme.textColor.withValues(alpha: 0.24),
                                size: 40),
                          ),
                        ),
                        // Price tag
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            color: AppTheme.backgroundColor.withValues(alpha: 0.8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Text(
                              '\$${product.price.toStringAsFixed(0)}',
                              style: GoogleFonts.outfit(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        // Favorite Indicator
                        if (isFav)
                          const Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.favorite,
                              color: AppTheme.primaryColor,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Product Info
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.category.toUpperCase(),
                            style: GoogleFonts.outfit(
                              color: AppTheme.primaryColor.withValues(alpha: 0.5),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          StreamBuilder<double>(
                            stream: ReviewService().streamAverageRating(product.id),
                            builder: (context, snapshot) {
                              final rating = snapshot.data ?? 0.0;
                              if (rating == 0) return const SizedBox.shrink();
                              return Row(
                                children: [
                                  const Icon(Icons.star, color: AppTheme.primaryColor, size: 10),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
