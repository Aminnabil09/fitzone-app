import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class WishlistService extends ChangeNotifier {
  static final WishlistService _instance = WishlistService._internal();
  factory WishlistService() => _instance;
  WishlistService._internal();

  final Set<String> _wishlistProductIds = {};
  final _db = FirebaseFirestore.instance;
  bool _loaded = false;

  String get _docId => AuthService().currentNumericId ?? '';
  CollectionReference get _wishRef =>
      _db.collection('users').doc(_docId).collection('wishlist');

  // ─── LOAD FROM FIRESTORE ────────────────────────────────────────────────────
  Future<void> loadWishlist() async {
    if (_docId.isEmpty || _loaded) return;
    _loaded = true;
    final snapshot = await _wishRef.get();
    _wishlistProductIds.clear();
    for (final doc in snapshot.docs) {
      _wishlistProductIds.add((doc.data() as Map)['productId'] as String);
    }
    notifyListeners();
  }

  void resetLoader() {
    _loaded = false;
    _wishlistProductIds.clear();
  }

  bool isFavorite(String productId) => _wishlistProductIds.contains(productId);

  // ─── TOGGLE FAVORITE ────────────────────────────────────────────────────────
  Future<void> toggleFavorite(String productId) async {
    if (_wishlistProductIds.contains(productId)) {
      _wishlistProductIds.remove(productId);
      if (_docId.isNotEmpty) {
        final snap = await _wishRef.where('productId', isEqualTo: productId).get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }
    } else {
      _wishlistProductIds.add(productId);
      if (_docId.isNotEmpty) {
        await _wishRef.add({'productId': productId});
      }
    }
    notifyListeners();
  }

  List<String> get wishlistProductIds => _wishlistProductIds.toList();
}
