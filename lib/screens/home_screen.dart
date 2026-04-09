import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_background.dart';
import '../widgets/product_card.dart';
import '../widgets/carousel_banner.dart';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/locale_service.dart';
import '../services/theme_service.dart';
import 'product_detail_screen.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _gridController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _gridController.forward();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  List<Product> _getFilteredProducts() {
    final allProducts = ProductService().products;
    return allProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategory == 'ALL' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    _gridController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([LocaleService(), ThemeService(), AuthService(), CartService(), ProductService()]),
      builder: (context, child) {
        return Scaffold(
          body: AnimatedBackground(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                _buildSearchBar(),
                _buildPromoBanner(),
                _buildSectionHeader(LocaleService().translate('PREMIUM CATEGORIES')),
                _buildCategories(),
                _buildSectionHeader(LocaleService().translate('FEATURED PRODUCTS')),
                _buildProductGrid(),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
          extendBody: true,
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildAppBar() {
    final name = AuthService().userName;
    final greeting = name.isNotEmpty ? 'WELCOME, ${name.toUpperCase()}' : 'FITZONE';
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: name.isEmpty,
      title: name.isEmpty
          ? Text(
              LocaleService().translate('FITZONE'),
              style: LocaleService().getTextStyle(
                baseStyle: GoogleFonts.outfit(
                  fontWeight: FontWeight.w200,
                  letterSpacing: 8,
                  fontSize: 20,
                  color: AppTheme.textColor,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w200,
                    letterSpacing: 4,
                    fontSize: 14,
                    color: AppTheme.textColor,
                  ),
                ),
                Text(
                  'FITZONE',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w100,
                    letterSpacing: 8,
                    fontSize: 10,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, size: 20),
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
            if (CartService().itemCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      CartService().itemCount > 9
                          ? '9+'
                          : '${CartService().itemCount}',
                      style: GoogleFonts.outfit(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.textColor.withValues(alpha: 0.03),
            border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 14),
            decoration: InputDecoration(
              hintText: LocaleService().translate('SEARCH'),
              hintStyle: GoogleFonts.inter(color: AppTheme.textColor.withValues(alpha: 0.24)),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor, size: 18),
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: Icon(Icons.close, color: AppTheme.textColor.withValues(alpha: 0.24), size: 16),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  )
                : null,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return const SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverToBoxAdapter(
        child: CarouselBanner(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: LocaleService().getTextStyle(
                baseStyle: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 4,
                  color: AppTheme.textColor.withValues(alpha: 0.54),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.pushNamed(context, '/categories');
                if (result != null && result is String) {
                  setState(() {
                    _selectedCategory = result;
                  });
                }
              },
              child: Text(
                LocaleService().translate('COLLECTIONS'),
                style: LocaleService().getTextStyle(
                  baseStyle: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['ALL', 'Football', 'Basketball', 'Running', 'Gym & Fitness', 'Nutrition'];
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = categories[index] == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = categories[index];
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      categories[index],
                      style: GoogleFonts.outfit(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textColor.withValues(alpha: 0.38),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 12,
                        height: 1,
                        color: AppTheme.primaryColor,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    final filteredProducts = _getFilteredProducts();
    
    if (ProductService().isLoading && filteredProducts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Center(
            child: Text(
              'No products found.',
              style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.5)),
            ),
          ),
        ),
      );
    }

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
            return ProductCard(
              product: filteredProducts[index],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      product: filteredProducts[index],
                    ),
                  ),
                );
              },
            );
          },
          childCount: filteredProducts.length,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      color: AppTheme.backgroundColor,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.grid_view, true, () {
            // Scroll to top or reset filters? Let's reset filters.
            setState(() {
              _selectedCategory = 'ALL';
              _searchController.clear();
            });
          }),
          _buildNavItem(Icons.category_outlined, false, () async {
            final result = await Navigator.pushNamed(context, '/categories');
            if (result != null && result is String) {
              setState(() {
                _selectedCategory = result;
              });
            }
          }),
          _buildNavItem(Icons.chat_bubble_outline, false, () => Navigator.pushNamed(context, '/chat')),
          _buildNavItem(Icons.person_outline, false, () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: isActive ? AppTheme.primaryColor : AppTheme.textColor.withValues(alpha: 0.24),
        size: 22,
      ),
    );
  }
}






