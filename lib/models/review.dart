import 'package:cloud_firestore/cloud_firestore.dart';

class ProductReview {
  final String id;
  final String userId;
  final String userName;
  final String userNumericId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ProductReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userNumericId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ProductReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductReview(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userNumericId: data['userNumericId'] ?? 'N/A',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userNumericId': userNumericId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
