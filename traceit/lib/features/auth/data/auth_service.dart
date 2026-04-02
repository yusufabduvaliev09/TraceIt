import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required String pvz,
  }) async {
    final normalizedPhone = _normalizePhone(phone);
    final email = _emailFromPhone(normalizedPhone);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    final customerId = _generateCustomerId();
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'phone': normalizedPhone,
      'pvz': pvz,
      'customerId': customerId,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    final normalizedPhone = _normalizePhone(phone);
    final email = _emailFromPhone(normalizedPhone);
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() => _auth.signOut();

  Stream<Map<String, dynamic>?> userDocument(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.data(),
        );
  }

  String _emailFromPhone(String phone) => '$phone@traceit.app';

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  String _generateCustomerId() {
    final random = Random();
    final code = 1000 + random.nextInt(9000);
    return 'TR-$code';
  }
}
