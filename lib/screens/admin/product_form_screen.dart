import 'dart:io';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../widgets/animated_background.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  Product? _existingProduct;
  bool _isInit = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController(); 
  final _descController = TextEditingController();
  final _stockController = TextEditingController();
  final _sizesController = TextEditingController();
  final _colorsController = TextEditingController(); 
  final _imageUrlController = TextEditingController(); 

  final List<String> _predefinedCategories = [
    'Gym & Fitness', 'Football', 'Basketball', 'Running', 
    'Clothing', 'Shoes', 'Accessories', 'Equipment', 
    'Nutrition', 'Yoga & Wellness', 'Other'
  ];
  String _selectedCategory = 'Gym & Fitness';
  
  String _imageUrl = '';
  File? _imageFile;
  Uint8List? _imageBytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Product) {
        _existingProduct = args;
        _nameController.text = _existingProduct!.name;
        _priceController.text = _existingProduct!.price.toString();
        _descController.text = _existingProduct!.description;
        _stockController.text = _existingProduct!.stock.toString();
        _imageUrl = _existingProduct!.imageUrl;
        _imageUrlController.text = _existingProduct!.imageUrl;
        _sizesController.text = _existingProduct!.sizes.join(', ');
        _colorsController.text = _existingProduct!.colors.join(', ');
        
        if (_predefinedCategories.contains(_existingProduct!.category)) {
          _selectedCategory = _existingProduct!.category;
        } else {
          _selectedCategory = 'Other';
          _categoryController.text = _existingProduct!.category;
        }
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _stockController.dispose();
    _sizesController.dispose();
    _colorsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        if (!kIsWeb) {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _priceController.clear();
      _descController.clear();
      _stockController.clear();
      _sizesController.clear();
      _colorsController.clear();
      _imageUrlController.clear();
      _categoryController.clear();
      _selectedCategory = 'Gym & Fitness';
      _imageBytes = null;
      _imageFile = null;
      _imageUrl = '';
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate image presence for new products
    if (_existingProduct == null && _imageBytes == null && _imageFile == null && _imageUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PLEASE UPLOAD AN IMAGE OR PROVIDE A URL')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String finalImageUrl = _imageUrl;

      // 1. Upload image to Storage if a new one was selected
      if (_imageBytes != null) {
        final String path = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadedUrl = await StorageService().uploadImage(_imageBytes!, path);
        
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        } else {
          throw Exception('Image upload failed');
        }
      } else if (_imageUrlController.text.trim().isNotEmpty) {
        finalImageUrl = _imageUrlController.text.trim();
      }

      // 2. Prepare Product Data
      final finalCategory = _selectedCategory == 'Other' ? _categoryController.text.trim() : _selectedCategory;
      final suppliedSizes = _sizesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final suppliedColors = _colorsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final cleanedPrice = _priceController.text.replaceAll(RegExp(r'[^\d.]'), '');

      final product = Product(
        id: _existingProduct?.id ?? '',
        name: _nameController.text.trim(),
        price: double.tryParse(cleanedPrice) ?? 0.0,
        category: finalCategory,
        description: _descController.text.trim(),
        stock: int.tryParse(_stockController.text) ?? 1,
        imageUrl: finalImageUrl,
        colors: suppliedColors,
        sizes: suppliedSizes,
      );

      // 3. Save to Firestore
      if (_existingProduct == null) {
        await ProductService().addProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SUCCESS: PRODUCT ADDED TO INVENTORY'), backgroundColor: AppTheme.primaryColor),
          );
          _resetForm(); // Clear the form for next product as requested
        }
      } else {
        await ProductService().updateProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SUCCESS: PRODUCT DETAILS UPDATED'), backgroundColor: AppTheme.primaryColor),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ERROR SAVING PRODUCT: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _existingProduct == null ? 'ADD PRODUCT' : 'EDIT PRODUCT',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
            fontSize: 14,
            color: AppTheme.textColor,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: AnimatedBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildImagePicker(),
                        const SizedBox(height: 16),
                        _buildTextField('IMAGE URL (OPTIONAL FALLBACK)', _imageUrlController),
                        const SizedBox(height: 32),
                        _buildTextField('PRODUCT NAME', _nameController, isRequired: true),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('PRICE (\$)', _priceController, isRequired: true, isNumber: true)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('STOCK', _stockController, isRequired: true, isNumber: true)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCategoryDropdown(),
                        if (_selectedCategory == 'Other') ...[
                          const SizedBox(height: 16),
                          _buildTextField('CUSTOM CATEGORY', _categoryController, isRequired: true),
                        ],
                        const SizedBox(height: 16),
                        _buildTextField('SIZES (E.G. S, M, L OR 10 KG, 20 KG)', _sizesController),
                        const SizedBox(height: 16),
                        _buildTextField('COLORS (E.G. BLACK, RED, BLUE)', _colorsController),
                        const SizedBox(height: 16),
                        _buildTextField('DESCRIPTION', _descController, isRequired: true, maxLines: 4),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: AppTheme.backgroundColor,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          child: Text(
                            'SAVE PRODUCT',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.textColor.withValues(alpha: 0.02),
          border: Border.all(color: AppTheme.textColor.withValues(alpha: 0.1)),
        ),
        child: _imageBytes != null
            ? Image.memory(_imageBytes!, fit: BoxFit.cover)
            : _imageFile != null && !kIsWeb
                ? Image.file(_imageFile!, fit: BoxFit.cover)
                : _imageUrl.isNotEmpty
                    ? Image.network(_imageUrl, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppTheme.textColor.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text(
                            'TAP TO UPLOAD IMAGE',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: AppTheme.textColor.withValues(alpha: 0.5),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      dropdownColor: AppTheme.surfaceColor,
      decoration: InputDecoration(
        labelText: 'CATEGORY',
        labelStyle: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.5), fontSize: 12, letterSpacing: 2),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textColor.withValues(alpha: 0.2))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryColor)),
      ),
      style: GoogleFonts.outfit(color: AppTheme.textColor),
      items: _predefinedCategories.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(cat.toUpperCase(), style: GoogleFonts.outfit(fontSize: 12)),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _selectedCategory = val;
          });
        }
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isRequired = false, bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      style: GoogleFonts.outfit(color: AppTheme.textColor),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Required field';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: AppTheme.textColor.withValues(alpha: 0.5), fontSize: 12, letterSpacing: 2),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.textColor.withValues(alpha: 0.2))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryColor)),
      ),
    );
  }
}
