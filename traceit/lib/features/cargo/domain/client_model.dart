class ClientModel {
  ClientModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.customerId,
    required this.pvz,
    this.pvzDocId,
    required this.role,
    required this.isBlocked,
  });

  final String uid;
  final String name;
  final String phone;
  final String customerId;
  final String pvz;
  final String? pvzDocId;
  final String role;
  final bool isBlocked;

  factory ClientModel.fromFirestore(Map<String, dynamic> json, String uid) {
    return ClientModel(
      uid: uid,
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      customerId: (json['customerId'] ?? '').toString(),
      pvz: (json['pvz'] ?? '').toString(),
      pvzDocId: json['pvzDocId']?.toString(),
      role: (json['role'] ?? 'user').toString(),
      isBlocked: (json['isBlocked'] ?? false) == true,
    );
  }
}
