import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/cargo_model.dart';

class CargoService {
  // FirebaseFirestore instansiyasini olamiz
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream - bu "o'zgarmas oqim". Agar bazada bitta posilka o'zgarsa, 
  // ilovadagi ro'yxat ham avtomat o'zgaradi (Refresh shart emas).
  Stream<List<CargoModel>> getMyCargo(String userUid) {
    return _db
        .collection('cargo') // 'cargo' degan kolleksiyadan qidir
        .where('ownerUid', isEqualTo: userUid) // Faqat shu foydalanuvchinikini ol
        .snapshots() // O'zgarishlarni kuzatib tur
        .map((snapshot) => snapshot.docs
            .map((doc) => CargoModel.fromFirestore(doc.data(), doc.id))
            .toList()); // Hammasini bitta ro'yxatga (List) yig'
  }
}