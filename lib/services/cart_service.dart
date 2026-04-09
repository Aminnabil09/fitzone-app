import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import 'product_service.dart';
import 'auth_service.dart';

class CartItem {
  final Product product;
  int quantity;
  final String selectedSize;
  final String selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedSize,
    required this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toFirestore() => {
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'quantity': quantity,
        'selectedSize': selectedSize,
        'selectedColor': selectedColor,
      };
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];
  final _db = FirebaseFirestore.instance;
  bool _loaded = false;

  List<CartItem> get items => _items;
  String get _docId => AuthService().currentNumericId ?? '';
  CollectionReference get _cartRef => _db.collection('users').doc(_docId).collection('cart');

  // ─── LOAD FROM FIRESTORE ────────────────────────────────────────────────────
  Future<void> loadCart() async {
    if (_docId.isEmpty || _loaded) return;
    _loaded = true;
    final snapshot = await _cartRef.get();
    _items.clear();
    // Use live Firestore products from ProductService — NOT hardcoded sample data
    final allProducts = ProductService().products;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final productIndex = allProducts.indexWhere((p) => p.id == data['productId']);
      if (productIndex == -1) continue; // Product not found in Firestore catalog
      _items.add(CartItem(
        product: allProducts[productIndex],
        quantity: data['quantity'] ?? 1,
        selectedSize: data['selectedSize'] ?? '',
        selectedColor: data['selectedColor'] ?? '',
      ));
    }
    notifyListeners();
  }

  void resetLoader() {
    _loaded = false;
    _items.clear();
  }

  // ─── ADD TO CART ────────────────────────────────────────────────────────────
  void addToCart(Product product, String size, String color) {
    final existingIndex = _items.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedSize == size &&
        item.selectedColor == color);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, selectedSize: size, selectedColor: color));
    }
    _syncToFirestore();
    notifyListeners();
  }

  // ─── REMOVE FROM CART ───────────────────────────────────────────────────────
  void removeFromCart(CartItem item) {
    _items.remove(item);
    _syncToFirestore();
    notifyListeners();
  }

  // ─── UPDATE QUANTITY ────────────────────────────────────────────────────────
  void updateQuantity(CartItem item, int quantity) {
    if (quantity <= 0) {
      removeFromCart(item);
    } else {
      item.quantity = quantity;
      _syncToFirestore();
      notifyListeners();
    }
  }

  // ─── CLEAR CART ─────────────────────────────────────────────────────────────
  void clearCart() {
    _items.clear();
    if (_docId.isNotEmpty) {
      _cartRef.get().then((snap) {
        for (final doc in snap.docs) {
          doc.reference.delete();
        }
      });
    }
    notifyListeners();
  }

  // ─── SYNC ALL ITEMS TO FIRESTORE ────────────────────────────────────────────
  Future<void> _syncToFirestore() async {
    if (_docId.isEmpty) return;
    // Delete existing and re-write (simple strategy for small carts)
    final snap = await _cartRef.get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    for (final item in _items) {
      await _cartRef.add(item.toFirestore());
    }
  }

  double get totalPrice => _items.fold(0.0, (acc, item) => acc + item.totalPrice);
  int get itemCount => _items.fold(0, (acc, item) => acc + item.quantity);
}
