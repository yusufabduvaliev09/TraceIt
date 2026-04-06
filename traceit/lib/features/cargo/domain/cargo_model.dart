import 'package:traceit/features/cargo/domain/cargo_status.dart';

class CargoModel {
  final String id;           // Posilkaning bazadagi noyob ID raqami
  final String title;        // Posilka nomi (masalan: "Oshxonaga pichoq")
  final String description;
  final String trackCode;    // Trek-kod (Pinduoduo yoki boshqa joydan)
  final double weight;       // Posilkaning vazni (kg da)
  final String status;       // See [CargoStatusKeys]
  final DateTime createdAt;  // Ro'yxatga olingan vaqti

  // Konstruktor - bu modelga ma'lumotlarni solish uchun kerak
  CargoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.trackCode,
    required this.weight,
    required this.status,
    required this.createdAt,
  });

  // FromFirestore - bu Firebase'dan kelgan JSON ma'lumotni 
  // Dart tilidagi tushunarli modelga aylantirib beradi.
  factory CargoModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return CargoModel(
      id: documentId,
      title: json['title'] ?? '', // Agar nom bo'lmasa, bo'sh joy qo'y
      description: json['description'] ?? '',
      trackCode: json['trackCode'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(), // Sonni double formatga o'tkazish
      status: CargoStatusKeys.normalize(json['status']?.toString()),
      createdAt: (json['createdAt'] != null) 
          ? json['createdAt'].toDate() 
          : DateTime.now(),
    );
  }
}