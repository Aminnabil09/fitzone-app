import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../widgets/animated_background.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(context),
            _buildSearchBar(),
            _buildProductList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add, color: AppTheme.backgroundColor),
        onPressed: () => Navigator.pushNamed(context, '/product_form'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'MANAGE PRODUCTS',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w200,
          letterSpacing: 4,
          fontSize: 14,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.textColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.outfit(color: AppTheme.textColor, fontSize: 14),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'SEARCH PRODUCTS...',
              hintStyle: GoogleFonts.outfit(
                color: AppTheme.textColor.withValues(alpha: 0.3),
                fontSize: 12,
                letterSpacing: 2,
              ),
              prefixIcon: Icon(Icons.search, color: AppTheme.textColor.withValues(alpha: 0.3), size: 20),
              suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppTheme.textColor.withValues(alpha: 0.3), size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return ListenableBuilder(
      listenable: ProductService(),
      builder: (context, child) {
        var products = ProductService().products;
        
        // Filter based on search query
        if (_searchQuery.isNotEmpty) {
          products = products.where((p) => 
            p.name.toLowerCase().contains(_searchQuery) || 
            p.category.toLowerCase().contains(_searchQuery)
          ).toList();
        }
        
        if (ProductService().isLoading && products.isEmpty && _searchQuery.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
          );
        }

        if (products.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Text(
                _searchQuery.isEmpty ? 'NO PRODUCTS FOUND' : 'NO RESULTS FOR "$_searchQuery"',
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
                final product = products[index];
                return _buildProductTile(context, product);
              },
              childCount: products.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductTile(BuildContext context, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.textColor.withValues(alpha: 0.02),
        border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.05), width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.1)),
          ),
          child: product.imageUrl.isNotEmpty
              ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.image, color: AppTheme.textColor.withValues(alpha: 0.2)))
              : Icon(Icons.image, color: AppTheme.textColor.withValues(alpha: 0.2)),
        ),
        title: Text(
          product.name.toUpperCase(),
          style: GoogleFonts.outfit(
            color: AppTheme.textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '\$${product.price.toStringAsFixed(2)} • ${product.category.toUpperCase()}',
          style: GoogleFonts.outfit(
            color: AppTheme.textColor.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppTheme.textColor.withValues(alpha: 0.7), size: 20),
              onPressed: () => Navigator.pushNamed(context, '/product_form', arguments: product),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => _confirmDelete(context, product),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text('DELETE PRODUCT', style: GoogleFonts.outfit(color: AppTheme.textColor)),
        content: Text('Are you sure you want to delete ${product.name}?', style: GoogleFonts.outfit(color: AppTheme.textColor)),
        actions: [
          TextButton(
            child: Text('CANCEL', style: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.5))),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onPressed: () async {
              await ProductService().deleteProduct(product.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
