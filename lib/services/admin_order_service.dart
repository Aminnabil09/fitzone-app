import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrder {
  final String id;
  final String userId;
  final DateTime date;
  final double totalAmount;
  final String status;
  final List<dynamic> items;
  final String? customerName; // Backup name if directly in order doc

  AdminOrder({
    required this.id,
    required this.userId,
    required this.date,
    required this.totalAmount,
    required this.status,
    required this.items,
    this.customerName,
  });

  factory AdminOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Robust Price Detection
    double price = 0.0;
    if (data.containsKey('totalAmount')) {
      price = (data['totalAmount'] as num).toDouble();
    } else if (data.containsKey('totalPrice')) {
      price = (data['totalPrice'] as num).toDouble();
    } else if (data.containsKey('total')) {
      price = (data['total'] as num).toDouble();
    } else if (data.containsKey('amount')) {
      price = (data['amount'] as num).toDouble();
    }

    // Robust User ID Detection
    String uid = data['userId'] ?? data['user_id'] ?? data['uid'] ?? 'Unknown';
    
    // Check if name is already hardcoded in the order
    String? cName = data['customerName'] ?? data['customer'] ?? data['name'];

    return AdminOrder(
      id: doc.id,
      userId: uid,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalAmount: price,
      status: data['status'] ?? 'pending',
      items: data['items'] as List<dynamic>? ?? [],
      customerName: cName,
    );
  }
}

class AdminOrderService extends ChangeNotifier {
  static final AdminOrderService _instance = AdminOrderService._internal();
  factory AdminOrderService() => _instance;
  AdminOrderService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<AdminOrder> _orders = [];

  List<AdminOrder> get orders => _orders;

  // Total revenue calculation
  double get totalRevenue => _orders.fold(0.0, (previousValue, order) => previousValue + order.totalAmount);

  // Stream all orders globally using a Collection Group
  Stream<List<AdminOrder>> streamGlobalOrders() {
    return _db.collectionGroup('orders').snapshots().map((snapshot) {
      final newOrders = snapshot.docs.map((doc) => AdminOrder.fromFirestore(doc)).toList();
      newOrders.sort((a, b) => b.date.compareTo(a.date)); // Sort locally to bypass Firebase composite index requirements
      _orders = newOrders;
      return newOrders;
    });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Find the document path. Since collectionGroup queries don't give us the direct parent easy to update without the ref
      // We can just use the reference from the document if we had it, but since we didn't save the ref in the model,
      // let's do a query to find the document by id globally and update it.
      final snapshot = await _db.collectionGroup('orders').where(FieldPath.documentId, isEqualTo: orderId).get();
      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({'status': newStatus});
      }
    } catch (e) {
      debugPrint("Error updating order status: \$e");
    }
  }
}
