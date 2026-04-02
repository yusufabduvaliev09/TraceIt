import 'package:cloud_firestore/cloud_firestore.dart';
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
    required String title,
    required String trackCode,
    required double weight,
    String status = 'pending',
  }) async {
    await _db.collection('cargo').add({
      'ownerUid': ownerUid,
      'title': title.trim(),
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

  Future<void> sendNotification({
    required String title,
    required String body,
    String? targetUid,
  }) async {
    await _db.collection('notifications').add({
      'title': title.trim(),
      'body': body.trim(),
      'targetUid': targetUid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}