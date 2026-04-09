import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_card.dart';
import '../widgets/animated_background.dart';
import '../services/locale_service.dart';
import 'product_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<String> _categories = const [
    'Gym & Fitness',
    'Football',
    'Basketball',
    'Running',
    'Clothing',
    'Shoes',
    'Accessories',
    'Equipment',
    'Nutrition',
    'Outdoor & Adventure',
    'Yoga & Wellness',
    'Kids & Youth',
    'Boxing & Combat',
    'Deals & Collections',
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Gym & Fitness': return Icons.fitness_center;
      case 'Football': return Icons.sports_soccer;
      case 'Basketball': return Icons.sports_basketball;
      case 'Running': return Icons.directions_run;
      case 'Clothing': return Icons.checkroom;
      case 'Shoes': return Icons.shopping_bag;
      case 'Accessories': return Icons.watch;
      case 'Equipment': return Icons.sports;
      case 'Nutrition': return Icons.restaurant;
      case 'Outdoor & Adventure': return Icons.landscape;
      case 'Yoga & Wellness': return Icons.self_improvement;
      case 'Kids & Youth': return Icons.child_care;
      case 'Boxing & Combat': return Icons.sports_mma;
      case 'Deals & Collections': return Icons.local_offer;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService(),
      builder: (context, child) {
        return Scaffold(
          body: AnimatedBackground(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = _categories[index];
                        return _buildCategoryCard(context, category);
                      },
                      childCount: _categories.length,
                    ),
                  ),
                ),
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
        LocaleService().translate('COLLECTIONS'),
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

  Widget _buildCategoryCard(BuildContext context, String category) {
    return GestureDetector(
      onTap: () {
        final products = ProductService().products
            .where((p) => p.category == category)
            .toList();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryProductsScreen(
              category: category,
              products: products.isEmpty ? ProductService().products : products,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.textColor.withValues(alpha: 0.02),
          border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 28,
              color: AppTheme.primaryColor.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              LocaleService().translate(category).toUpperCase(),
              textAlign: TextAlign.center,
              style: LocaleService().getTextStyle(
                baseStyle: GoogleFonts.outfit(
                  color: AppTheme.textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProductsScreen extends StatelessWidget {
  final String category;
  final List<Product> products;

  const CategoryProductsScreen({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                category.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontSize: 20,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => ProductCard(
                    product: products[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            product: products[index],
                          ),
                        ),
                      );
                    },
                  ),
                  childCount: products.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

