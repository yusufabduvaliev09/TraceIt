class PvzModel {
  PvzModel({
    required this.id,
    required this.code,
    required this.name,
    required this.address,
    required this.lastCustomerSeq,
    this.whatsappTemplate = '',
  });

  final String id;
  final String code;
  final String name;
  final String address;
  final int lastCustomerSeq;
  final String whatsappTemplate;

  String get displayLabel => '$code — $name';

  factory PvzModel.fromFirestore(Map<String, dynamic> json, String id) {
    return PvzModel(
      id: id,
      code: (json['code'] ?? '').toString().trim(),
      name: (json['name'] ?? '').toString().trim(),
      address: (json['address'] ?? '').toString().trim(),
      lastCustomerSeq: (json['lastCustomerSeq'] ?? 0) is int
          ? json['lastCustomerSeq'] as int
          : (json['lastCustomerSeq'] as num?)?.toInt() ?? 0,
      whatsappTemplate: (json['whatsappTemplate'] ?? '').toString(),
    );
  }
}
