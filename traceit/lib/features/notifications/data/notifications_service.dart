import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traceit/features/notifications/domain/in_app_notification.dart';

class NotificationsService {
  NotificationsService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Broadcast docs use `targetUid: null`; personal ones use the user's uid.
  Stream<List<InAppNotification>> watchForUser(String userUid) {
    return _db
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => InAppNotification.fromFirestore(d.data(), d.id))
              .where(
                (n) => n.targetUid == null || n.targetUid == userUid,
              )
              .toList(),
        );
  }
}
