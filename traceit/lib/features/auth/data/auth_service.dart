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
    required String pvzDocId,
  }) async {
    final normalizedPhone = _normalizePhone(phone);
    final email = _emailFromPhone(normalizedPhone);

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    try {
      await _firestore.runTransaction((transaction) async {
        final pvzRef = _firestore.collection('pvz').doc(pvzDocId);
        final pvzSnap = await transaction.get(pvzRef);
        if (!pvzSnap.exists) {
          throw FirebaseAuthException(
            code: 'invalid-pvz',
            message: 'Выбранный ПВЗ не найден.',
          );
        }
        final d = pvzSnap.data()!;
        final code = (d['code'] ?? '').toString().trim().toUpperCase();
        if (code.isEmpty) {
          throw FirebaseAuthException(
            code: 'invalid-pvz',
            message: 'У ПВЗ не задан код.',
          );
        }
        final last = d['lastCustomerSeq'] is int
            ? d['lastCustomerSeq'] as int
            : (d['lastCustomerSeq'] as num?)?.toInt() ?? 0;
        final next = last + 1;
        final customerId = '$code$next';
        final pvzName = (d['name'] ?? '').toString().trim();
        final pvzAddress = (d['address'] ?? '').toString().trim();
        final pvzDisplay = pvzName.isNotEmpty ? pvzName : code;

        transaction.update(pvzRef, {'lastCustomerSeq': next});

        final userRef = _firestore.collection('users').doc(uid);
        final isAdminAllowlisted =
            _adminAllowlistPhones.contains(normalizedPhone);
        transaction.set(userRef, {
          'uid': uid,
          'name': name.trim(),
          'phone': normalizedPhone,
          'pvzDocId': pvzDocId,
          'pvzCode': code,
          'pvzName': pvzName,
          'pvzAddress': pvzAddress,
          'pvz': pvzDisplay,
          'customerId': customerId,
          'role': isAdminAllowlisted ? 'admin' : 'user',
          'isBlocked': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseAuthException catch (_) {
      try {
        await credential.user?.delete();
      } catch (_) {}
      rethrow;
    } catch (_) {
      try {
        await credential.user?.delete();
      } catch (_) {}
      throw FirebaseAuthException(
        code: 'registration-failed',
        message: 'Не удалось завершить регистрацию. Попробуйте снова.',
      );
    }
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

}
