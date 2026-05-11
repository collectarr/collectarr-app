class SyncChange {
  const SyncChange({
    required this.entityType,
    required this.action,
    required this.payload,
    this.entityId,
    this.clientChangedAt,
  });

  final String entityType;
  final String? entityId;
  final String action;
  final Map<String, dynamic> payload;
  final DateTime? clientChangedAt;

  Map<String, dynamic> toJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'payload': payload,
      'client_changed_at': clientChangedAt?.toIso8601String(),
    };
  }
}
