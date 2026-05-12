import 'dart:convert';

class SyncChange {
  const SyncChange({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.payload,
    required this.clientChangedAt,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String action;
  final Map<String, dynamic> payload;
  final DateTime clientChangedAt;

  Map<String, dynamic> toWireJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'action': action,
      'client_changed_at': clientChangedAt.toUtc().toIso8601String(),
      'payload': payload,
    };
  }

  String get payloadJson => jsonEncode(payload);
}
