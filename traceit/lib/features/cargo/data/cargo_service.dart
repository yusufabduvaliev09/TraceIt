import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traceit/features/cargo/domain/client_model.dart';
import '../domain/cargo_model.dart';

class CargoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<CargoModel>> getMyCargo(String userUid) {
    return _db
        .collection('cargo')
        .where('ownerUid', isEqualTo: userUid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CargoModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<CargoModel>> getAllCargo() {
    return _db.collection('cargo').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => CargoModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addCargo({
    required String ownerUid,
    required String ownerName,
    required String ownerCustomerId,
    required String title,
    required String description,
    required String trackCode,
    required double weight,
    String status = 'pending',
  }) async {
    await _db.collection('cargo').add({
      'ownerUid': ownerUid,
      'ownerName': ownerName.trim(),
      'ownerCustomerId': ownerCustomerId.trim(),
      'title': title.trim(),
      'description': description.trim(),
      'trackCode': trackCode.trim(),
      'weight': weight,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateCargoStatus({
    required String cargoId,
    required String status,
  }) async {
    await _db.collection('cargo').doc(cargoId).update({'status': status});
  }

  Future<void> bulkUpdateCargoStatus({
    required List<String> cargoIds,
    required String fromStatus,
    required String toStatus,
  }) async {
    final batch = _db.batch();
    for (final id in cargoIds) {
      final ref = _db.collection('cargo').doc(id);
      batch.update(ref, {'status': toStatus, 'previousStatus': fromStatus});
    }
    await batch.commit();
  }

  Stream<List<ClientModel>> getAllUsers() {
    return _db.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => ClientModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateUserPvz({
    required String uid,
    required String pvz,
  }) async {
    await _db.collection('users').doc(uid).update({'pvz': pvz});
  }

  /// Updates user PVZ fields from a `pvz/{pvzDocId}` document (ID клиента не меняется).
  Future<void> updateUserPvzFromDoc({
    required String uid,
    required String pvzDocId,
  }) async {
    final doc = await _db.collection('pvz').doc(pvzDocId).get();
    if (!doc.exists || doc.data() == null) return;
    final d = doc.data()!;
    final code = (d['code'] ?? '').toString().trim().toUpperCase();
    final name = (d['name'] ?? '').toString().trim();
    final address = (d['address'] ?? '').toString().trim();
    final display = name.isNotEmpty ? name : code;
    await _db.collection('users').doc(uid).update({
      'pvzDocId': pvzDocId,
      'pvzCode': code,
      'pvzName': name,
      'pvzAddress': address,
      'pvz': display,
    });
  }

  Future<void> setUserBlocked({
    required String uid,
    required bool isBlocked,
  }) async {
    await _db.collection('users').doc(uid).update({'isBlocked': isBlocked});
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    String? targetUid,
  }) async {
    await _db.collection('notifications').add({
      'title': title.trim(),
      'body': body.trim(),
      'targetUid': targetUid,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendBroadcastNotification({
    required String message,
    required String createdBy,
  }) async {
    await _db.collection('notifications').add({
      'title': 'Admin Broadcast',
      'body': message.trim(),
      'targetUid': null,
      'createdBy': createdBy,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Global China warehouse address. Document: `app_config/public`, field `chinaWarehouseAddress`.
  Stream<String> watchChinaWarehouseAddress() {
    return _db.doc('app_config/public').snapshots().map((doc) {
      final v = doc.data()?['chinaWarehouseAddress'];
      return v == null ? '' : v.toString().trim();
    });
  }

  Future<String> readChinaWarehouseAddressOnce() async {
    final doc = await _db.doc('app_config/public').get();
    final v = doc.data()?['chinaWarehouseAddress'];
    return v == null ? '' : v.toString().trim();
  }

  /// Шаблон с плейсхолдером (ID) или {ID}. Document: `app_config/public`.
  Stream<String> watchChinaAddressTemplate() {
    return _db.doc('app_config/public').snapshots().map((doc) {
      final v = doc.data()?['chinaAddressTemplate'];
      return v == null ? '' : v.toString().trim();
    });
  }

  Future<String> readChinaAddressTemplateOnce() async {
    final doc = await _db.doc('app_config/public').get();
    final v = doc.data()?['chinaAddressTemplate'];
    return v == null ? '' : v.toString().trim();
  }

  Future<void> saveChinaAddressTemplate(String template) async {
    await _db.doc('app_config/public').set(
          {'chinaAddressTemplate': template.trim()},
          SetOptions(merge: true),
        );
  }

  Future<void> addUserParcel({
    required String ownerUid,
    required String ownerName,
    required String ownerCustomerId,
    required String trackCode,
    required String description,
  }) async {
    final t = trackCode.trim();
    final d = description.trim();
    await _db.collection('cargo').add({
      'ownerUid': ownerUid,
      'ownerName': ownerName.trim(),
      'ownerCustomerId': ownerCustomerId.trim(),
      'title': d.isNotEmpty ? d : t,
      'description': d,
      'trackCode': t,
      'weight': 0.0,
      'status': 'pending',
      'source': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
