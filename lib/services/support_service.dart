import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_report.dart';
import 'auth_service.dart';

class SupportService extends ChangeNotifier {
  static final SupportService _instance = SupportService._internal();
  factory SupportService() => _instance;
  SupportService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USER OPERATIONS ────────────────────────────────────────────────────────

  Future<void> submitReport({
    required String type,
    required String subject,
    required String message,
  }) async {
    final auth = AuthService();
    if (!auth.isLoggedIn) return;

    final String docId = auth.currentNumericId ?? auth.userId;

    final report = {
      'userId': auth.userId,
      'userName': auth.userName,
      'userNumericId': auth.currentNumericId ?? 'N/A',
      'type': type,
      'subject': subject,
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    // Save under the user's specific document (Numeric ID preferred) for consistency
    await _db
        .collection('users')
        .doc(docId)
        .collection('reports')
        .add(report);
  }

  Stream<List<SupportReport>> streamUserReports() {
    final auth = AuthService();
    if (!auth.isLoggedIn) return const Stream.empty();

    final String docId = auth.currentNumericId ?? auth.userId;

    return _db
        .collection('users')
        .doc(docId)
        .collection('reports')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => SupportReport.fromFirestore(doc)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  // ─── ADMIN OPERATIONS ───────────────────────────────────────────────────────

  Stream<List<SupportReport>> streamAllReports() {
    // Use collectionGroup to find all 'reports' subcollections across all users
    return _db
        .collectionGroup('reports')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => SupportReport.fromFirestore(doc)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> replyToReport(String reportId, String reply) async {
    // Since we only have the reportId, we search for it across all report collections
    final snapshot = await _db.collectionGroup('reports').get();
    final docRef = snapshot.docs.firstWhere((doc) => doc.id == reportId).reference;

    await docRef.update({
      'adminReply': reply,
      'status': 'replied',
      'repliedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<int> streamPendingCount() {
    return _db
        .collectionGroup('reports')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
