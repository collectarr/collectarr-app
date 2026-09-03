import 'package:collectarr_app/core/models/catalog_entity_ref.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_id.dart';
import 'package:collectarr_app/features/providers/domain/models/provider_personal_entry.dart';
import 'package:flutter/foundation.dart';

@immutable
final class ProviderItemLink {
  const ProviderItemLink({
    required this.accountId,
    required this.provider,
    required this.remoteItemId,
    this.remoteEntryId,
    required this.localEntityRef,
    this.baseSnapshot,
    this.lastPulledAt,
    this.lastPushedAt,
    this.remoteRevision,
    this.metadata = const {},
  });

  final String accountId;
  final ProviderId provider;
  final String remoteItemId;
  final String? remoteEntryId;
  final CatalogEntityRef localEntityRef;
  final ProviderPersonalEntry? baseSnapshot;
  final DateTime? lastPulledAt;
  final DateTime? lastPushedAt;
  final String? remoteRevision;
  final Map<String, dynamic> metadata;

  ProviderItemLink copyWith({
    String? accountId,
    ProviderId? provider,
    String? remoteItemId,
    String? remoteEntryId,
    CatalogEntityRef? localEntityRef,
    ProviderPersonalEntry? baseSnapshot,
    DateTime? lastPulledAt,
    DateTime? lastPushedAt,
    String? remoteRevision,
    Map<String, dynamic>? metadata,
  }) {
    return ProviderItemLink(
      accountId: accountId ?? this.accountId,
      provider: provider ?? this.provider,
      remoteItemId: remoteItemId ?? this.remoteItemId,
      remoteEntryId: remoteEntryId ?? this.remoteEntryId,
      localEntityRef: localEntityRef ?? this.localEntityRef,
      baseSnapshot: baseSnapshot ?? this.baseSnapshot,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      lastPushedAt: lastPushedAt ?? this.lastPushedAt,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'provider': provider.value,
        'remoteItemId': remoteItemId,
        if (remoteEntryId != null) 'remoteEntryId': remoteEntryId,
        'localEntityRef': localEntityRef.toJson(),
        if (baseSnapshot != null) 'baseSnapshot': baseSnapshot!.toJson(),
        if (lastPulledAt != null)
          'lastPulledAt': lastPulledAt!.toIso8601String(),
        if (lastPushedAt != null)
          'lastPushedAt': lastPushedAt!.toIso8601String(),
        if (remoteRevision != null) 'remoteRevision': remoteRevision,
        'metadata': metadata,
      };

  factory ProviderItemLink.fromJson(Map<String, dynamic> json) {
    final refMap = json['localEntityRef'] as Map? ?? const {};
    return ProviderItemLink(
      accountId: json['accountId']?.toString() ?? '',
      provider: ProviderId.fromValue(json['provider']?.toString()) ??
          ProviderId.aniList,
      remoteItemId: json['remoteItemId']?.toString() ?? '',
      remoteEntryId: json['remoteEntryId']?.toString(),
      localEntityRef: CatalogEntityRef(
        id: refMap['id']?.toString() ?? '',
        kind: refMap['kind']?.toString() ?? '',
        entityType: CatalogEntityType.fromApiValue(
          refMap['entityType']?.toString() ?? refMap['entity_type']?.toString(),
        ),
      ),
      baseSnapshot: json['baseSnapshot'] != null && json['baseSnapshot'] is Map
          ? ProviderPersonalEntry.fromJson(
              Map<String, dynamic>.from(json['baseSnapshot'] as Map))
          : null,
      lastPulledAt: json['lastPulledAt'] != null
          ? DateTime.tryParse(json['lastPulledAt'].toString())
          : null,
      lastPushedAt: json['lastPushedAt'] != null
          ? DateTime.tryParse(json['lastPushedAt'].toString())
          : null,
      remoteRevision: json['remoteRevision']?.toString(),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    );
  }
}
