import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';
import 'auth_service.dart';

class ReviewService extends ChangeNotifier {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream reviews for a specific product
  Stream<List<ProductReview>> streamReviews(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ProductReview.fromFirestore(doc)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // Calculate average rating for a product
  Stream<double> streamAverageRating(String productId) {
    return _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return 0.0;
      double total = 0;
      for (var doc in snap.docs) {
        total += (doc.data()['rating'] as num?)?.toDouble() ?? 0.0;
      }
      return total / snap.docs.length;
    });
  }

  // Add a new review
  Future<void> addReview({
    required String productId,
    required double rating,
    required String comment,
  }) async {
    final auth = AuthService();
    if (!auth.isLoggedIn) return;

    final review = {
      'userId': auth.userId,
      'userName': auth.userName,
      'userNumericId': auth.currentNumericId ?? 'N/A',
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db
        .collection('products')
        .doc(productId)
        .collection('reviews')
        .add(review);
  }
}
