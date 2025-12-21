import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. GET ALL PRODUCTS (The Home Screen Stream)
  // We remove any .limit() and ensure strict ordering by Time
  Stream<QuerySnapshot> getProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true) // Newest items at the TOP
        .snapshots();
  }

  // 2. UPLOAD PRODUCT (With Category)
  Future<void> uploadProduct(String title, String description, double price, String sellerEmail, String imageUrl, String category) async {
    await _db.collection('products').add({
      'title': title,
      'description': description,
      'price': price,
      'sellerEmail': sellerEmail,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(), // Critical for sorting
    });
  }

  // 3. UPDATE USER PROFILE
  Future<void> updateUserProfile(String name, String photoUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.updateDisplayName(name);
    await user.updatePhotoURL(photoUrl);

    await _db.collection('users').doc(user.email).set({
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'photoUrl': photoUrl,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 4. GET USER PROFILE
  Future<Map<String, dynamic>?> getUserProfile(String email) async {
    try {
      var doc = await _db.collection('users').doc(email).get();
      return doc.data();
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }
}