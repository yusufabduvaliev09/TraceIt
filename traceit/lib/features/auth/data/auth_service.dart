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
  static const Set<String> _adminAllowlistPhones = {};

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
    final customerId = await _generateUniqueCustomerId();
    final isAdminAllowlisted = _adminAllowlistPhones.contains(normalizedPhone);
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'phone': normalizedPhone,
      'pvz': pvz,
      'customerId': customerId,
      'role': isAdminAllowlisted ? 'admin' : 'user',
      'isBlocked': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    final normalizedPhone = _normalizePhone(phone);
    final email = _emailFromPhone(normalizedPhone);
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final doc =
        await _firestore.collection('users').doc(credential.user!.uid).get();
    if ((doc.data()?['isBlocked'] ?? false) == true) {
      await _auth.signOut();
      throw FirebaseAuthException(
        code: 'user-blocked',
        message: 'User is blocked by administrator.',
      );
    }
  }

  Future<void> logout() => _auth.signOut();

  Stream<Map<String, dynamic>?> userDocument(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.data(),
        );
  }

  Future<Map<String, dynamic>?> userDocumentOnce(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  String _emailFromPhone(String phone) => '${phone.replaceAll('+', '')}@traceit.app';

  String _normalizePhone(String value) {
    var digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('996')) {
      return '+$digits';
    }
    if (digits.length == 9) {
      return '+996$digits';
    }
    return '+$digits';
  }

  String _generateCustomerId() {
    final random = Random();
    final code = 1000 + random.nextInt(9000);
    return 'TR-$code';
  }

  Future<String> _generateUniqueCustomerId() async {
    for (var i = 0; i < 10; i++) {
      final id = _generateCustomerId();
      final exists = await _firestore
          .collection('users')
          .where('customerId', isEqualTo: id)
          .limit(1)
          .get();
      if (exists.docs.isEmpty) return id;
    }
    return 'TR-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }
}
