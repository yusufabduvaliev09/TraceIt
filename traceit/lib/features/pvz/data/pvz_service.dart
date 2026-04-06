import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traceit/features/pvz/domain/pvz_model.dart';

class PvzService {
  PvzService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('pvz');

  Stream<List<PvzModel>> watchPvzList() {
    return _col.snapshots().map(
          (snap) {
            final list = snap.docs
                .map((d) => PvzModel.fromFirestore(d.data(), d.id))
                .toList();
            list.sort((a, b) => a.code.compareTo(b.code));
            return list;
          },
        );
  }

  Future<void> addPvz({
    required String code,
    required String name,
    required String address,
  }) async {
    final c = code.trim().toUpperCase();
    await _col.add({
      'code': c,
      'name': name.trim(),
      'address': address.trim(),
      'lastCustomerSeq': 0,
      'whatsappTemplate': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePvz({
    required String id,
    required String code,
    required String name,
    required String address,
  }) async {
    await _col.doc(id).update({
      'code': code.trim().toUpperCase(),
      'name': name.trim(),
      'address': address.trim(),
    });
  }

  Future<void> updateWhatsappTemplate({
    required String pvzId,
    required String template,
  }) async {
    await _col.doc(pvzId).update({'whatsappTemplate': template.trim()});
  }

  Future<PvzModel?> getPvzOnce(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return PvzModel.fromFirestore(doc.data()!, doc.id);
  }
}
