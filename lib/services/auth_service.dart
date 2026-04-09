import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_service.dart';
import 'wishlist_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // In-memory profile cache (loaded from Firestore)
  String userName = '';
  String userImage = '';
  String userRole = 'user';
  String? currentNumericId; // Cache the numeric ID for document lookups

  bool get isAdmin => userRole == 'admin';

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String get userId => _auth.currentUser?.uid ?? '';
  String get userEmail => _auth.currentUser?.email ?? '';

  // ─── SIGN UP ────────────────────────────────────────────────────────────────
  Future<String?> signUp(String email, String password, String name) async {
    try {
      // Create user in Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final String uid = cred.user!.uid;

      // Generate a professional Numeric ID (e.g., 10001, 10002)
      int maxNumericId = 10000;
      try {
        final querySnapshot = await _db
            .collection('users')
            .orderBy('numericId', descending: true)
            .limit(1)
            .get();
            
        if (querySnapshot.docs.isNotEmpty) {
          final data = querySnapshot.docs.first.data();
          if (data.containsKey('numericId')) {
            maxNumericId = int.tryParse(data['numericId'].toString()) ?? 10000;
          }
        }
      } catch (e) {
        debugPrint("Error scanning for numericId: $e");
      }
      
      final String finalNumericId = (maxNumericId + 1).toString();
      currentNumericId = finalNumericId;

      // Save initial profile to Firestore using the NUMERIC ID as the DOCUMENT ID
      // This follows user preference while maintaining a single source of truth
      await _db.collection('users').doc(finalNumericId).set({
        'name': name.trim(),
        'email': email.trim(),
        'numericId': finalNumericId,
        'authUid': uid, // Essential for looking up the numericId via uid later
        'photoUrl': '',
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      userName = name.trim();
      userImage = '';
      userRole = 'user';
      await CartService().loadCart();
      await WishlistService().loadWishlist();
      notifyListeners();
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  // ─── SIGN IN ────────────────────────────────────────────────────────────────
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await loadUserProfile();
      await CartService().loadCart();
      await WishlistService().loadWishlist();
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    }
  }

  // ─── SIGN OUT ───────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    userName = '';
    userImage = '';
    userRole = 'user';
    currentNumericId = null;
    CartService().resetLoader();
    WishlistService().resetLoader();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  // ─── LOAD PROFILE FROM FIRESTORE ────────────────────────────────────────────
  Future<void> loadUserProfile() async {
    if (userId.isEmpty) return;
    
    // Find the document where authUid matches (since docId is numericId)
    final snapshot = await _db.collection('users')
        .where('authUid', isEqualTo: userId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      final data = doc.data();
      currentNumericId = doc.id; // Correctly get the Numeric ID from the doc name
      
      userName = data['name'] ?? '';
      userImage = data['photoUrl'] ?? '';
      userRole = data['role'] ?? 'user';

      // Consolidation check: if a document also exists using the UID, merge its subcollections
      await _consolidateUserData(currentNumericId!);

      // Demo/Development mode logic
      if (userRole != 'admin') {
        final adminCheck = await _db.collection('users').where('role', isEqualTo: 'admin').limit(1).get();
        if (adminCheck.docs.isEmpty) {
          userRole = 'admin';
          await _db.collection('users').doc(currentNumericId!).set({'role': 'admin'}, SetOptions(merge: true));
        }
      }

      notifyListeners();
    } else {
      // Fallback: If no document matches authUid, check if doc exists at exactly UID
      // (likely created by buggy services before standardizing)
      final uidDoc = await _db.collection('users').doc(userId).get();
      if (uidDoc.exists) {
        // We found a record but it's using UID as the name. We should probably keep using it 
        // to avoid "Guest" states, but the user wants numericId as the document name.
        // We will have to wait for them to register or manually fix.
      }
    }
  }

  /// Consolidates data from a UID-based document into a NumericID-based document.
  /// This includes moving subcollections like 'cart', 'orders', 'reports', etc.
  Future<void> _consolidateUserData(String targetNumericId) async {
    if (userId.isEmpty || targetNumericId == userId) return;

    final uidDocRef = _db.collection('users').doc(userId);
    final uidDocSnap = await uidDocRef.get();
    
    if (!uidDocSnap.exists) return; // Nothing to consolidate

    debugPrint('CONSOLIDATING DATA FOR USER: $userId -> $targetNumericId');

    final targetDocRef = _db.collection('users').doc(targetNumericId);
    
    // List of subcollections to migrate (Cart, Wishlist, Orders, Addresses, etc.)
    final subcollections = ['cart', 'wishlist', 'orders', 'reports', 'addresses', 'payment_methods'];

    for (var sub in subcollections) {
      final oldSub = uidDocRef.collection(sub);
      final newSub = targetDocRef.collection(sub);
      
      final snap = await oldSub.get();
      for (var doc in snap.docs) {
        // Copy to NEW subcollection
        await newSub.doc(doc.id).set(doc.data());
        // Delete from OLD subcollection
        await doc.reference.delete();
      }
    }

    // Finally delete the old root UID document
    await uidDocRef.delete();
    debugPrint('CONSOLIDATION COMPLETE: REMOVED LEGACY UID DOCUMENT $userId');
  }

  // ─── UPDATE PROFILE ─────────────────────────────────────────────────────────
  Future<void> updateUserProfile(String name, String imageUrl) async {
    if (currentNumericId == null) return;
    
    userName = name;
    userImage = imageUrl;
    
    await _db.collection('users').doc(currentNumericId!).update({
      'name': name,
      'photoUrl': imageUrl,
    });
    
    notifyListeners();
  }

  // ─── AUTH STATE STREAM ──────────────────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── LEGACY (kept for compatibility) ────────────────────────────────────────
  Future<void> checkLoginStatus() async {
    await loadUserProfile();
    notifyListeners();
  }

  // ─── ERROR MESSAGES ─────────────────────────────────────────────────────────
  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'NO ACCOUNT FOUND WITH THIS EMAIL.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'INCORRECT EMAIL OR PASSWORD.';
      case 'email-already-in-use':
        return 'THIS EMAIL IS ALREADY REGISTERED.';
      case 'weak-password':
        return 'PASSWORD MUST BE AT LEAST 6 CHARACTERS.';
      case 'invalid-email':
        return 'PLEASE ENTER A VALID EMAIL ADDRESS.';
      case 'too-many-requests':
        return 'TOO MANY ATTEMPTS. PLEASE TRY AGAIN LATER.';
      default:
        return 'AUTHENTICATION FAILED. PLEASE TRY AGAIN.';
    }
  }
}
