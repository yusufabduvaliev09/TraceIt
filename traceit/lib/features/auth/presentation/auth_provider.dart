import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:traceit/features/auth/data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service ?? AuthService() {
    _subscription = _service.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  final AuthService _service;
  StreamSubscription<User?>? _subscription;
  bool isLoading = false;
  String? errorMessage;

  User? get currentUser => _service.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required String pvz,
  }) async {
    await _run(() => _service.register(
          name: name,
          phone: phone,
          password: password,
          pvz: pvz,
        ));
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    await _run(() => _service.login(phone: phone, password: password));
  }

  Future<void> logout() async {
    await _run(_service.logout);
  }

  Stream<Map<String, dynamic>?> userDocumentStream() {
    final user = currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return _service.userDocument(user.uid);
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Authentication failed';
    } catch (_) {
      errorMessage = 'Unexpected error. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
