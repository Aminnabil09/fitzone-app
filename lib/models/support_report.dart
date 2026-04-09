import 'package:cloud_firestore/cloud_firestore.dart';

class SupportReport {
  final String id;
  final String userId;
  final String userName;
  final String userNumericId;
  final String type; // 'App', 'Product', 'Order', 'Other'
  final String subject;
  final String message;
  final String? adminReply;
  final String status; // 'pending', 'replied'
  final DateTime createdAt;
  final DateTime? repliedAt;

  SupportReport({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userNumericId,
    required this.type,
    required this.subject,
    required this.message,
    this.adminReply,
    required this.status,
    required this.createdAt,
    this.repliedAt,
  });

  factory SupportReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportReport(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Unknown User',
      userNumericId: data['userNumericId'] ?? 'N/A',
      type: data['type'] ?? 'General',
      subject: data['subject'] ?? 'No Subject',
      message: data['message'] ?? '',
      adminReply: data['adminReply'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      repliedAt: (data['repliedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userNumericId': userNumericId,
      'type': type,
      'subject': subject,
      'message': message,
      'adminReply': adminReply,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'repliedAt': repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
    };
  }
}
