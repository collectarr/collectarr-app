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
    this.acceptedKeys = const {},
  });

  final DateTime serverTime;
  final List<SyncRejectedChange> rejectedChanges;

  /// Entities the server took from this device in this round-trip.
  final Set<String> acceptedKeys;

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
  bool get canKeepLocal => localAction != null && localPayload != null;

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

  /// Restores a conflict that is still waiting for the user's decision.
  factory SyncRejectedChange.fromStoredJson(Map<String, dynamic> json) {
    final localAt = json['local_client_changed_at'];
    final localPayload = json['local_payload'];
    final wire = SyncRejectedChange.fromJson(json);
    return SyncRejectedChange(
      entityType: wire.entityType,
      entityId: wire.entityId,
      reason: wire.reason,
      currentClientChangedAt: wire.currentClientChangedAt,
      serviceAction: wire.serviceAction,
      servicePayload: wire.servicePayload,
      localAction: json['local_action'] as String?,
      localPayload:
          localPayload is Map ? localPayload.cast<String, dynamic>() : null,
      localClientChangedAt:
          localAt is String ? DateTime.parse(localAt).toUtc() : null,
    );
  }

  Map<String, dynamic> toStoredJson() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'reason': reason,
      'current_client_changed_at':
          currentClientChangedAt?.toUtc().toIso8601String(),
      'current_action': serviceAction,
      'current_payload': servicePayload,
      'local_action': localAction,
      'local_payload': localPayload,
      'local_client_changed_at':
          localClientChangedAt?.toUtc().toIso8601String(),
    };
  }
}
