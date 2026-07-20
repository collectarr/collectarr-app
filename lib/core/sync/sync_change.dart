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

/// Outcome of a single sync round-trip.
class SyncResult {
  const SyncResult({
    required this.serverTime,
    this.rejectedChanges = const [],
  });

  final DateTime serverTime;
  final List<SyncRejectedChange> rejectedChanges;

  int get rejectedCount => rejectedChanges.length;
  bool get hasRejectedChanges => rejectedChanges.isNotEmpty;
}

/// A local change that the server did not accept during push.
class SyncRejectedChange {
  const SyncRejectedChange({
    required this.entityType,
    required this.entityId,
    required this.reason,
    this.currentClientChangedAt,
    this.serviceAction,
    this.servicePayload,
    this.localAction,
    this.localPayload,
    this.localClientChangedAt,
  });

  final String entityType;
  final String entityId;
  final String reason;
  final DateTime? currentClientChangedAt;
  final String? serviceAction;
  final Map<String, dynamic>? servicePayload;
  final String? localAction;
  final Map<String, dynamic>? localPayload;
  final DateTime? localClientChangedAt;

  String get key => '$entityType:$entityId';
  bool get hasDiffPayload => servicePayload != null || localPayload != null;

  factory SyncRejectedChange.fromJson(
    Map<String, dynamic> json, {
    SyncChange? localChange,
  }) {
    final currentClientChangedAt = json['current_client_changed_at'];
    final currentPayload = json['current_payload'];
    return SyncRejectedChange(
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      reason: json['reason'] as String? ?? 'rejected',
      currentClientChangedAt: currentClientChangedAt is String
          ? DateTime.parse(currentClientChangedAt).toUtc()
          : null,
      serviceAction: json['current_action'] as String?,
      servicePayload:
          currentPayload is Map ? currentPayload.cast<String, dynamic>() : null,
      localAction: localChange?.action,
      localPayload: localChange?.payload,
      localClientChangedAt: localChange?.clientChangedAt,
    );
  }
}
