import 'package:cloud_firestore/cloud_firestore.dart';

class InAppNotification {
  InAppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.targetUid,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String? targetUid;
  final DateTime createdAt;

  factory InAppNotification.fromFirestore(
    Map<String, dynamic> json,
    String id,
  ) {
    return InAppNotification(
      id: id,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      targetUid: json['targetUid'] as String?,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
