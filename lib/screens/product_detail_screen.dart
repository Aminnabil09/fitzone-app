import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../utils/app_theme.dart';
import '../services/cart_service.dart';
import '../services/locale_service.dart';

import '../services/theme_service.dart';
import '../widgets/animated_background.dart';
import '../services/wishlist_service.dart';
import '../services/review_service.dart';
import '../services/auth_service.dart';
import '../models/review.dart';
class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  String _selectedColor = '';
  int _quantity = 1;
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();

  @override
  void initState() {
    super.initState();
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors[0];
    }
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes[0];
    }
  }

  void _addToCart() {
    if (_selectedSize.isEmpty || _selectedColor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PLEASE SELECT A VARIANT TO PROCEED',
            style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600, color: AppTheme.backgroundColor),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      );
      return;
    }

    // Add for each quantity selected
    for (int i = 0; i < _quantity; i++) {
      _cartService.addToCart(
        widget.product,
        _selectedSize,
        _selectedColor,
      );
    }
    
    // Reset quantity
    setState(() => _quantity = 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ADDED TO YOUR COLLECTION',
          style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600, color: AppTheme.backgroundColor),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(24),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _wishlistService,
      builder: (context, child) {
        return ListenableBuilder(
          listenable: Listenable.merge([LocaleService(), ThemeService()]),
          builder: (context, child) {
            return Scaffold(
              body: AnimatedBackground(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(),
                    _buildHeroImage(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildSizeSelector(),
                            const SizedBox(height: 32),
                            _buildColorSelector(),
                            const SizedBox(height: 32),
                            _buildDescription(),
                            const SizedBox(height: 48),
                            _buildReviewsHeader(),
                            const SizedBox(height: 24),
                            _buildReviewsList(),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              extendBody: true,
              bottomNavigationBar: _buildPurchaseSheet(),
            );
          },
        );
      },
    );
  }

  Widget _buildAppBar() {
    final isFav = _wishlistService.isFavorite(widget.product.id);
    return SliverAppBar(
      expandedHeight: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        _buildCircleAction(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? AppTheme.primaryColor : AppTheme.textColor,
          onTap: () => _wishlistService.toggleFavorite(widget.product.id),
        ),
        const SizedBox(width: 8),
        _buildCircleAction(
          Icons.ios_share,
          onTap: () => _showShareFeedback(),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, {Color? color, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.textColor.withValues(alpha: 0.05),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color ?? AppTheme.textColor),
        onPressed: onTap,
      ),
    );
  }

  void _showShareFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ARCHIVE LINK COPIED TO CLIPBOARD',
          style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600, color: AppTheme.backgroundColor),
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(24),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }

  Widget _buildHeroImage() {
    return SliverToBoxAdapter(
      child: Hero(
        tag: 'product_${widget.product.id}',
        child: Container(
          height: 400,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
          ),
          child: Image.network(
            widget.product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.fitness_center,
              size: 100,
              color: AppTheme.textColor.withValues(alpha: 0.24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                widget.product.name,
                style: LocaleService().getTextStyle(
                  baseStyle: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w200,
                    color: AppTheme.textColor,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
             Text(
              '\$${widget.product.price.toStringAsFixed(0)}',
              style: LocaleService().getTextStyle(
                baseStyle: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.category.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleService().translate('SIZE'),
          style: LocaleService().getTextStyle(
            baseStyle: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 4,
              color: AppTheme.textColor.withValues(alpha: 0.38),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.product.sizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 70,
                height: 52,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textColor.withValues(alpha: 0.03),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textColor.withValues(alpha: 0.1),
                    width: isSelected ? 1 : 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: GoogleFonts.outfit(
                      color: isSelected ? AppTheme.backgroundColor : AppTheme.textColor,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w300,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FINISH',
          style: LocaleService().getTextStyle(
            baseStyle: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 4,
              color: AppTheme.textColor.withValues(alpha: 0.38),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          children: widget.product.colors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Container(
                  color: _getColorFromString(color),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleService().translate('SPECIFICATIONS'),
          style: LocaleService().getTextStyle(
            baseStyle: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 4,
              color: AppTheme.textColor.withValues(alpha: 0.38),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.product.description,
          style: LocaleService().getTextStyle(
            baseStyle: GoogleFonts.inter(
              fontSize: 14,
              height: 1.8,
              fontWeight: FontWeight.w300,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseSheet() {
    return Container(
      color: AppTheme.backgroundColor,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Row(
        children: [
          _buildQuantitySelector(),
          const SizedBox(width: 24),
          Expanded(
            child: ElevatedButton(
              onPressed: _addToCart,
              child: Text(LocaleService().translate('ACQUIRE')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
            icon: Icon(Icons.remove, color: AppTheme.textColor, size: 18),
          ),
          Text(
            '$_quantity',
            style: GoogleFonts.outfit(
              color: AppTheme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon: const Icon(Icons.add, color: AppTheme.primaryColor, size: 18),
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
      default: return Colors.grey;
    }
  }

  Widget _buildReviewsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'USER REVIEWS',
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 4,
            color: AppTheme.textColor.withValues(alpha: 0.38),
          ),
        ),
        if (AuthService().isLoggedIn)
          GestureDetector(
            onTap: _showAddReviewDialog,
            child: Text(
              'WRITE A REVIEW',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
                letterSpacing: 2,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewsList() {
    return StreamBuilder<List<ProductReview>>(
      stream: ReviewService().streamReviews(widget.product.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'BE THE FIRST TO REVIEW THIS PRODUCT',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: AppTheme.textColor.withValues(alpha: 0.2),
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        }

        return Column(
          children: reviews.map((review) => _buildReviewTile(review)).toList(),
        );
      },
    );
  }

  Widget _buildReviewTile(ProductReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
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
              Text(
                review.userName.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: AppTheme.primaryColor,
                    size: 10,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: AppTheme.secondaryTextColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog() {
    double selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'SHARE YOUR FEEDBACK',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w200,
              letterSpacing: 4,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () => setDialogState(() => selectedRating = index + 1.0),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 4,
                style: GoogleFonts.inter(color: AppTheme.textColor, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  hintStyle: GoogleFonts.inter(color: AppTheme.textColor.withValues(alpha: 0.2)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.textColor.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.5))),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) return;
                await ReviewService().addReview(
                  productId: widget.product.id,
                  rating: selectedRating,
                  comment: commentController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: Text('SUBMIT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

