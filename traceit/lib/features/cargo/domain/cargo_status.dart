/// ABU Cargo parcel lifecycle (Firestore `cargo.status`).
class CargoStatusKeys {
  static const pending = 'pending';
  static const warehouseChina = 'warehouse_china';
  static const transit = 'transit';
  static const readyPickup = 'ready_pickup';
  static const received = 'received';

  static const List<String> homeOrder = [
    pending,
    warehouseChina,
    transit,
    readyPickup,
    received,
  ];

  static String labelRu(String key) {
    switch (key) {
      case pending:
        return 'В ожидании';
      case warehouseChina:
        return 'На складе в Китае';
      case transit:
        return 'В пути';
      case readyPickup:
        return 'Готов к выдаче';
      case received:
        return 'Получено';
      default:
        return key;
    }
  }

  /// Maps legacy statuses from older data.
  static String normalize(String? raw) {
    final s = (raw ?? pending).trim();
    switch (s) {
      case 'delivered':
        return received;
      case 'warehouse':
        return warehouseChina;
      default:
        return s;
    }
  }
}
