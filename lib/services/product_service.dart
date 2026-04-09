import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService extends ChangeNotifier {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<Product> _products = [];
  bool _isLoaded = false;
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoaded => _isLoaded;
  bool get isLoading => _isLoading;

  // Stream of all products, allowing UI to react to database changes in real-time
  Stream<List<Product>> streamProducts() {
    return _db.collection('products').snapshots().map((snapshot) {
      final newProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      _products = newProducts;
      if (!_isLoaded) {
        _isLoaded = true;
        notifyListeners();
      }
      return newProducts;
    });
  }

  // Load products once
  Future<void> loadProducts({bool force = false}) async {
    if ((_isLoaded && !force) || _isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('products').get();
      _products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      _isLoaded = true;
    } catch (e) {
      debugPrint("Error loading products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Find a specific product by ID
  Product? getProductById(String id) {
    if (!_isLoaded) {
      // It's recommended to call loadProducts prior to this if data might not be loaded.
      debugPrint("Warning: getProductById called before products are loaded.");
    }
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Seed the empty database with sample products
  Future<void> seedDatabaseIfEmpty() async {
    final snapshot = await _db.collection('products').limit(1).get();
    if (snapshot.docs.isEmpty) {
      debugPrint("Products collection is empty. Seeding data...");
      final batch = _db.batch();
      final sampleProducts = Product.getSampleProducts();
      
      for (final product in sampleProducts) {
        // Use the hardcoded ID as the document ID for consistency during dev/seed
        final docRef = _db.collection('products').doc(product.id);
        batch.set(docRef, product.toFirestore());
      }
      
      await batch.commit();
      debugPrint("Successfully seeded ${sampleProducts.length} products.");
    }
  }

  // ─── ADMIN CRUD OPERATIONS ──────────────────────────────────────────────

  Future<void> addProduct(Product product) async {
    try {
      // Find the highest numeric ID currently in use
      int maxId = 0;
      final snapshot = await _db
          .collection('products')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        int? currentId = int.tryParse(snapshot.docs.first.id);
        if (currentId != null) {
          maxId = currentId;
        }
      }
      
      String newId = (maxId + 1).toString();
      
      final docRef = _db.collection('products').doc(newId);
      final newProduct = Product(
        id: docRef.id,
        name: product.name,
        price: product.price,
        imageUrl: product.imageUrl,
        category: product.category,
        description: product.description,
        colors: product.colors,
        sizes: product.sizes,
        stock: product.stock,
      );
      await docRef.set(newProduct.toFirestore()).timeout(const Duration(seconds: 15));
      await loadProducts(force: true);
    } catch (e) {
      debugPrint("Error adding product: $e");
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _db.collection('products').doc(product.id).update(product.toFirestore()).timeout(const Duration(seconds: 15));
      await loadProducts(force: true);
    } catch (e) {
      debugPrint("Error updating product: $e");
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _db.collection('products').doc(id).delete().timeout(const Duration(seconds: 15));
      await loadProducts(force: true);
    } catch (e) {
      debugPrint("Error deleting product: $e");
      rethrow;
    }
  }
}
